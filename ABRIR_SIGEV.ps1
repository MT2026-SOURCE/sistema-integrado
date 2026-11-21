$ErrorActionPreference = 'Stop'
$Root = Join-Path $PSScriptRoot 'SIGEV_Web'
$Runtime = Join-Path $Root 'runtime'
$Node = Join-Path $Runtime 'node.exe'
if (-not (Test-Path $Node)) { Write-Host 'SIGEV ainda nao instalado. Execute INSTALAR_SIGEV.bat.'; exit 1 }
$env:Path = "$Runtime;$env:Path"
$env:DATA_DIR = Join-Path $Root 'data'
New-Item -ItemType Directory -Force -Path $env:DATA_DIR | Out-Null
$Port = 3000
function Test-Sigev($p) { try { (Invoke-RestMethod -Uri "http://127.0.0.1:$p/api/health" -TimeoutSec 2).ok -eq $true } catch { $false } }
if (-not (Test-Sigev $Port)) {
  $Test = New-Object System.Net.Sockets.TcpClient
  try { $Test.Connect('127.0.0.1',$Port); $Port = 3100; while ($Port -lt 3200) { $Probe=New-Object System.Net.Sockets.TcpClient; try {$Probe.Connect('127.0.0.1',$Port);$Port++} catch {break} finally {$Probe.Dispose()} } } catch { } finally {$Test.Dispose()}
}
$env:PORT = "$Port"
if (-not (Test-Sigev $Port)) {
  $Out = Join-Path $Root 'sigev-server.log'
  Start-Process -FilePath $Node -ArgumentList 'server.js' -WorkingDirectory $Root -WindowStyle Hidden -RedirectStandardOutput $Out -RedirectStandardError (Join-Path $Root 'sigev-error.log')
  $Ready = $false
  for ($i=0; $i -lt 30; $i++) { Start-Sleep -Seconds 1; if (Test-Sigev $Port) { $Ready=$true; break } }
  if (-not $Ready) { Write-Host "Servidor SIGEV nao arrancou. Veja o ficheiro: $Out"; Start-Process notepad.exe $Out; exit 1 }
}
$Url = "http://127.0.0.1:$Port"
$Edge = @('C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe','C:\Program Files\Microsoft\Edge\Application\msedge.exe') | Where-Object {Test-Path $_} | Select-Object -First 1
if ($Edge) { Start-Process $Edge -ArgumentList "--app=$Url" } else { Start-Process $Url }
