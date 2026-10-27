$ErrorActionPreference = "Stop"
$manifest = Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/manifest.json" | ConvertFrom-Json
$output = Join-Path $PSScriptRoot $manifest.archive
if (Test-Path -LiteralPath $output) { throw "Output already exists: $output" }
$stream = [System.IO.File]::Create($output)
try { foreach ($part in $manifest.parts) { $path = Join-Path $PSScriptRoot $part.name; if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() -ne $part.sha256) { throw "Bad part: $path" }; $inputStream = [System.IO.File]::OpenRead($path); try { $inputStream.CopyTo($stream) } finally { $inputStream.Dispose() } } } finally { $stream.Dispose() }
if ((Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLower() -ne $manifest.sha256) { throw "Archive hash mismatch" }
Write-Host "Verified: $output"
