# Install bucket/marque.json with Scoop on a Windows runner and check what it
# installed: marque.exe in the app directory and the `marque` shim. The app is
# not launched (no interactive session on the runner).
$ErrorActionPreference = 'Stop'
$manifest = Join-Path $PWD 'bucket\marque.json'
scoop install $manifest
if ($LASTEXITCODE -ne 0) { throw "scoop install failed" }
$exe = Join-Path (scoop prefix marque) 'marque.exe'
if (-not (Test-Path $exe)) { throw "$exe is missing" }
$shim = (Get-Command marque).Source
Write-Output "marque.exe: $exe"
Write-Output "shim: $shim"
scoop uninstall marque
if ($LASTEXITCODE -ne 0) { throw "scoop uninstall failed" }
Write-Output "manifest install check passed"
