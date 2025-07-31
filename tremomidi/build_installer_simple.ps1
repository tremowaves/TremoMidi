# Script đơn giản để build installer TremoMidi
Write-Host "=== TremoMidi Installer Builder ===" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra Inno Setup
try {
    $null = Get-Command iscc -ErrorAction Stop
    Write-Host "Inno Setup found ✓" -ForegroundColor Green
} catch {
    Write-Host "Inno Setup not found. Please install from: https://jrsoftware.org/isinfo.php" -ForegroundColor Red
    Write-Host "After installation, restart your terminal and run this script again." -ForegroundColor Yellow
    exit 1
}

# Build Flutter app
Write-Host "Building Flutter application..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Flutter build completed ✓" -ForegroundColor Green

# Kiểm tra file cần thiết
$requiredFiles = @(
    "build\windows\x64\runner\Release\tremomidi.exe",
    "assets\TremoSoundFont.sf2"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "Missing required file: $file" -ForegroundColor Red
        exit 1
    }
}

# Build installer
Write-Host "Building installer..." -ForegroundColor Yellow
iscc setup.iss
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installer build failed!" -ForegroundColor Red
    exit 1
}

# Kiểm tra kết quả
$installerPath = "installer\TremoMidi-Setup.exe"
if (Test-Path $installerPath) {
    $fileSize = (Get-Item $installerPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "=== Build Completed Successfully! ===" -ForegroundColor Green
    Write-Host "Installer location: $installerPath" -ForegroundColor Cyan
    Write-Host "File size: $fileSizeMB MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now distribute this installer to users." -ForegroundColor Green
} else {
    Write-Host "Installer not found at expected location!" -ForegroundColor Red
    exit 1
} 