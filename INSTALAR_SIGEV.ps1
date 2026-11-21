$ErrorActionPreference = 'Stop'
$Root = Join-Path $PSScriptRoot 'SIGEV_Web'
$Runtime = Join-Path $Root 'runtime'
$NodeExe = Join-Path $Runtime 'node.exe'
$NodeVersion = 'v22.16.0'
$NodeZip = Join-Path $Root 'node-portable.zip'
$NodeUrl = "https://nodejs.org/dist/$NodeVersion/node-$NodeVersion-win-x64.zip"

function Fail($msg) { Write-Host "`nERRO: $msg" -ForegroundColor Red; exit 1 }
Write-Host 'SIGEV - Instalacao automatica' -ForegroundColor Cyan
Write-Host 'A preparar o sistema. Na primeira instalacao, precisa de Internet.'
if (-not (Test-Path $NodeExe)) {
  Write-Host "A descarregar Node.js portatil ($NodeVersion)..."
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZip -UseBasicParsing
    if ((Get-Item $NodeZip).Length -lt 10MB) { Fail 'O download do Node.js parece incompleto.' }
    New-Item -ItemType Directory -Force -Path $Runtime | Out-Null
    Expand-Archive -Path $NodeZip -DestinationPath (Join-Path $Root 'runtime-extract') -Force
    $Extracted = Join-Path (Join-Path $Root 'runtime-extract') "node-$NodeVersion-win-x64"
    Copy-Item -Path (Join-Path $Extracted '*') -Destination $Runtime -Recurse -Force
    Remove-Item (Join-Path $Root 'runtime-extract') -Recurse -Force
    Remove-Item $NodeZip -Force
  } catch { Fail "Nao foi possivel descarregar/preparar Node.js. Confirme a Internet e tente novamente. $($_.Exception.Message)" }
}
$env:Path = "$Runtime;$env:Path"
$env:npm_config_audit = 'false'; $env:npm_config_fund = 'false'
Write-Host 'A instalar componentes SIGEV (pode demorar alguns minutos)...'
Push-Location $Root
try {
  & (Join-Path $Runtime 'npm.cmd') install --omit=dev --no-audit --no-fund
  if ($LASTEXITCODE -ne 0) { Fail 'Instalacao dos componentes falhou. Tente novamente com Internet.' }
} finally { Pop-Location }
# Desktop shortcut for launcher
$ShortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'SIGEV - Externato Victoria.lnk'
$Wsh = New-Object -ComObject WScript.Shell
$Shortcut = $Wsh.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $PSScriptRoot 'ABRIR_SIGEV.bat'
$Shortcut.WorkingDirectory = $Root
$Shortcut.Description = 'Abrir o SIGEV - Externato Victoria'
$Shortcut.Save()
Write-Host "`nInstalacao concluida! Atalho criado no Ambiente de Trabalho." -ForegroundColor Green
Write-Host 'A abrir o SIGEV...'
Start-Process -FilePath (Join-Path $PSScriptRoot 'ABRIR_SIGEV.bat') -WorkingDirectory $PSScriptRoot
