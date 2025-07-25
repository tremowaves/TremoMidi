# TremoMIDI - MIDI Generator

Một ứng dụng Flutter để tạo file MIDI từ text input đơn giản.

## Tính năng

- **Text-to-MIDI**: Chuyển đổi text notation thành file MIDI
- **Multiple Instruments**: Hỗ trợ nhiều nhạc cụ khác nhau
- **Tempo Control**: Điều chỉnh tempo cho từng track
- **Real-time Generation**: Tạo MIDI file ngay lập tức
- **Audio Playback**: Phát âm thanh trực tiếp từ synthesizer
- **File Export**: Lưu file MIDI với tên tự động

## Cách sử dụng

### Cú pháp Text Notation

```
tempo: 120
instrument: Acoustic Grand Piano

C4 100 0.5
D4 100 0.5
E4 100 0.5
F4 100 0.5
G4 100 1.0
G4 100 1.0
A4 100 0.5
A4 100 0.5
A4 100 0.5
A4 100 0.5
G4 100 2.0
```

### Format

- `tempo: [BPM]` - Đặt tempo cho track
- `instrument: [Tên nhạc cụ]` - Chọn nhạc cụ
- `[Note] [Velocity] [Duration]` - Định nghĩa note

### Notes

- **Note Names**: C, C#, Db, D, D#, Eb, E, F, F#, Gb, G, G#, Ab, A, A#, Bb, B
- **Octaves**: 0-9 (ví dụ: C4, A5)
- **Velocity**: 0-127 (độ mạnh của note)
- **Duration**: Thời gian phát note (giây)

### Nhạc cụ hỗ trợ

- Piano: Acoustic Grand Piano, Bright Acoustic Piano, Electric Grand Piano
- Strings: Violin, Viola, Cello, Double Bass
- Brass: Trumpet, Trombone, Tuba, French Horn
- Woodwinds: Flute, Clarinet, Saxophone
- Và nhiều nhạc cụ khác...

## Cài đặt

1. Clone repository
2. Chạy `flutter pub get`
3. Chạy `flutter run`

## Build

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Dependencies

- `dart_melty_soundfont`: Xử lý SoundFont và MIDI synthesis
- `audioplayers`: Audio playback functionality
- `file_saver`: Lưu file MIDI
- `flutter`: UI framework

## Cấu trúc Project

```
lib/
├── main.dart          # Main application
├── models/            # Data models
└── utils/             # Utility functions
```

## Lưu ý

- Ứng dụng sử dụng TremoSoundFont.sf2 cho âm thanh
- File MIDI được tạo theo chuẩn Standard MIDI Files (SMF)
- Hỗ trợ format 1 MIDI với multiple tracks
- Audio playback sử dụng dart_melty_soundfont synthesizer
- Hỗ trợ real-time MIDI playback với synthesizer

## License

MIT License
