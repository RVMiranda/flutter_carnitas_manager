Write-Host ""
Write-Host "Exquisssita Manager - Setup inicial" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que .env existe y tiene valores reales
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: El archivo .env no existe." -ForegroundColor Red
    Write-Host "Copia .env.example a .env y rellena SUPABASE_URL y SUPABASE_ANON_KEY" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

$envContent = Get-Content ".env" -Raw
if ($envContent -match "your-project-id" -or $envContent -match "your-anon-key-here") {
    Write-Host "ADVERTENCIA: El archivo .env tiene valores placeholder." -ForegroundColor Yellow
    Write-Host "Edita .env con los datos reales de tu proyecto Supabase." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "OK: .env encontrado y configurado" -ForegroundColor Green

# flutter pub get
Write-Host ""
Write-Host "Instalando dependencias..." -ForegroundColor White
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR en flutter pub get" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Dependencias instaladas" -ForegroundColor Green

# build_runner
Write-Host ""
Write-Host "Generando codigo (Drift + Riverpod)..." -ForegroundColor White
dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR en build_runner" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Codigo generado" -ForegroundColor Green

# flutter analyze
Write-Host ""
Write-Host "Analizando codigo..." -ForegroundColor White
flutter analyze

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Setup completo" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor White
Write-Host "  flutter run   (para correr en Android conectado)" -ForegroundColor Gray
Write-Host ""
Write-Host "Para desarrollo con hot-reload de codigo generado:" -ForegroundColor White
Write-Host "  dart run build_runner watch --delete-conflicting-outputs" -ForegroundColor Gray
Write-Host ""
