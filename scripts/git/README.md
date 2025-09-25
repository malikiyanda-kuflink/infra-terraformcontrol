# windows setup 

# setup runner 
$env:GITHUB_PAT = '<toekn>'
Set-ExecutionPolicy Bypass -Scope Process -Force
PowerShell -ExecutionPolicy Bypass -File ".\setup-runner.ps1"   

# Just run the runner manually (this works perfectly)
cd C:\actions-personal-runner
.\run.cmd


./config.cmd --url https://github.com/malikiyanda-kuflink/infra-terraformcontrol --token "<token>" --name tf-runner --labels tf-runner  

# remove runner 
$env:GITHUB_PAT = '<toekn>'
Set-ExecutionPolicy Bypass -Scope Process -Force
PowerShell -ExecutionPolicy Bypass -File "./remove-runner.ps1"