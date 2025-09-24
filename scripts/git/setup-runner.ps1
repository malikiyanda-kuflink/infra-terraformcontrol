#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# --- TOKEN (must be set before running) ---
# Example (set this in your terminal before executing the script):
# $env:GITHUB_REG_TOKEN = '<FRESH_TOKEN_FROM_GITHUB_UI>'
$Token = $env:GITHUB_REG_TOKEN
if ([string]::IsNullOrWhiteSpace($Token)) {
  throw 'Set a fresh registration token first: $env:GITHUB_REG_TOKEN = ''<token>'''
}

# --- CONFIG (runner) ---
$RepoUrl       = 'https://github.com/malikiyanda-kuflink/infra-terraformcontrol'  # repo or org URL
$RunnerName    = 'windows-tf-runner'
$Labels        = 'tf-runner'
$RunnerVersion = '2.328.0'
$RunnerDir     = 'C:\actions-personal-runner'
$WorkFolder    = 'windows-tf-runner'

# --- CONFIG (Terraform) ---
$TerraformVersion = '1.6.6'
$TerraformDir     = 'C:\terraform'
$TerraformExe     = Join-Path $TerraformDir 'terraform.exe'

Write-Host '=== GitHub Actions Runner + Terraform Setup ===' -ForegroundColor Green

# ---------- Runner setup ----------
if (-not (Test-Path $RunnerDir)) {
  New-Item -ItemType Directory -Path $RunnerDir | Out-Null
}
Set-Location $RunnerDir

# Stop/uninstall any lingering runner service (safe if absent)
if (Test-Path '.\svc') {
  try { .\svc stop } catch {}
  try { .\svc uninstall } catch {}
}

# Clean stale config files
foreach ($f in @('.runner','.credentials','.credentials_rsaparams','_diag')) {
  if (Test-Path $f) { Remove-Item $f -Recurse -Force }
}

# Download runner if needed
$runnerZip = "actions-runner-win-x64-$RunnerVersion.zip"
if (-not (Test-Path "$RunnerDir\bin\Runner.Listener.exe")) {
  Write-Host "[*] Downloading runner v$RunnerVersion..."
  Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$RunnerVersion/$runnerZip" -OutFile "$RunnerDir\$runnerZip"
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$RunnerDir\$runnerZip", $RunnerDir)
  } catch {
    # If already extracted, continue
  }
}

# Configure (unattended + replace)
Write-Host '[*] Configuring runner...'
$cfgArgs = @(
  '--unattended',
  '--url', $RepoUrl,
  '--token', $Token,
  '--name', $RunnerName,
  '--runnergroup','Default',
  '--work', $WorkFolder,
  '--labels', $Labels,
  '--replace'
)
& .\config.cmd @cfgArgs

# Verify config actually succeeded
if (-not (Test-Path '.runner' -Force) -or -not (Test-Path '.credentials' -Force)) {
  throw 'Configuration failed (.runner/.credentials missing). Use a fresh token and re-run.'
}

# Install & start the Windows service (correct binary)
Write-Host '[*] Installing and starting runner service...'
.\svc install
.\svc start

# ---------- Terraform install ----------
Write-Host "[*] Installing Terraform $TerraformVersion..."
if (Test-Path $TerraformDir) { Remove-Item -Recurse -Force $TerraformDir }
New-Item -ItemType Directory -Path $TerraformDir | Out-Null

$tfZip = Join-Path $env:TEMP "terraform_${TerraformVersion}_windows_amd64.zip"
$tfUrl = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"
Invoke-WebRequest -Uri $tfUrl -OutFile $tfZip

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tfZip, $TerraformDir)

# Optional: make Terraform available in the current session PATH
$env:Path = "$TerraformDir;$env:Path"

# Verify Terraform
& $TerraformExe version | Write-Host

Write-Host "Runner '$RunnerName' is online. Terraform installed at: $TerraformExe" -ForegroundColor Green
