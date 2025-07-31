# Files đã tạo cho Installer

## Files chính

### 1. `setup.iss`
- File cấu hình chính cho Inno Setup
- Chứa thông tin ứng dụng, đường dẫn, và cài đặt installer
- Hỗ trợ đa ngôn ngữ (tiếng Việt + tiếng Anh)

### 2. `build_installer_simple.ps1`
- Script PowerShell để build installer tự động
- Kiểm tra Inno Setup, build Flutter app, và tạo installer
- Hiển thị thông tin chi tiết về quá trình build

### 3. `build_installer.bat`
- Script batch để build installer
- Tương thích với Command Prompt

### 4. `install_innosetup.ps1`
- Script để tải và cài đặt Inno Setup tự động
- Thêm Inno Setup vào PATH

## Files hướng dẫn

### 5. `QUICK_BUILD.md`
- Hướng dẫn nhanh để build installer
- Troubleshooting cho các lỗi thường gặp

### 6. `BUILD_INSTALLER.md`
- Hướng dẫn chi tiết về cấu hình installer
- Tùy chỉnh và troubleshooting nâng cao

### 7. `LICENSE`
- File license MIT cho ứng dụng

## Cấu trúc thư mục

```
tremomidi/
├── setup.iss                    # Cấu hình Inno Setup
├── build_installer_simple.ps1   # Script PowerShell chính
├── build_installer.bat          # Script batch
├── install_innosetup.ps1        # Script cài đặt Inno Setup
├── QUICK_BUILD.md              # Hướng dẫn nhanh
├── BUILD_INSTALLER.md          # Hướng dẫn chi tiết
├── LICENSE                     # File license
├── installer/                  # Thư mục chứa installer
└── build/                     # Thư mục build Flutter
    └── windows/x64/runner/Release/
        └── tremomidi.exe      # File exe chính
```

## Cách sử dụng

1. **Cài đặt Inno Setup** từ https://jrsoftware.org/isinfo.php
2. **Chạy script build**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File build_installer_simple.ps1
   ```
3. **Kết quả**: File `installer\TremoMidi-Setup.exe` sẽ được tạo

## Tính năng Installer

- ✅ Tự động cài đặt tất cả dependencies
- ✅ Tạo shortcuts trên Desktop và Start Menu
- ✅ Hỗ trợ gỡ cài đặt hoàn toàn
- ✅ Không yêu cầu quyền Administrator
- ✅ Hỗ trợ tiếng Việt và tiếng Anh
- ✅ Tự động chạy ứng dụng sau khi cài đặt
- ✅ Nén LZMA để giảm kích thước file 