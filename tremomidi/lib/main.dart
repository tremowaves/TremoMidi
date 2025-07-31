import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_saver/file_saver.dart';

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

  final List<String> _logs = [];
  bool _isGenerating = false;
  bool _soundFontLoaded = false;
  bool _isPlaying = false;

  late final AnimationController _generateButtonController;
  late final AnimationController _playButtonController;

  // Audio Engine
  late SynthesizerSettings _synthesizerSettings;
  Synthesizer? _synthesizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _audioTimer;
  final List<Int16List> _audioBuffer = [];
  String? _currentAudioFile;

  // MIDI Data
  MIDIData? _currentMidiData;
  Uint8List? _midiBytes;

  // Playback control
  Timer? _playbackTimer;
  int _currentNoteIndex = 0;
  final List<PlaybackNote> _playbackNotes = [];

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();

    _generateButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _playButtonController = AnimationController(
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
    _stopPlayback();
    _audioTimer?.cancel();
    _audioPlayer.dispose();
    _generateButtonController.dispose();
    _playButtonController.dispose();
    _textController.dispose();
    _logController.dispose();
    
    // Cleanup audio files
    _cleanupAudioFiles();

    super.dispose();
  }

  void _cleanupAudioFiles() {
    try {
      final directory = Directory.current;
      final files = directory.listSync();
      for (final file in files) {
        if (file is File && file.path.contains('temp_audio_') && file.path.endsWith('.wav')) {
          file.deleteSync();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
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
      
      // Initialize audio stream for playback
      _initializeAudioStream();
    } catch (e) {
      _addLog('Error loading SoundFont: $e');
    }
  }

  void _initializeAudioStream() {
    if (_synthesizer == null) return;
    
    // Initialize audio player for real-time playback
    try {
      _audioBuffer.clear();
      _addLog('Audio stream initialized with audioplayers');
    } catch (e) {
      _addLog('Error initializing audio stream: $e');
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

      // Prepare playback notes
      _preparePlaybackNotes(midiData);

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

  void _preparePlaybackNotes(MIDIData midiData) {
    _playbackNotes.clear();

    
    for (int trackIndex = 0; trackIndex < midiData.tracks.length; trackIndex++) {
      final track = midiData.tracks[trackIndex];
      double trackTime = 0.0;
      
      for (final note in track.notes) {
        _playbackNotes.add(PlaybackNote(
          time: trackTime,
          pitch: note.pitch,
          velocity: note.velocity,
          duration: note.duration,
          channel: trackIndex,
          program: track.program,
          isNoteOn: true,
        ));
        
        _playbackNotes.add(PlaybackNote(
          time: trackTime + note.duration,
          pitch: note.pitch,
          velocity: 0,
          duration: 0,
          channel: trackIndex,
          program: track.program,
          isNoteOn: false,
        ));
        
        trackTime += note.duration;
      }
    }
    
    // Sort by time
    _playbackNotes.sort((a, b) => a.time.compareTo(b.time));
    _addLog('Prepared ${_playbackNotes.length} playback events');
  }

  Future<void> _playMIDI() async {
    if (_synthesizer == null || _currentMidiData == null) {
      _addLog('No synthesizer or MIDI data available');
      return;
    }

    if (_isPlaying) {
      _stopPlayback();
      return;
    }

    setState(() => _isPlaying = true);
    _playButtonController.forward();
    _addLog('Starting playback...');
    
    _currentNoteIndex = 0;
    
    // Set up instruments for each channel
    for (int i = 0; i < _currentMidiData!.tracks.length; i++) {
      final track = _currentMidiData!.tracks[i];
      _synthesizer!.selectPreset(channel: i, preset: track.program);
    }
    
    // Start audio playback with synthesizer
    try {
      // Generate audio file for playback
      await _generateAudioFile();
      
      // Play the generated audio file
      if (_currentAudioFile != null) {
        await _audioPlayer.play(DeviceFileSource(_currentAudioFile!));
      }
      _addLog('Audio playback started');
      
      // Set up audio timer to generate samples
      _audioTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (_synthesizer != null && _isPlaying) {
          // Create PCM buffer for audio output
          final buffer = ArrayInt16.zeros(numShorts: 512);
          _synthesizer!.renderMonoInt16(buffer);
          // Store samples for continuous playback
          final samples = Int16List(512);
          for (int i = 0; i < 512; i++) {
            samples[i] = buffer[i];
          }
          _audioBuffer.add(samples);
        }
      });
    } catch (e) {
      _addLog('Error starting audio playback: $e');
      _stopPlayback();
      return;
    }
    
    final startTime = DateTime.now();
    
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!_isPlaying || _currentNoteIndex >= _playbackNotes.length) {
        _stopPlayback();
        return;
      }
      
      final elapsedSeconds = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      while (_currentNoteIndex < _playbackNotes.length && 
             _playbackNotes[_currentNoteIndex].time <= elapsedSeconds) {
        
        final note = _playbackNotes[_currentNoteIndex];
        
        if (note.isNoteOn) {
          // Note On
          _synthesizer!.noteOn(
            channel: note.channel,
            key: note.pitch,
            velocity: note.velocity,
          );
          _addLog('Note ON: ${_pitchToNoteName(note.pitch)} (Ch${note.channel})');
        } else {
          // Note Off
          _synthesizer!.noteOff(
            channel: note.channel,
            key: note.pitch,
          );
        }
        
        _currentNoteIndex++;
      }
    });
  }

  void _stopPlayback() {
    if (_playbackTimer != null) {
      _playbackTimer!.cancel();
      _playbackTimer = null;
    }
    
    if (_audioTimer != null) {
      _audioTimer!.cancel();
      _audioTimer = null;
    }
    
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      _playButtonController.reverse();
      _addLog('Playback stopped');
      
      // Stop audio player
      _audioPlayer.stop();
      
      // Stop all notes
      if (_synthesizer != null) {
        for (int channel = 0; channel < 16; channel++) {
          for (int note = 0; note < 128; note++) {
            _synthesizer!.noteOff(
              channel: channel,
              key: note,
            );
          }
        }
      }
    }
  }

  String _pitchToNoteName(int pitch) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (pitch ~/ 12) - 1;
    final noteName = noteNames[pitch % 12];
    return '$noteName$octave';
  }

  Future<void> _generateAudioFile() async {
    if (_synthesizer == null || _currentMidiData == null) return;
    
    try {
      // Calculate total duration
      double totalDuration = 0;
      for (final track in _currentMidiData!.tracks) {
        double trackDuration = 0;
        for (final note in track.notes) {
          trackDuration += note.duration;
        }
        if (trackDuration > totalDuration) {
          totalDuration = trackDuration;
        }
      }
      
      // Generate audio for the entire duration
      final sampleRate = 44100;
      final totalSamples = (totalDuration * sampleRate).round();
      final buffer = ArrayInt16.zeros(numShorts: totalSamples);
      
      // Set up instruments
      for (int i = 0; i < _currentMidiData!.tracks.length; i++) {
        final track = _currentMidiData!.tracks[i];
        _synthesizer!.selectPreset(channel: i, preset: track.program);
      }
      
      // Create timeline of events
      final events = <TimelineEvent>[];
      
      for (int trackIndex = 0; trackIndex < _currentMidiData!.tracks.length; trackIndex++) {
        final track = _currentMidiData!.tracks[trackIndex];
        double trackTime = 0;
        
        for (final note in track.notes) {
          // Note On event
          events.add(TimelineEvent(
            time: trackTime,
            type: EventType.noteOn,
            channel: trackIndex,
            pitch: note.pitch,
            velocity: note.velocity,
          ));
          
          // Note Off event
          events.add(TimelineEvent(
            time: trackTime + note.duration,
            type: EventType.noteOff,
            channel: trackIndex,
            pitch: note.pitch,
            velocity: 0,
          ));
          
          trackTime += note.duration;
        }
      }
      
      // Sort events by time
      events.sort((a, b) => a.time.compareTo(b.time));
      
      // Render audio with proper timing
      int currentSample = 0;
      int eventIndex = 0;
      final samplesPerBlock = 512;
      
      while (currentSample < totalSamples) {
        final blockEndSample = (currentSample + samplesPerBlock).clamp(0, totalSamples);
        final blockSamples = blockEndSample - currentSample;
        final blockBuffer = ArrayInt16.zeros(numShorts: blockSamples);
        
        // Process events that should happen in this block
        final currentTime = currentSample / sampleRate;
        final blockEndTime = blockEndSample / sampleRate;
        
        while (eventIndex < events.length && events[eventIndex].time < blockEndTime) {
          final event = events[eventIndex];
          if (event.time >= currentTime) {
            if (event.type == EventType.noteOn) {
              _synthesizer!.noteOn(
                channel: event.channel,
                key: event.pitch,
                velocity: event.velocity,
              );
            } else if (event.type == EventType.noteOff) {
              _synthesizer!.noteOff(
                channel: event.channel,
                key: event.pitch,
              );
            }
          }
          eventIndex++;
        }
        
        // Render this block
        _synthesizer!.renderMonoInt16(blockBuffer);
        
        // Copy to main buffer
        for (int i = 0; i < blockSamples; i++) {
          buffer[currentSample + i] = blockBuffer[i];
        }
        
        currentSample = blockEndSample;
      }
      
      // Save to WAV file with unique name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'temp_audio_$timestamp.wav';
      final file = File(fileName);
      await file.writeAsBytes(_createWavHeader(sampleRate, totalSamples) + 
                             _arrayInt16ToBytes(buffer, totalSamples));
      
      _currentAudioFile = fileName;
      _addLog('Generated audio file: ${file.lengthSync()} bytes');
    } catch (e) {
      _addLog('Error generating audio file: $e');
    }
  }

  List<int> _createWavHeader(int sampleRate, int numSamples) {
    final header = <int>[];
    
    // RIFF header
    header.addAll('RIFF'.codeUnits);
    header.addAll([36 + numSamples * 2, 0, 0, 0]); // File size
    header.addAll('WAVE'.codeUnits);
    
    // fmt chunk
    header.addAll('fmt '.codeUnits);
    header.addAll([16, 0, 0, 0]); // Chunk size
    header.addAll([1, 0]); // Audio format (PCM)
    header.addAll([1, 0]); // Channels (mono)
    header.addAll([sampleRate & 0xFF, (sampleRate >> 8) & 0xFF, (sampleRate >> 16) & 0xFF, (sampleRate >> 24) & 0xFF]); // Sample rate
    header.addAll([sampleRate * 2 & 0xFF, (sampleRate * 2 >> 8) & 0xFF, (sampleRate * 2 >> 16) & 0xFF, (sampleRate * 2 >> 24) & 0xFF]); // Byte rate
    header.addAll([2, 0]); // Block align
    header.addAll([16, 0]); // Bits per sample
    
    // data chunk
    header.addAll('data'.codeUnits);
    header.addAll([numSamples * 2 & 0xFF, (numSamples * 2 >> 8) & 0xFF, (numSamples * 2 >> 16) & 0xFF, (numSamples * 2 >> 24) & 0xFF]); // Data size
    
    return header;
  }

  List<int> _arrayInt16ToBytes(ArrayInt16 array, int length) {
    final bytes = <int>[];
    for (int i = 0; i < length; i++) {
      final value = array[i];
      bytes.add(value & 0xFF);
      bytes.add((value >> 8) & 0xFF);
    }
    return bytes;
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
                                onPressed: (_currentMidiData == null || !_soundFontLoaded) ? null : _playMIDI,
                                icon: _isPlaying 
                                    ? const Icon(CupertinoIcons.stop_fill)
                                    : const Icon(CupertinoIcons.play_fill),
                                label: Text(_isPlaying ? 'Stop' : 'Play'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isPlaying ? colorScheme.error : colorScheme.primary,
                                ),
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

// Playback Note Class
class PlaybackNote {
  final double time;
  final int pitch;
  final int velocity;
  final double duration;
  final int channel;
  final int program;
  final bool isNoteOn;

  PlaybackNote({
    required this.time,
    required this.pitch,
    required this.velocity,
    required this.duration,
    required this.channel,
    required this.program,
    required this.isNoteOn,
  });
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
  final int _lastTicks = 0;

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

enum EventType { noteOn, noteOff }

class TimelineEvent {
  final double time;
  final EventType type;
  final int channel;
  final int pitch;
  final int velocity;

  TimelineEvent({
    required this.time,
    required this.type,
    required this.channel,
    required this.pitch,
    required this.velocity,
  });
}


