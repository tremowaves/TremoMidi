# Script để tải và cài đặt Inno Setup
Write-Host "Installing Inno Setup..." -ForegroundColor Green

# URL tải Inno Setup
$innosetupUrl = "https://files.jrsoftware.org/is/6/innosetup-6.2.2.exe"
$installerPath = "$env:TEMP\innosetup-installer.exe"

try {
    # Tải Inno Setup
    Write-Host "Downloading Inno Setup..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $innosetupUrl -OutFile $installerPath
    
    # Cài đặt Inno Setup
    Write-Host "Installing Inno Setup..." -ForegroundColor Yellow
    Start-Process -FilePath $installerPath -ArgumentList "/SILENT" -Wait
    
    # Thêm vào PATH
    $innosetupPath = "C:\Program Files (x86)\Inno Setup 6"
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$innosetupPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$innosetupPath", "Machine")
        Write-Host "Added Inno Setup to PATH" -ForegroundColor Green
    }
    
    # Xóa file tạm
    Remove-Item $installerPath -Force
    
    Write-Host "Inno Setup installed successfully!" -ForegroundColor Green
    Write-Host "Please restart your terminal/PowerShell to use iscc command" -ForegroundColor Yellow
    
} catch {
    Write-Host "Error installing Inno Setup: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download and install manually from: https://jrsoftware.org/isinfo.php" -ForegroundColor Yellow
} 