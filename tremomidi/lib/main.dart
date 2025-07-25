import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

// Main App Entry Point
void main() {
  runApp(const MIDIGeneratorApp());
}

class MIDIGeneratorApp extends StatelessWidget {
  const MIDIGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0A84FF),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0A84FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'MIDI Generator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: lightScheme.primary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
      ),
      themeMode: ThemeMode.system,
      home: const MIDIGeneratorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Home Page Widget
class MIDIGeneratorHome extends StatefulWidget {
  const MIDIGeneratorHome({super.key});

  @override
  _MIDIGeneratorHomeState createState() => _MIDIGeneratorHomeState();
}

class _MIDIGeneratorHomeState extends State<MIDIGeneratorHome>
    with TickerProviderStateMixin {
  late final TextEditingController _textController;
  final ScrollController _logController = ScrollController();

  List<String> _logs = [];
  bool _isGenerating = false;
  bool _isPlaying = false;
  bool _soundFontLoaded = false;

  late final AnimationController _playButtonController;
  late final AnimationController _generateButtonController;

  // Audio Engine
  late SynthesizerSettings _synthesizerSettings;
  Synthesizer? _synthesizer;
  MidiFileSequencer? _sequencer;

  // MIDI Data
  MIDIData? _currentMidiData;
  Uint8List? _midiBytes;

  // Audio Player
  Timer? _audioLoop;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();

    FlutterPcmSound.init(
      sampleRate: 44100,
      channel: PcmChannel.stereo,
      bitDepth: PcmBitDepth.int16,
    );

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _generateButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _textController.text = '''tempo: 120
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
G4 100 2.0''';

    _loadSoundFont();
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _generateButtonController.dispose();
    _textController.dispose();
    _logController.dispose();
    _audioLoop?.cancel();
    FlutterPcmSound.release();
    super.dispose();
  }

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logs.add('$timestamp - $message');
      print('$timestamp - $message');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadSoundFont() async {
    _addLog('Loading SoundFont...');
    try {
      final bytes = await rootBundle.load('assets/TremoSoundFont.sf2');
      _synthesizerSettings = SynthesizerSettings(
        sampleRate: 44100,
        maximumPolyphony: 128,
        blockSize: 64,
      );
      final synthesizer = Synthesizer.loadByteData(
        bytes,
        _synthesizerSettings,
      );
      setState(() {
        _synthesizer = synthesizer;
        _soundFontLoaded = true;
      });
      _addLog('SoundFont loaded successfully.');
    } catch (e) {
      _addLog('Error loading SoundFont: $e');
    }
  }

  Future<void> _generateMIDI() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);
    _generateButtonController.forward().then((_) => _generateButtonController.reverse());
    _addLog('Parsing text input...');

    try {
      final parser = MIDITextParser();
      final midiData = parser.parse(_textController.text);
      await Future.delayed(const Duration(milliseconds: 300));

      _addLog('Successfully parsed:');
      _addLog('  Tempo: ${midiData.tempo} BPM');
      _addLog('  Instruments: ${midiData.tracks.length}');
      _addLog('  Total notes: ${midiData.tracks.fold(0, (sum, track) => sum + track.notes.length)}');

      final midiGenerator = MIDIFileGenerator();
      final midiBytes = midiGenerator.generate(midiData);
      _addLog('MIDI file generated (${midiBytes.length} bytes)');

      setState(() {
        _currentMidiData = midiData;
        _midiBytes = midiBytes;
      });
    } on FormatException catch (e) {
      _addLog('Error parsing input: ${e.message}');
    } catch (e) {
      _addLog('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveMIDI() async {
    if (_midiBytes == null) {
      _addLog('No MIDI data to save. Please generate first.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate MIDI before saving!')),
      );
      return;
    }

    try {
      final fileName = 'midi_${DateTime.now().toIso8601String().replaceAll(':', '-')}';
      final path = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: _midiBytes,
        ext: 'mid',
        mimeType: MimeType.other,
      );
      _addLog('Saved $fileName at $path');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully saved to $path')),
      );
    } catch (e) {
      _addLog('Error saving file: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (_synthesizer == null || _midiBytes == null) {
      _addLog('Please load SoundFont and generate MIDI first.');
      return;
    }

    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (_synthesizer == null || _midiBytes == null || !mounted) return;

    setState(() => _isPlaying = true);
    _playButtonController.forward();
    _addLog('Starting playback...');

    _sequencer = MidiFileSequencer(_synthesizer!);
    final byteData = _midiBytes!.buffer.asByteData(_midiBytes!.offsetInBytes, _midiBytes!.lengthInBytes);
    final midiFile = MidiFile.fromByteData(byteData);
    _sequencer!.play(midiFile, loop: false);

    FlutterPcmSound.play();

    final left = Float32List(_synthesizerSettings.blockSize);
    final right = Float32List(_synthesizerSettings.blockSize);
    final interleaved = Int16List(_synthesizerSettings.blockSize * 2);

    _audioLoop = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _synthesizer!.render(left, right);
      for (var i = 0; i < _synthesizerSettings.blockSize; i++) {
        interleaved[i * 2] = (left[i] * 32767).toInt();
        interleaved[i * 2 + 1] = (right[i] * 32767).toInt();
      }
      FlutterPcmSound.feed(PcmArrayInt16.fromInt16List(interleaved));
    });

    final duration = _calculatePlaybackDuration(_currentMidiData!);
    Future.delayed(Duration(milliseconds: duration), () {
      if (mounted && _isPlaying) {
        _stopPlayback(isFinished: true);
      }
    });
  }

  void _stopPlayback({bool isFinished = false}) {
    if (!mounted) return;
    _audioLoop?.cancel();
    FlutterPcmSound.stop();
    _sequencer?.stop();
    setState(() => _isPlaying = false);
    _playButtonController.reverse();
    if (isFinished) {
      _addLog('Playback finished.');
    } else {
      _addLog('Playback stopped by user.');
    }
  }

  int _calculatePlaybackDuration(MIDIData midiData) {
    double totalDurationSeconds = 0;
    for (final track in midiData.tracks) {
      double trackDuration = 0;
      for (final note in track.notes) {
        trackDuration += note.duration;
      }
      if (trackDuration > totalDurationSeconds) {
        totalDurationSeconds = trackDuration;
      }
    }
    // Add a small buffer
    return (totalDurationSeconds * 1000).toInt() + 500;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Custom Title Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              children: [
                Text('MIDI Generator', style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  avatar: Icon(
                    _soundFontLoaded ? Icons.check_circle : Icons.hourglass_empty,
                    color: _soundFontLoaded ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  label: Text(_soundFontLoaded ? 'SoundFont Ready' : 'Loading...'),
                  backgroundColor: colorScheme.surfaceVariant,
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Editor
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    elevation: 0,
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.music_note_2, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Musical Score', style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(fontFamily: 'SF Mono', fontSize: 14, height: 1.4),
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              FilledButton.icon(
                                onPressed: _isGenerating ? null : _generateMIDI,
                                icon: _isGenerating
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(CupertinoIcons.waveform),
                                label: Text(_isGenerating ? 'Generating...' : 'Generate MIDI'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: _togglePlayback,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isPlaying ? colorScheme.error : colorScheme.primary,
                                  foregroundColor: _isPlaying ? colorScheme.onError : colorScheme.onPrimary,
                                ),
                                icon: Icon(_isPlaying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill),
                                label: Text(_isPlaying ? 'Stop' : 'Play'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(
                                onPressed: _saveMIDI,
                                icon: const Icon(CupertinoIcons.cloud_download_fill),
                                label: const Text('Save'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Panel - Log
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                    elevation: 0,
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.list_bullet, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Generation Log', style: theme.textTheme.titleMedium),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(CupertinoIcons.clear, size: 16),
                                onPressed: () => setState(() => _logs.clear()),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.separated(
                              controller: _logController,
                              itemCount: _logs.length,
                              separatorBuilder: (_, __) => Divider(color: colorScheme.outline.withOpacity(0.12)),
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final isError = log.contains('Error:');
                                return Text(
                                  log,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'SF Mono',
                                    color: isError ? colorScheme.error : colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Data Models and Parsers (Largely Unchanged) ---

class MIDIData {
  final int tempo;
  final List<MIDITrack> tracks;
  MIDIData({required this.tempo, required this.tracks});
}

class MIDITrack {
  final String instrument;
  final int program;
  final List<MIDINote> notes;
  MIDITrack({required this.instrument, required this.program, required this.notes});
}

class MIDINote {
  final int pitch;
  final int velocity;
  final double duration; // in seconds
  MIDINote({required this.pitch, required this.velocity, required this.duration});
}

class MIDITextParser {
  static const Map<String, int> noteMap = {
    'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5, 'F#': 6,
    'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
  };
  static const Map<String, int> instrumentMap = {
    'Acoustic Grand Piano': 0, 'Bright Acoustic Piano': 1, 'Electric Grand Piano': 2,
    'Honky-tonk Piano': 3, 'Electric Piano 1': 4, 'Electric Piano 2': 5, 'Harpsichord': 6,
    'Clavi': 7, 'Celesta': 8, 'Glockenspiel': 9, 'Music Box': 10, 'Vibraphone': 11,
    'Marimba': 12, 'Xylophone': 13, 'Tubular Bells': 14, 'Dulcimer': 15, 'Violin': 40,
    'Viola': 41, 'Cello': 42, 'Double Bass': 43, 'Trumpet': 56, 'Trombone': 57,
    'Tuba': 58, 'French Horn': 60, 'Flute': 73, 'Clarinet': 71, 'Saxophone': 64,
  };

  MIDIData parse(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    int tempo = 120;
    Map<String, List<MIDINote>> instrumentNotes = {};
    String currentInstrument = 'Acoustic Grand Piano';

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('tempo:')) {
        tempo = int.tryParse(trimmed.substring(6).trim()) ?? 120;
      } else if (trimmed.startsWith('instrument:')) {
        currentInstrument = trimmed.substring(11).trim();
        instrumentNotes.putIfAbsent(currentInstrument, () => []);
      } else {
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          try {
            final pitch = _parseNoteName(parts[0]);
            final velocity = int.parse(parts[1]);
            final duration = double.parse(parts[2]);
            instrumentNotes.putIfAbsent(currentInstrument, () => []);
            instrumentNotes[currentInstrument]!.add(
              MIDINote(pitch: pitch, velocity: velocity, duration: duration),
            );
          } catch (e) {
            throw FormatException('Invalid note line: "$trimmed" ($e)');
          }
        }
      }
    }

    final tracks = instrumentNotes.entries.map((entry) {
      final program = instrumentMap[entry.key] ?? 0;
      return MIDITrack(instrument: entry.key, program: program, notes: entry.value);
    }).toList();

    return MIDIData(tempo: tempo, tracks: tracks);
  }

  int _parseNoteName(String noteName) {
    final match = RegExp(r'^([A-G][#b]?)(\d+)$').firstMatch(noteName);
    if (match == null) throw FormatException('Invalid note name: $noteName');
    final noteBase = match.group(1)!;
    final octave = int.parse(match.group(2)!);
    final noteValue = noteMap[noteBase];
    if (noteValue == null) throw FormatException('Invalid note: $noteBase');
    return (octave + 1) * 12 + noteValue;
  }
}

class MIDIFileGenerator {
  Uint8List generate(MIDIData midiData) {
    final writer = MidiWriter(ticksPerBeat: 480);
    writer.addTempo(midiData.tempo);

    for (int i = 0; i < midiData.tracks.length; i++) {
      final track = midiData.tracks[i];
      writer.addTrack();
      writer.addProgramChange(channel: i, program: track.program);
      
      int absoluteTicks = 0;
      for (final note in track.notes) {
        final durationInTicks = (note.duration * writer.ticksPerBeat * (midiData.tempo / 60.0)).round();
        writer.addNote(
          channel: i,
          pitch: note.pitch,
          velocity: note.velocity,
          startTicks: absoluteTicks,
          endTicks: absoluteTicks + durationInTicks,
        );
        absoluteTicks += durationInTicks;
      }
    }
    return writer.build();
  }
}

// A simple MIDI writer class to generate Standard MIDI Files (SMF).
class MidiWriter {
  final int ticksPerBeat;
  final List<MidiTrackWriter> _tracks = [];
  int _tempo = 120;

  MidiWriter({this.ticksPerBeat = 480});

  void addTempo(int tempo) {
    _tempo = tempo;
  }

  void addTrack() {
    _tracks.add(MidiTrackWriter());
  }

  void addProgramChange({required int channel, required int program}) {
    if (_tracks.isEmpty) addTrack();
    _tracks.last.addProgramChange(channel: channel, program: program);
  }

  void addNote({
    required int channel,
    required int pitch,
    required int velocity,
    required int startTicks,
    required int endTicks,
  }) {
    if (_tracks.isEmpty) addTrack();
    _tracks.last.addNote(
      channel: channel,
      pitch: pitch,
      velocity: velocity,
      startTicks: startTicks,
      endTicks: endTicks,
    );
  }

  Uint8List build() {
    final builder = BytesBuilder();

    // Header chunk
    builder.add('MThd'.codeUnits);
    builder.add(_int32(6)); // chunk length
    builder.add(_int16(1)); // format 1
    builder.add(_int16(_tracks.length + 1)); // number of tracks
    builder.add(_int16(ticksPerBeat));

    // Tempo track
    final tempoTrack = MidiTrackWriter();
    tempoTrack.addTempo(_tempo);
    final tempoTrackBytes = tempoTrack.build();
    builder.add('MTrk'.codeUnits);
    builder.add(_int32(tempoTrackBytes.length));
    builder.add(tempoTrackBytes);

    // Note tracks
    for (final track in _tracks) {
      final trackBytes = track.build();
      builder.add('MTrk'.codeUnits);
      builder.add(_int32(trackBytes.length));
      builder.add(trackBytes);
    }

    return builder.toBytes();
  }

  static Uint8List _int16(int value) =>
      Uint8List(2)..buffer.asByteData().setInt16(0, value);
  static Uint8List _int32(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value);
}

class MidiTrackWriter {
  final List<_MidiEvent> _events = [];
  int _lastTicks = 0;

  void addTempo(int tempo) {
    final microsecondsPerBeat = 60000000 ~/ tempo;
    final tempoBytes = Uint8List(3)
      ..[0] = (microsecondsPerBeat >> 16) & 0xFF
      ..[1] = (microsecondsPerBeat >> 8) & 0xFF
      ..[2] = microsecondsPerBeat & 0xFF;
    _events.add(_MidiEvent(0, 0xFF, [0x51, 0x03, ...tempoBytes]));
  }

  void addProgramChange({required int channel, required int program}) {
    _events.add(_MidiEvent(_lastTicks, 0xC0 | channel, [program]));
  }

  void addNote({
    required int channel,
    required int pitch,
    required int velocity,
    required int startTicks,
    required int endTicks,
  }) {
    _events.add(_MidiEvent(startTicks, 0x90 | channel, [pitch, velocity]));
    _events.add(_MidiEvent(endTicks, 0x80 | channel, [pitch, 0]));
  }

  Uint8List build() {
    _events.sort((a, b) => a.ticks.compareTo(b.ticks));

    final builder = BytesBuilder();
    int lastTicks = 0;

    for (final event in _events) {
      final deltaTicks = event.ticks - lastTicks;
      builder.add(_writeVarInt(deltaTicks));
      builder.addByte(event.status);
      builder.add(event.data);
      lastTicks = event.ticks;
    }

    // End of track event
    builder.add(_writeVarInt(0));
    builder.add([0xFF, 0x2F, 0x00]);

    return builder.toBytes();
  }

  static Uint8List _writeVarInt(int value) {
    if (value < 0x80) return Uint8List.fromList([value]);

    final buffer = <int>[];
    buffer.add(value & 0x7F);
    value >>= 7;
    while (value > 0) {
      buffer.add(0x80 | (value & 0x7F));
      value >>= 7;
    }
    return Uint8List.fromList(buffer.reversed.toList());
  }
}

class _MidiEvent {
  final int ticks;
  final int status;
  final List<int> data;
  _MidiEvent(this.ticks, this.status, this.data);
}
</final_file_content>

IMPORTANT: For any future changes to this file, use the final_file_content shown above as your reference. This content reflects the current state of the file, including any auto-formatting (e.g., if you used single quotes but the formatter converted them to double quotes). Always base your SEARCH/REPLACE operations on this final version to ensure accuracy.

<environment_details>
# VSCode Visible Files
tremomidi/lib/main.dart

# VSCode Open Tabs
.gitignore
tremomidi/lib/main.dart
tremomidi/assets/TremoSoundFont.sf2

# Current Time
7/25/2025, 4:58:13 PM (Asia/Bangkok, UTC+7:00)

# Context Window Usage
190,784 / 1,048.576K tokens used (18%)

# Current Mode
ACT MODE
</environment_details>
