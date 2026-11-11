param([int]$Port = 8080)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
try {
    if (-not (Test-Path -LiteralPath '.local\maps.json')) {
        throw 'Create .local/maps.json with GOOGLE_MAPS_API_KEY as described in README.md.'
    }
    flutter build web --release --pwa-strategy=none --dart-define-from-file=.local/maps.json "--dart-define=API_BASE_URL=http://127.0.0.1:$Port/api/"
    if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
    python tool/preview_server.py --port $Port
} finally { Pop-Location }
