# extract-binary.ps1 — Windows-Pendant zu extract-binary.sh
#
# Usage:
#   ./extract-binary.ps1 -Archive upstream.tar.bz2 `
#                        -Binary sherpa-onnx-offline-websocket-server.exe `
#                        -LibGlob "*.dll" `
#                        -OutDir stage

param(
  [Parameter(Mandatory = $true)][string]$Archive,
  [Parameter(Mandatory = $true)][string]$Binary,
  [Parameter(Mandatory = $true)][string]$LibGlob,
  [Parameter(Mandatory = $true)][string]$OutDir
)

$ErrorActionPreference = "Stop"

$TmpDir = Join-Path $env:TEMP ("sherpa-extract-" + [Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

try {
  Write-Host "Extract $Archive to $TmpDir"
  # Windows 10 1803+ ships `tar` natively and handles .tar.bz2 via libarchive.
  & tar -xjf $Archive -C $TmpDir
  if ($LASTEXITCODE -ne 0) { throw "tar failed with exit code $LASTEXITCODE" }

  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

  $BinPath = Get-ChildItem -Path $TmpDir -Recurse -Filter $Binary -File |
             Select-Object -First 1
  if (-not $BinPath) {
    Write-Error "Binary '$Binary' nicht im Tarball gefunden"
    Get-ChildItem -Path $TmpDir -Recurse -Depth 3 -File | Select-Object -First 30
    exit 1
  }
  Copy-Item $BinPath.FullName (Join-Path $OutDir $Binary)
  Write-Host "Binary kopiert: $(Join-Path $OutDir $Binary)"

  $LibCount = 0
  Get-ChildItem -Path $TmpDir -Recurse -Filter $LibGlob -File | ForEach-Object {
    $Dest = Join-Path $OutDir $_.Name
    if (-not (Test-Path $Dest)) {
      Copy-Item $_.FullName $Dest
      $LibCount++
    }
  }
  Write-Host "Libs kopiert: $LibCount"
  Get-ChildItem $OutDir
}
finally {
  Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
