# Script tổng hợp để build installer TremoMidi
param(
    [switch]$SkipInnoSetup,
    [switch]$SkipFlutterBuild
)

Write-Host "=== TremoMidi Installer Builder ===" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra Inno Setup
function Test-InnoSetup {
    try {
        $null = Get-Command iscc -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Cài đặt Inno Setup nếu cần
if (-not $SkipInnoSetup) {
    if (-not (Test-InnoSetup)) {
        Write-Host "Inno Setup not found. Installing..." -ForegroundColor Yellow
        & "$PSScriptRoot\install_innosetup.ps1"
        
        # Refresh environment variables
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        
        if (-not (Test-InnoSetup)) {
            Write-Host "Failed to install Inno Setup. Please install manually." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Inno Setup found ✓" -ForegroundColor Green
    }
}

# Build Flutter app
if (-not $SkipFlutterBuild) {
    Write-Host "Building Flutter application..." -ForegroundColor Yellow
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Flutter build failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Flutter build completed ✓" -ForegroundColor Green
} else {
    Write-Host "Skipping Flutter build..." -ForegroundColor Yellow
}

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