# Automated Windows Release Build & Single-File Installer Packaging Script
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ">>> 1. Building Flutter Windows 64-bit Release Binary..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

flutter build windows --release --dart-define=API_BASE_URL=https://nexus-h44p.onrender.com/api/v1/

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ">>> 2. Packaging into Single-File Setup (.exe) via Inno Setup..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$isccPath = "C:\Users\Gaurav Kadam\AppData\Local\Programs\Inno Setup 6\ISCC.exe"
if (-not (Test-Path $isccPath)) {
    $found = Get-ChildItem 'C:\Program Files*\Inno Setup*\ISCC.exe', "$env:LOCALAPPDATA\Programs\Inno Setup*\ISCC.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($found) { $isccPath = $found }
}

if (-not (Test-Path $isccPath)) {
    Write-Error "ISCC.exe (Inno Setup Compiler) not found! Ensure Inno Setup 6 is installed."
    exit 1
}

& "$isccPath" "$PSScriptRoot\nexus_setup.iss"

$outputExe = "$PSScriptRoot\..\..\web\downloads\nexus-windows-setup.exe"
if (Test-Path $outputExe) {
    $sizeMb = [math]::Round((Get-Item $outputExe).Length / 1MB, 2)
    Write-Host ">>> SUCCESS! Generated: $outputExe ($sizeMb MB)" -ForegroundColor Green
} else {
    Write-Error "Failed to locate generated setup executable."
}
