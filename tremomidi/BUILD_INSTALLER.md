# Hướng dẫn Build Installer cho TremoMidi

## Yêu cầu

1. **Inno Setup**: Tải và cài đặt từ [https://jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php)
2. **Flutter SDK**: Đã cài đặt và cấu hình
3. **Windows Build Tools**: Đã cài đặt

## Cách Build Installer

### Phương pháp 1: Sử dụng batch file (Khuyến nghị)

1. Mở Command Prompt hoặc PowerShell
2. Di chuyển đến thư mục dự án: `cd path\to\tremomidi`
3. Chạy lệnh:
   ```cmd
   build_installer.bat
   ```

### Phương pháp 2: Build thủ công

1. Build ứng dụng Flutter:
   ```cmd
   flutter build windows --release
   ```

2. Build installer với Inno Setup:
   ```cmd
   iscc setup.iss
   ```

## Kết quả

Sau khi build thành công, file installer sẽ được tạo tại:
```
installer\TremoMidi-Setup.exe
```

## Cấu hình Installer

File `setup.iss` chứa các cấu hình:

- **AppName**: Tên ứng dụng (TremoMidi)
- **AppVersion**: Phiên bản (1.0.0)
- **DefaultDirName**: Thư mục cài đặt mặc định
- **OutputBaseFilename**: Tên file installer
- **SetupIconFile**: Icon cho installer
- **Compression**: Nén LZMA để giảm kích thước

## Tính năng Installer

- ✅ Cài đặt tự động tất cả dependencies
- ✅ Tạo shortcut trên Desktop và Start Menu
- ✅ Hỗ trợ gỡ cài đặt hoàn toàn
- ✅ Không yêu cầu quyền Administrator
- ✅ Hỗ trợ tiếng Việt và tiếng Anh
- ✅ Tự động chạy ứng dụng sau khi cài đặt

## Troubleshooting

### Lỗi "iscc not found"
- Đảm bảo Inno Setup đã được cài đặt
- Thêm đường dẫn Inno Setup vào PATH:
  ```
  C:\Program Files (x86)\Inno Setup 6
  ```

### Lỗi Flutter build
- Kiểm tra Flutter SDK đã được cài đặt đúng
- Chạy `flutter doctor` để kiểm tra

### Lỗi thiếu file
- Đảm bảo file `assets\TremoSoundFont.sf2` tồn tại
- Kiểm tra build Flutter đã thành công

## Tùy chỉnh

Để thay đổi cấu hình installer, chỉnh sửa file `setup.iss`:

- Thay đổi `AppName` để đổi tên ứng dụng
- Thay đổi `AppVersion` để cập nhật phiên bản
- Thêm file mới vào section `[Files]`
- Tùy chỉnh giao diện installer 