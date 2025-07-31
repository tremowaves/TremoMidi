# TremoMidi - MIDI Generator & Player

Ứng dụng Flutter để tạo và phát nhạc MIDI từ văn bản.

## Tính năng

- **Text to MIDI**: Chuyển đổi văn bản thành file MIDI
- **MIDI Playback**: Phát âm thanh trực tiếp từ synthesizer
- **MIDI Import**: Import file MIDI và chuyển đổi thành văn bản có thể chỉnh sửa
- **SoundFont Support**: Sử dụng SoundFont để tạo âm thanh chất lượng cao
- **Cross-platform**: Hoạt động trên Windows, macOS, Linux, Android, iOS

## Cách sử dụng

### Tạo MIDI từ văn bản

1. Nhập văn bản theo định dạng:
```
tempo: 120

instrument: Acoustic Grand Piano

C4 96 1.0
D4 96 1.0
E4 96 1.0
F4 96 1.0
G4 96 2.0
```

2. Nhấn "Generate MIDI" để tạo file MIDI
3. Nhấn "Play" để phát âm thanh

### Import MIDI file

1. Nhấn "Import MIDI" để chọn file MIDI (.mid hoặc .midi)
2. Ứng dụng sẽ tự động chuyển đổi MIDI thành văn bản
3. Chỉnh sửa văn bản và tạo lại MIDI nếu cần

### Định dạng văn bản

- `tempo: [số]` - Tốc độ (BPM)
- `instrument: [tên nhạc cụ]` - Nhạc cụ cho track
- `[note] [velocity] [duration]` - Nốt nhạc
  - `note`: Tên nốt (C4, D#5, etc.)
  - `velocity`: Độ mạnh (0-127)
  - `duration`: Thời gian (giây)

## Dependencies

- `dart_melty_soundfont`: SoundFont synthesizer
- `audioplayers`: Audio playback
- `file_saver`: Save MIDI files
- `file_picker`: Import MIDI files

## Cài đặt

### Windows Installer

1. Tải file `TremoMidi_Setup.exe` từ thư mục `installer/`
2. Chạy installer và làm theo hướng dẫn
3. Ứng dụng sẽ được cài đặt với SoundFont

### Build từ source

```bash
flutter pub get
flutter build windows --release
```

## Ghi chú

- Âm thanh được tạo từ SoundFont `TremoSoundFont.sf2`
- Hỗ trợ import MIDI với parsing chính xác
- Tự động cleanup file tạm thời
- Giao diện Material Design 3

## MIDI Import Features

Ứng dụng sử dụng `MIDIToTextConverter` để parse MIDI files với:

- **Comprehensive MIDI Parsing**: Hỗ trợ đầy đủ MIDI format
- **Variable Length Quantity**: Xử lý chính xác timing
- **Tempo Extraction**: Trích xuất tempo từ MIDI
- **Instrument Mapping**: 128 General MIDI instruments
- **Note Tracking**: Theo dõi note on/off events
- **Multi-track Support**: Hỗ trợ nhiều track

## License

MIT License - Xem file LICENSE để biết thêm chi tiết.
