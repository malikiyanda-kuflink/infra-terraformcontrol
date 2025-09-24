#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# --- CONFIG ---
$runnerDir   = 'C:\actions-runner'
$RunnerName  = 'windows-tf-runner'
$RepoOwner   = 'kuflink'                     # org or user
$RepoName    = 'infra-terraformcontrol'      # repo name (omit if org runner)
$Scope       = 'repo'                        # 'repo' or 'org'

# --- TOKEN ---
$Pat = $env:GITHUB_PAT
if ([string]::IsNullOrWhiteSpace($Pat)) {
  throw "Set a GitHub PAT with the right scope first: `$env:GITHUB_PAT = '<token>'"
}
$Headers = @{ Authorization = "Bearer $Pat"; "Accept" = "application/vnd.github+json" }

Write-Host "=== Removing GitHub Actions Runner ($RunnerName) ===" -ForegroundColor Yellow

# --- LOCAL CLEANUP ---

Write-Host "[*] Stopping service/processes locally..."
if (Test-Path "$runnerDir\svc") {
  try { & "$runnerDir\svc" stop } catch {}
  try { & "$runnerDir\svc" uninstall } catch {}
}
Get-Process -Name "Runner.Listener","Runner.Worker" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Service | Where-Object { $_.Name -like 'actions.runner*' } | ForEach-Object {
  sc.exe stop    $_.Name 2>$null
  sc.exe delete  $_.Name 2>$null
}

Write-Host "[*] Removing runner folder..."
Remove-Item -LiteralPath $runnerDir -Recurse -Force -ErrorAction SilentlyContinue

# --- GITHUB CLEANUP ---

Write-Host "[*] Checking GitHub for runner '$RunnerName'..."
$baseUrl = "https://api.github.com"
$endpoint = if ($Scope -eq 'repo') {
  "$baseUrl/repos/$RepoOwner/$RepoName/actions/runners"
} else {
  "$baseUrl/orgs/$RepoOwner/actions/runners"
}

$runners = Invoke-RestMethod -Uri $endpoint -Headers $Headers -Method GET
$runner = $runners.runners | Where-Object { $_.name -eq $RunnerName }

if ($null -eq $runner) {
  Write-Host "Runner '$RunnerName' not found in GitHub (already removed)." -ForegroundColor Green
} else {
  Write-Host "[*] Removing runner id=$($runner.id) from GitHub..."
  $deleteEndpoint = "$endpoint/$($runner.id)"
  Invoke-RestMethod -Uri $deleteEndpoint -Headers $Headers -Method DELETE
  Write-Host "✅ Runner '$RunnerName' removed from GitHub." -ForegroundColor Green
}

Write-Host "✅ Local and GitHub runner removal complete." -ForegroundColor Cyan
