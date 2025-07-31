import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

// Shared constants to avoid code duplication
const Map<int, String> INSTRUMENTS = {
  0: 'Acoustic Grand Piano', 1: 'Bright Acoustic Piano', 2: 'Electric Grand Piano', 3: 'Honky-tonk Piano', 4: 'Electric Piano 1', 5: 'Electric Piano 2', 6: 'Harpsichord', 7: 'Clavi', 8: 'Celesta', 9: 'Glockenspiel', 10: 'Music Box', 11: 'Vibraphone', 12: 'Marimba', 13: 'Xylophone', 14: 'Tubular Bells', 15: 'Dulcimer', 16: 'Drawbar Organ', 17: 'Percussive Organ', 18: 'Rock Organ', 19: 'Church Organ', 20: 'Reed Organ', 21: 'Accordion', 22: 'Harmonica', 23: 'Tango Accordion', 24: 'Acoustic Guitar (nylon)', 25: 'Acoustic Guitar (steel)', 26: 'Electric Guitar (jazz)', 27: 'Electric Guitar (clean)', 28: 'Electric Guitar (muted)', 29: 'Overdriven Guitar', 30: 'Distortion Guitar', 31: 'Guitar Harmonics', 32: 'Acoustic Bass', 33: 'Electric Bass (finger)', 34: 'Electric Bass (pick)', 35: 'Fretless Bass', 36: 'Slap Bass 1', 37: 'Slap Bass 2', 38: 'Synth Bass 1', 39: 'Synth Bass 2', 40: 'Violin', 41: 'Viola', 42: 'Cello', 43: 'Contrabass', 44: 'Tremolo Strings', 45: 'Pizzicato Strings', 46: 'Orchestral Harp', 47: 'Timpani', 48: 'String Ensemble 1', 49: 'String Ensemble 2', 50: 'Synth Strings 1', 51: 'Synth Strings 2', 52: 'Choir Aahs', 53: 'Voice Oohs', 54: 'Synth Voice', 55: 'Orchestra Hit', 56: 'Trumpet', 57: 'Trombone', 58: 'Tuba', 59: 'Muted Trumpet', 60: 'French Horn', 61: 'Brass Section', 62: 'Synth Brass 1', 63: 'Synth Brass 2', 64: 'Soprano Sax', 65: 'Alto Sax', 66: 'Tenor Sax', 67: 'Baritone Sax', 68: 'Oboe', 69: 'English Horn', 70: 'Bassoon', 71: 'Clarinet', 72: 'Piccolo', 73: 'Flute', 74: 'Recorder', 75: 'Pan Flute', 76: 'Blown Bottle', 77: 'Shakuhachi', 78: 'Whistle', 79: 'Ocarina', 80: 'Lead 1 (square)', 81: 'Lead 2 (sawtooth)', 82: 'Lead 3 (calliope)', 83: 'Lead 4 (chiff)', 84: 'Lead 5 (charang)', 85: 'Lead 6 (voice)', 86: 'Lead 7 (fifths)', 87: 'Lead 8 (bass + lead)', 88: 'Pad 1 (new age)', 89: 'Pad 2 (warm)', 90: 'Pad 3 (polysynth)', 91: 'Pad 4 (choir)', 92: 'Pad 5 (bowed)', 93: 'Pad 6 (metallic)', 94: 'Pad 7 (halo)', 95: 'Pad 8 (sweep)', 96: 'FX 1 (rain)', 97: 'FX 2 (soundtrack)', 98: 'FX 3 (crystal)', 99: 'FX 4 (atmosphere)', 100: 'FX 5 (brightness)', 101: 'FX 6 (goblins)', 102: 'FX 7 (echoes)', 103: 'FX 8 (sci-fi)', 104: 'Sitar', 105: 'Banjo', 106: 'Shamisen', 107: 'Koto', 108: 'Kalimba', 109: 'Bagpipe', 110: 'Fiddle', 111: 'Shanai', 112: 'Tinkle Bell', 113: 'Agogo', 114: 'Steel Drums', 115: 'Woodblock', 116: 'Taiko Drum', 117: 'Melodic Tom', 118: 'Synth Drum', 119: 'Reverse Cymbal', 120: 'Guitar Fret Noise', 121: 'Breath Noise', 122: 'Seashore', 123: 'Bird Tweet', 124: 'Telephone Ring', 125: 'Helicopter', 126: 'Applause', 127: 'Gunshot'
};

// MIDI to Text Converter
class MIDIToTextConverter {
  static const Map<int, String> _instruments = INSTRUMENTS;

  static const Map<int, String> _noteNames = {
    0: 'C-1', 1: 'C#-1', 2: 'D-1', 3: 'D#-1', 4: 'E-1', 5: 'F-1', 6: 'F#-1', 7: 'G-1', 8: 'G#-1', 9: 'A-1', 10: 'A#-1', 11: 'B-1',
    12: 'C0', 13: 'C#0', 14: 'D0', 15: 'D#0', 16: 'E0', 17: 'F0', 18: 'F#0', 19: 'G0', 20: 'G#0', 21: 'A0', 22: 'A#0', 23: 'B0',
    24: 'C1', 25: 'C#1', 26: 'D1', 27: 'D#1', 28: 'E1', 29: 'F1', 30: 'F#1', 31: 'G1', 32: 'G#1', 33: 'A1', 34: 'A#1', 35: 'B1',
    36: 'C2', 37: 'C#2', 38: 'D2', 39: 'D#2', 40: 'E2', 41: 'F2', 42: 'F#2', 43: 'G2', 44: 'G#2', 45: 'A2', 46: 'A#2', 47: 'B2',
    48: 'C3', 49: 'C#3', 50: 'D3', 51: 'D#3', 52: 'E3', 53: 'F3', 54: 'F#3', 55: 'G3', 56: 'G#3', 57: 'A3', 58: 'A#3', 59: 'B3',
    60: 'C4', 61: 'C#4', 62: 'D4', 63: 'D#4', 64: 'E4', 65: 'F4', 66: 'F#4', 67: 'G4', 68: 'G#4', 69: 'A4', 70: 'A#4', 71: 'B4',
    72: 'C5', 73: 'C#5', 74: 'D5', 75: 'D#5', 76: 'E5', 77: 'F5', 78: 'F#5', 79: 'G5', 80: 'G#5', 81: 'A5', 82: 'A#5', 83: 'B5',
    84: 'C6', 85: 'C#6', 86: 'D6', 87: 'D#6', 88: 'E6', 89: 'F6', 90: 'F#6', 91: 'G6', 92: 'G#6', 93: 'A6', 94: 'A#6', 95: 'B6',
    96: 'C7', 97: 'C#7', 98: 'D7', 99: 'D#7', 100: 'E7', 101: 'F7', 102: 'F#7', 103: 'G7', 104: 'G#7', 105: 'A7', 106: 'A#7', 107: 'B7',
    108: 'C8', 109: 'C#8', 110: 'D8', 111: 'D#8', 112: 'E8', 113: 'F8', 114: 'F#8', 115: 'G8', 116: 'G#8', 117: 'A8', 118: 'A#8', 119: 'B8',
    120: 'C9', 121: 'C#9', 122: 'D9', 123: 'D#9', 124: 'E9', 125: 'F9', 126: 'F#9', 127: 'G9'
  };

  static String midiDataToText(Uint8List midiBytes) {
    final midiData = _parseMidiFile(midiBytes);
    return _convertMidiDataToText(midiData);
  }

  static String _convertMidiDataToText(MIDIData midiData) {
    final buffer = StringBuffer();
    
    buffer.writeln('tempo: ${midiData.tempo}');
    buffer.writeln();
    
    for (int i = 0; i < midiData.tracks.length; i++) {
      final track = midiData.tracks[i];
      
      buffer.writeln('instrument: ${track.instrument}');
      buffer.writeln();
      
      final noteGroups = <double, List<MIDINote>>{};
      double currentTime = 0;
      
      for (final note in track.notes) {
        noteGroups.putIfAbsent(currentTime, () => []);
        noteGroups[currentTime]!.add(note);
        currentTime += note.duration;
      }
      
      for (final entry in noteGroups.entries) {
        final notes = entry.value;
        if (notes.length == 1) {
          final note = notes.first;
          final noteName = _pitchToNoteName(note.pitch);
          buffer.writeln('$noteName ${note.velocity} ${note.duration.toStringAsFixed(2)}');
        } else {
          final velocityGroups = <int, List<MIDINote>>{};
          for (final note in notes) {
            velocityGroups.putIfAbsent(note.velocity, () => []);
            velocityGroups[note.velocity]!.add(note);
          }
          
          for (final velocityEntry in velocityGroups.entries) {
            final chordNotes = velocityEntry.value;
            final durationGroups = <double, List<MIDINote>>{};
            for (final note in chordNotes) {
              durationGroups.putIfAbsent(note.duration, () => []);
              durationGroups[note.duration]!.add(note);
            }
            
            for (final durationEntry in durationGroups.entries) {
              final finalChordNotes = durationEntry.value;
              final noteNames = finalChordNotes.map((n) => _pitchToNoteName(n.pitch)).toList();
              final chordString = noteNames.join('+');
              buffer.writeln('$chordString ${velocityEntry.key} ${durationEntry.key.toStringAsFixed(2)}');
            }
          }
        }
      }
      
      if (i < midiData.tracks.length - 1) {
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }

  static String _pitchToNoteName(int pitch) {
    return _noteNames[pitch] ?? 'Unknown';
  }

  static String _getInstrumentName(int program) {
    return _instruments[program] ?? 'Acoustic Grand Piano';
  }

  static MIDIData _parseMidiFile(Uint8List bytes) {
    final data = bytes;
    int offset = 0;
    
    if (data.length < 14 || String.fromCharCodes(data.sublist(0, 4)) != 'MThd') {
      throw FormatException('Invalid MIDI file header');
    }
    
    final headerLength = _readInt32(data, 4);
    final format = _readInt16(data, 8);
    final numTracks = _readInt16(data, 10);
    final timeDivision = _readInt16(data, 12);
    
    if (headerLength != 6 || format < 0 || format > 1) { // Accept format 0 and 1
        throw FormatException('Unsupported MIDI format. Only format 0 and 1 are supported.');
    }
    
    final ticksPerBeat = timeDivision;
    offset = 14;
    
    final tracks = <MIDITrack>[];
    int tempo = 120;
    
    for (int trackIndex = 0; trackIndex < numTracks; trackIndex++) {
      if (offset >= data.length) break;
      
      if (offset + 4 <= data.length && String.fromCharCodes(data.sublist(offset, offset + 4)) == 'MTrk') {
        final trackLength = _readInt32(data, offset + 4);
        offset += 8;
        final trackEnd = offset + trackLength;
        
        final notes = <MIDINote>[];
        int currentTime = 0;
        int currentProgram = 0;
        final activeNotes = <int, _ActiveNote>{};
        int lastStatus = 0;

        while (offset < trackEnd && offset < data.length) {
          final deltaTimeResult = _readVarInt(data, offset);
          final deltaTime = deltaTimeResult.value;
          offset = deltaTimeResult.offset;
          
          if (offset >= trackEnd || offset >= data.length) break;
          
          currentTime += deltaTime;
          
          int status = data[offset];
          int channel;

          if (status < 0x80) {
            status = lastStatus;
          } else {
            offset++;
            lastStatus = status;
          }
          
          channel = status & 0x0F;
          final eventType = status & 0xF0;

          if (eventType == 0x90) {
            if (offset + 1 >= data.length) break;
            final note = data[offset];
            final velocity = data[offset + 1];
            offset += 2;
            
            if (velocity > 0) {
              final noteKey = note | (channel << 8);
              activeNotes[noteKey] = _ActiveNote(startTime: currentTime, channel: channel, velocity: velocity);
            } else {
              final noteKey = note | (channel << 8);
              _finalizeNote(activeNotes, noteKey, note, currentTime, notes, ticksPerBeat, tempo);
            }
          } else if (eventType == 0x80) {
            if (offset + 1 >= data.length) break;
            final note = data[offset];
            offset += 2; // Also skip velocity byte
            final noteKey = note | (channel << 8);
            _finalizeNote(activeNotes, noteKey, note, currentTime, notes, ticksPerBeat, tempo);
          } else if (eventType == 0xC0) {
            if (offset >= data.length) break;
            currentProgram = data[offset];
            offset += 1;
          } else if (status == 0xFF) {
            if (offset + 1 >= data.length) break;
            final metaType = data[offset];
            final metaLengthResult = _readVarInt(data, offset + 1);
            offset = metaLengthResult.offset;
            final metaLength = metaLengthResult.value;
            
            if (metaType == 0x51 && metaLength == 3) {
              final tempoValue = (data[offset] << 16) | (data[offset + 1] << 8) | data[offset + 2];
              tempo = 60000000 ~/ tempoValue;
            }
            offset += metaLength;
          } else if (eventType == 0xA0 || eventType == 0xB0 || eventType == 0xE0) {
              offset += 2;
          } else if (eventType == 0xD0) {
              offset += 1;
          }
        }
        
        for (final noteKey in activeNotes.keys.toList()) {
          final notePitch = noteKey & 0xFF;
          _finalizeNote(activeNotes, noteKey, notePitch, currentTime, notes, ticksPerBeat, tempo);
        }
        
        if (notes.isNotEmpty) {
          tracks.add(MIDITrack(
            instrument: _getInstrumentName(currentProgram),
            program: currentProgram,
            notes: notes,
          ));
        }
        
        offset = trackEnd;
      } else {
        offset++;
      }
    }
    
    return MIDIData(tempo: tempo, tracks: tracks);
  }

  static void _finalizeNote(
    Map<int, _ActiveNote> activeNotes, int noteKey, int notePitch, int currentTime, List<MIDINote> notes, int ticksPerBeat, int tempo
  ) {
    final activeNote = activeNotes.remove(noteKey);
    if (activeNote != null) {
      final durationInTicks = currentTime - activeNote.startTime;
      final durationInBeats = durationInTicks / ticksPerBeat.toDouble();
      final durationInSeconds = durationInBeats * (60.0 / tempo);
      notes.add(MIDINote(
        pitch: notePitch,
        velocity: activeNote.velocity,
        duration: durationInSeconds,
        startTime: activeNote.startTime / ticksPerBeat * (60.0/tempo)
      ));
    }
  }

  static int _readInt16(Uint8List data, int offset) => (data[offset] << 8) | data[offset + 1];
  static int _readInt32(Uint8List data, int offset) => (data[offset] << 24) | (data[offset + 1] << 16) | (data[offset + 2] << 8) | data[offset + 3];

  static _VarIntResult _readVarInt(Uint8List data, int offset) {
    int value = 0;
    int currentOffset = offset;
    while (currentOffset < data.length) {
      final byte = data[currentOffset++];
      value = (value << 7) | (byte & 0x7F);
      if ((byte & 0x80) == 0) break;
    }
    return _VarIntResult(value: value, offset: currentOffset);
  }
}

class _ActiveNote {
  final int startTime;
  final int channel;
  final int velocity;
  _ActiveNote({required this.startTime, required this.channel, required this.velocity});
}

class _VarIntResult {
  final int value;
  final int offset;
  _VarIntResult({required this.value, required this.offset});
}

void main() => runApp(const MIDIGeneratorApp());

class MIDIGeneratorApp extends StatelessWidget {
  const MIDIGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF), brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF), brightness: Brightness.dark);
    return MaterialApp(
      title: 'MIDI Generator',
      theme: ThemeData(useMaterial3: true, colorScheme: lightScheme, cupertinoOverrideTheme: CupertinoThemeData(primaryColor: lightScheme.primary)),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
      themeMode: ThemeMode.system,
      home: const MIDIGeneratorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MIDIGeneratorHome extends StatefulWidget {
  const MIDIGeneratorHome({super.key});
  @override
  State<MIDIGeneratorHome> createState() => _MIDIGeneratorHomeState();
}

class _MIDIGeneratorHomeState extends State<MIDIGeneratorHome> with TickerProviderStateMixin {
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
  String? _currentAudioFile;

  // MIDI Data
  MIDIData? _currentMidiData;
  Uint8List? _midiBytes;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _generateButtonController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _playButtonController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _textController.text = '''tempo: 140
instrument: Acoustic Grand Piano

C4 100 0.5
D4 100 0.5
Eb4 100 0.5
F4 100 0.5
G4 100 0.5
Ab4 100 0.5
Bb4 100 0.5
C5 100 1.0

instrument: Acoustic Guitar (nylon)

C3 85 0.75
D3 85 0.75
Eb3 85 0.75
F3 85 0.75
G3 85 0.75
Ab3 85 0.75
Bb3 85 0.75
C4 85 1.5''';
    _loadSoundFont();
    _setupAudioPlayerListener();
  }

  // ADDED: Listen for player completion to reset UI state
  void _setupAudioPlayerListener() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _addLog('Playback finished.');
        if (mounted) {
          setState(() => _isPlaying = false);
          _playButtonController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _generateButtonController.dispose();
    _playButtonController.dispose();
    _textController.dispose();
    _logController.dispose();
    _cleanupAudioFiles();
    super.dispose();
  }

  void _cleanupAudioFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (final file in files) {
        if (file is File && file.path.contains('temp_audio_') && file.path.endsWith('.wav')) {
          try { await file.delete(); } catch (_) {}
        }
      }
    } catch (_) {}
  }

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logs.add('$timestamp - $message');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(_logController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _loadSoundFont() async {
    _addLog('Loading SoundFont...');
    try {
      final bytes = await rootBundle.load('assets/TremoSoundFont.sf2');
      _synthesizerSettings = SynthesizerSettings(sampleRate: 44100, maximumPolyphony: 128, blockSize: 64);
      final synthesizer = Synthesizer.loadByteData(bytes, _synthesizerSettings);
      
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

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _stopPlayback();
      return;
    }

    if (_synthesizer == null || _currentMidiData == null) {
      _addLog('No synthesizer or MIDI data available. Please generate first.');
      return;
    }

    setState(() => _isGenerating = true); // Show spinner while rendering
    _addLog('Generating audio for playback...');
    
    // Asynchronously generate audio
    await _generateAudioFile();
    
    setState(() => _isGenerating = false);

    if (_currentAudioFile != null) {
      _addLog('Starting playback...');
      await _audioPlayer.play(DeviceFileSource(_currentAudioFile!));
      setState(() => _isPlaying = true);
      _playButtonController.forward();
    } else {
      _addLog('Failed to generate audio file for playback.');
    }
  }
  
  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
    _playButtonController.reverse();
    _addLog('Playback stopped.');
  }

  Future<void> _generateAudioFile() async {
    if (_synthesizer == null || _currentMidiData == null) return;
    
    try {
      // FIXED: Correctly calculate total duration by finding the end time of the last note.
      double totalDuration = 0;
      for (final track in _currentMidiData!.tracks) {
        for (final note in track.notes) {
          final noteEnd = note.startTime + note.duration;
          if (noteEnd > totalDuration) {
            totalDuration = noteEnd;
          }
        }
      }
      totalDuration += 1.0; // Add some tail time

      if (totalDuration <= 1.0) {
        _addLog('Error: No notes to play, duration is zero.');
        return;
      }
      _addLog('Rendering audio... Total duration: ${totalDuration.toStringAsFixed(2)}s');

      _synthesizer!.reset();

      // FIXED: Set up instruments for each channel
      for (int i = 0; i < _currentMidiData!.tracks.length; i++) {
        final track = _currentMidiData!.tracks[i];
        _addLog('  - Setting channel $i to instrument: ${track.instrument} (Program ${track.program})');
        _synthesizer!.noteOffAll(channel: i, immediate: true);
        _synthesizer!.selectPreset(channel: i, preset: track.program);
      }
      
      // Create a timeline of all events (NoteOn, NoteOff) from all tracks
      final events = <TimelineEvent>[];
      for (int i = 0; i < _currentMidiData!.tracks.length; i++) {
        for (final note in _currentMidiData!.tracks[i].notes) {
          events.add(TimelineEvent(time: note.startTime, type: EventType.noteOn, channel: i, pitch: note.pitch, velocity: note.velocity));
          events.add(TimelineEvent(time: note.startTime + note.duration, type: EventType.noteOff, channel: i, pitch: note.pitch));
        }
      }
      events.sort((a, b) => a.time.compareTo(b.time));

      // Render audio block by block
      final sampleRate = _synthesizerSettings.sampleRate;
      final totalSamples = (totalDuration * sampleRate).round();
      final renderedBytes = BytesBuilder();
      
      int currentSample = 0;
      int eventIndex = 0;
      final renderBlockSize = sampleRate ~/ 10; // Render in 100ms chunks

      while (currentSample < totalSamples) {
        final blockEndSample = (currentSample + renderBlockSize).clamp(0, totalSamples);
        final currentTime = currentSample / sampleRate;
        final blockEndTime = blockEndSample / sampleRate;

        // Process all MIDI events that occur before the end of this audio block
        while (eventIndex < events.length && events[eventIndex].time < blockEndTime) {
          final event = events[eventIndex];
          if (event.type == EventType.noteOn) {
            _synthesizer!.noteOn(channel: event.channel, key: event.pitch, velocity: event.velocity);
          } else {
            _synthesizer!.noteOff(channel: event.channel, key: event.pitch);
          }
          eventIndex++;
        }
        
        // Render the audio block
        final blockBuffer = ArrayInt16.zeros(numShorts: blockEndSample - currentSample);
        _synthesizer!.renderMonoInt16(blockBuffer);
        
        // Append rendered audio to our byte buffer
        renderedBytes.add(_arrayInt16ToBytes(blockBuffer));
        currentSample = blockEndSample;
      }

      // Save to a temporary WAV file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'temp_audio_$timestamp.wav';
      final path = (await getTemporaryDirectory()).path;
      final file = File('$path/$fileName');
      
      final wavData = renderedBytes.toBytes();
      final wavHeader = _createWavHeader(sampleRate, wavData.length ~/ 2);
      await file.writeAsBytes(wavHeader + wavData, flush: true);

      _currentAudioFile = file.path;
      _addLog('Generated audio file: ${file.lengthSync()} bytes');

    } catch (e, st) {
      _addLog('FATAL Error generating audio file: $e\n$st');
      _currentAudioFile = null;
    }
  }
  
  // FIXED: Simplified WAV header creation
  Uint8List _createWavHeader(int sampleRate, int numSamples) {
    final byteData = ByteData(44);
    final BITS_PER_SAMPLE = 16;
    final NUM_CHANNELS = 1;
    
    byteData.setUint32(0, 0x52494646, Endian.little); // 'RIFF'
    byteData.setUint32(4, 36 + numSamples * NUM_CHANNELS * BITS_PER_SAMPLE ~/ 8, Endian.little);
    byteData.setUint32(8, 0x57415645, Endian.little); // 'WAVE'
    byteData.setUint32(12, 0x666d7420, Endian.little); // 'fmt '
    byteData.setUint32(16, 16, Endian.little); // PCM sub-chunk size
    byteData.setUint16(20, 1, Endian.little); // PCM format
    byteData.setUint16(22, NUM_CHANNELS.toInt(), Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * NUM_CHANNELS * BITS_PER_SAMPLE ~/ 8, Endian.little); // Byte rate
    byteData.setUint16(32, NUM_CHANNELS * BITS_PER_SAMPLE ~/ 8, Endian.little); // Block align
    byteData.setUint16(34, BITS_PER_SAMPLE.toInt(), Endian.little);
    byteData.setUint32(36, 0x64617461, Endian.little); // 'data'
    byteData.setUint32(40, numSamples * NUM_CHANNELS * BITS_PER_SAMPLE ~/ 8, Endian.little);
    
    return byteData.buffer.asUint8List();
  }

  // FIXED: Simplified byte conversion
  Uint8List _arrayInt16ToBytes(ArrayInt16 array) {
    return array.buffer.asUint8List();
  }

  Future<void> _saveMIDI() async {
    if (_midiBytes == null) {
      _addLog('No MIDI data to save. Please generate first.');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generate MIDI before saving!')));
      return;
    }
    try {
      final fileName = 'midi_${DateTime.now().toIso8601String().replaceAll(':', '-')}';
      final path = await FileSaver.instance.saveFile(name: fileName, bytes: _midiBytes, ext: 'mid', mimeType: MimeType.other);
      _addLog('Saved $fileName at $path');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully saved to $path')));
    } catch (e) {
      _addLog('Error saving file: $e');
    }
  }

  Future<void> _importMIDI() async {
    try {
      _addLog('Importing MIDI file...');
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mid', 'midi'], allowMultiple: false);

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        _addLog('MIDI file loaded: ${file.path} (${bytes.length} bytes)');
        
        final text = MIDIToTextConverter.midiDataToText(bytes);
        setState(() => _textController.text = text);
        
        _addLog('MIDI converted to text successfully.');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MIDI imported and converted to text!')));
      }
    } catch (e) {
      _addLog('Error importing MIDI: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing MIDI: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: colorScheme.surface, border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5))),
            child: Row(
              children: [
                Text('MIDI Generator', style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  avatar: Icon(_soundFontLoaded ? Icons.check_circle : Icons.hourglass_empty, color: _soundFontLoaded ? colorScheme.primary : colorScheme.onSurfaceVariant),
                  label: Text(_soundFontLoaded ? 'SoundFont Ready' : 'Loading...'),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(20), elevation: 0, color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(CupertinoIcons.music_note_2, color: colorScheme.primary), const SizedBox(width: 8), Text('Musical Score', style: theme.textTheme.titleMedium)])),
                        const Divider(height: 1),
                        Expanded(child: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _textController, maxLines: null, expands: true, style: const TextStyle(fontFamily: 'SF Mono', fontSize: 14, height: 1.4), decoration: const InputDecoration(border: InputBorder.none)))),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              FilledButton.icon(
                                onPressed: _isGenerating ? null : _generateMIDI,
                                icon: _isGenerating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(CupertinoIcons.waveform),
                                label: Text(_isGenerating ? 'Generating...' : 'Generate MIDI'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: (_currentMidiData == null || !_soundFontLoaded || _isGenerating) ? null : _togglePlayback,
                                icon: _isPlaying ? const Icon(CupertinoIcons.stop_fill) : const Icon(CupertinoIcons.play_fill),
                                label: Text(_isPlaying ? 'Stop' : 'Play'),
                                style: FilledButton.styleFrom(backgroundColor: _isPlaying ? colorScheme.error : colorScheme.primary),
                              ),
                              const Spacer(),
                              FilledButton.tonalIcon(onPressed: _saveMIDI, icon: const Icon(CupertinoIcons.cloud_download_fill), label: const Text('Save')),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(onPressed: _importMIDI, icon: const Icon(CupertinoIcons.folder_fill), label: const Text('Import')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(0, 20, 20, 20), elevation: 0, color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [const Icon(CupertinoIcons.list_bullet, color: Colors.grey), const SizedBox(width: 8), Text('Generation Log', style: theme.textTheme.titleMedium), const Spacer(), IconButton(icon: const Icon(CupertinoIcons.clear, size: 16), onPressed: () => setState(() => _logs.clear()))]),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.separated(
                              controller: _logController, itemCount: _logs.length,
                              separatorBuilder: (_, __) => Divider(color: colorScheme.outline.withOpacity(0.12)),
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final isError = log.contains('Error');
                                return Text(log, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'SF Mono', color: isError ? colorScheme.error : colorScheme.onSurfaceVariant));
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

// --- Data Models and Parsers ---
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
  final double startTime; // in seconds
  MIDINote({required this.pitch, required this.velocity, required this.duration, required this.startTime});
}

class ChordOrNote {
  final List<int> pitches;
  final int velocity;
  final double duration;
  ChordOrNote({required this.pitches, required this.velocity, required this.duration});
}

class MIDITextParser {
  static const Map<String, int> noteMap = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11};
  static Map<String, int> get instrumentMap => Map.fromEntries(INSTRUMENTS.entries.map((e) => MapEntry(e.value, e.key)));

  MIDIData parse(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty && !line.trim().startsWith('#'));
    int tempo = 120;
    Map<String, List<ChordOrNote>> instrumentNotes = {};
    String currentInstrument = 'Acoustic Grand Piano';
    instrumentNotes.putIfAbsent(currentInstrument, () => []);

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
            final notePart = parts[0];
            final velocity = int.parse(parts[1]);
            final durationInBeats = double.parse(parts[2]);
            final durationInSeconds = durationInBeats * (60.0 / tempo);
            List<int> pitches = notePart.contains('+')
                ? notePart.split('+').map((name) => _parseNoteName(name.trim())).toList()
                : [_parseNoteName(notePart)];
            instrumentNotes[currentInstrument]!.add(ChordOrNote(pitches: pitches, velocity: velocity, duration: durationInSeconds));
          } catch (e) {
            throw FormatException('Invalid note line: "$trimmed" ($e)');
          }
        }
      }
    }
    
    final tracks = instrumentNotes.entries.map((entry) {
      final program = instrumentMap[entry.key] ?? 0;
      final midiNotes = <MIDINote>[];
      double currentTime = 0.0;
      
      for (final chordOrNote in entry.value) {
        for (final pitch in chordOrNote.pitches) {
          midiNotes.add(MIDINote(pitch: pitch, velocity: chordOrNote.velocity, duration: chordOrNote.duration, startTime: currentTime));
        }
        currentTime += chordOrNote.duration;
      }
      return MIDITrack(instrument: entry.key, program: program, notes: midiNotes);
    }).toList();

    return MIDIData(tempo: tempo, tracks: tracks);
  }

  int _parseNoteName(String noteName) {
    final match = RegExp(r'^([A-G][#b]?)(-?\d+)$').firstMatch(noteName.toUpperCase());
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
      
      final double beatsPerSecond = midiData.tempo / 60.0;
      for (final note in track.notes) {
        final startTicks = (note.startTime * beatsPerSecond * writer.ticksPerBeat).round();
        final durationInTicks = (note.duration * beatsPerSecond * writer.ticksPerBeat).round();
        writer.addNote(channel: i, pitch: note.pitch, velocity: note.velocity, startTicks: startTicks, endTicks: startTicks + durationInTicks);
      }
    }
    return writer.build();
  }
}

class MidiWriter {
  final int ticksPerBeat;
  final List<MidiTrackWriter> _tracks = [];
  int _tempo = 120;

  MidiWriter({this.ticksPerBeat = 480});
  void addTempo(int tempo) => _tempo = tempo;
  void addTrack() => _tracks.add(MidiTrackWriter());
  void addProgramChange({required int channel, required int program}) {
    if (_tracks.isEmpty) addTrack();
    _tracks.last.addProgramChange(channel: channel, program: program);
  }
  void addNote({required int channel, required int pitch, required int velocity, required int startTicks, required int endTicks}) {
    if (_tracks.isEmpty) addTrack();
    _tracks.last.addNote(channel: channel, pitch: pitch, velocity: velocity, startTicks: startTicks, endTicks: endTicks);
  }

  Uint8List build() {
    final builder = BytesBuilder();
    builder.add('MThd'.codeUnits);
    builder.add(_int32(6));
    builder.add(_int16(1));
    builder.add(_int16(_tracks.length + 1));
    builder.add(_int16(ticksPerBeat));

    final tempoTrackBytes = MidiTrackWriter()..addTempo(_tempo)..build();
    builder.add('MTrk'.codeUnits);
    builder.add(_int32(tempoTrackBytes.length));
    builder.add(tempoTrackBytes);

    for (final track in _tracks) {
      final trackBytes = track.build();
      builder.add('MTrk'.codeUnits);
      builder.add(_int32(trackBytes.length));
      builder.add(trackBytes);
    }
    return builder.toBytes();
  }

  static Uint8List _int16(int v) => Uint8List(2)..buffer.asByteData().setInt16(0, v, Endian.big);
  static Uint8List _int32(int v) => Uint8List(4)..buffer.asByteData().setInt32(0, v, Endian.big);
}

class MidiTrackWriter {
  final List<_MidiEvent> _events = [];
  void addTempo(int tempo) {
    final microsecs = 60000000 ~/ tempo;
    _events.add(_MidiEvent(0, 0xFF, [0x51, 0x03, (microsecs >> 16) & 0xFF, (microsecs >> 8) & 0xFF, microsecs & 0xFF]));
  }
  void addProgramChange({required int channel, required int program}) => _events.add(_MidiEvent(0, 0xC0 | channel, [program]));
  void addNote({required int channel, required int pitch, required int velocity, required int startTicks, required int endTicks}) {
    _events.add(_MidiEvent(startTicks, 0x90 | channel, [pitch, velocity]));
    _events.add(_MidiEvent(endTicks, 0x80 | channel, [pitch, 0]));
  }

  Uint8List build() {
    _events.sort((a, b) => a.ticks.compareTo(b.ticks));
    final builder = BytesBuilder();
    int lastTicks = 0;
    for (final event in _events) {
      builder.add(_writeVarInt(event.ticks - lastTicks));
      builder.addByte(event.status);
      builder.add(event.data);
      lastTicks = event.ticks;
    }
    builder.add([0x00, 0xFF, 0x2F, 0x00]);
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
  final int ticks; final int status; final List<int> data;
  _MidiEvent(this.ticks, this.status, this.data);
}

enum EventType { noteOn, noteOff }
class TimelineEvent {
  final double time; final EventType type; final int channel; final int pitch; final int velocity;
  TimelineEvent({required this.time, required this.type, required this.channel, required this.pitch, this.velocity = 0});
}