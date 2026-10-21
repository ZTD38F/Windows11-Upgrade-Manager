$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$readme = Get-Content -LiteralPath (Join-Path $root 'README.md') -Raw
$m = [regex]::Match($readme, 'powershell\.exe -NoExit -NoProfile -ExecutionPolicy Bypass -EncodedCommand ([A-Za-z0-9+/=]+)')
if (-not $m.Success) { throw 'README is missing the Win+R encoded one-liner' }
$encoded = $m.Groups[1].Value
$decoded = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encoded))
if ($decoded -notmatch 'raw\.githubusercontent\.com/ZTD38F/Windows11-Upgrade-Manager/main/bootstrap\.ps1') { throw 'Launcher targets unexpected repository' }
if ($decoded -notmatch 'Invoke-WebRequest.*-OutFile.*&') { throw 'Launcher must download then execute saved bootstrap' }
Write-Host '[PASS] Parsed and validated documented Win+R command.'
# Powershell -NoExit is only used by interactive users; CI runs identical payload without -NoExit.
$results = @('0' | powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded 2>&1)
$code = $LASTEXITCODE
$results | Out-Host
if ($code -ne 0) { throw "Encoded launcher exit code $code" }
if (($results -join "`n") -notmatch 'UPGRADE MANAGER') { throw 'Interactive menu never rendered' }
Write-Host '[PASS] Encoded command opened the real menu on Windows.'
