# Hướng dẫn Build Installer Nhanh

## Bước 1: Cài đặt Inno Setup

1. Tải Inno Setup từ: https://jrsoftware.org/isinfo.php
2. Cài đặt với cài đặt mặc định
3. Khởi động lại terminal/PowerShell

## Bước 2: Build Installer

### Phương pháp A: Sử dụng PowerShell (Khuyến nghị)
```powershell
powershell -ExecutionPolicy Bypass -File build_installer_simple.ps1
```

### Phương pháp B: Sử dụng Batch file
```cmd
build_installer.bat
```

### Phương pháp C: Build thủ công
```cmd
# 1. Build Flutter app
flutter build windows --release

# 2. Build installer
iscc setup.iss
```

## Kết quả

Sau khi build thành công, file installer sẽ được tạo tại:
```
installer\TremoMidi-Setup.exe
```

## Troubleshooting

### Lỗi "iscc not found"
- Đảm bảo Inno Setup đã được cài đặt
- Khởi động lại terminal sau khi cài đặt
- Kiểm tra PATH có chứa: `C:\Program Files (x86)\Inno Setup 6`

### Lỗi Flutter build
- Chạy `flutter doctor` để kiểm tra
- Đảm bảo Windows build tools đã cài đặt

### Lỗi thiếu file
- Kiểm tra file `assets\TremoSoundFont.sf2` tồn tại
- Đảm bảo Flutter build thành công

## Tính năng Installer

✅ **Tự động cài đặt**: Tất cả dependencies được cài đặt tự động
✅ **Shortcuts**: Tạo icon trên Desktop và Start Menu  
✅ **Gỡ cài đặt**: Hỗ trợ gỡ cài đặt hoàn toàn
✅ **Không cần Admin**: Không yêu cầu quyền Administrator
✅ **Đa ngôn ngữ**: Hỗ trợ tiếng Việt và tiếng Anh
✅ **Tự động chạy**: Chạy ứng dụng sau khi cài đặt 