param([string]$FlutterRoot = '', [int]$TimeoutSeconds = 45)
$ErrorActionPreference = 'Stop'
if (!$FlutterRoot) {
    $flutterCommand = Get-Command flutter -ErrorAction Stop
    $FlutterRoot = Split-Path (Split-Path $flutterCommand.Source -Parent) -Parent
}
$dart = Join-Path $FlutterRoot 'bin/cache/dart-sdk/bin/dart.exe'
$snapshot = Join-Path $FlutterRoot 'bin/cache/flutter_tools.snapshot'
if (!(Test-Path -LiteralPath $dart) -or !(Test-Path -LiteralPath $snapshot)) {
    throw 'SDK sin bootstrap. Ejecuta flutter doctor con permisos de escritura sobre el SDK.'
}
# Invoke only the installed, cached SDK. No lock deletion or process termination.
# Requires pub get first; the test timeout applies to each test, not SDK startup.
Write-Host "Suite: Dart del SDK $FlutterRoot; timeout por prueba ${TimeoutSeconds}s"
& $dart $snapshot test --no-pub "--timeout=${TimeoutSeconds}s" --reporter=expanded --concurrency=2
exit $LASTEXITCODE
