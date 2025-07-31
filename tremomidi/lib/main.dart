import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

// MIDI to Text Converter
class MIDIToTextConverter {
  static const Map<int, String> _instruments = {
    0: 'MK E.Grand Piano L',
    1: 'MK E.Grand Piano R',
    2: 'Harpsi 8\'I',
    3: 'Harpsi Key Noise',
    4: 'Harpsi 8\'II',
    5: 'HS1 hard',
    6: 'HS1 soft',
    7: 'HS normal',
    8: 'Celesta',
    9: 'Ethan\'s Glock',
    10: 'Music Box',
    11: 'Iowa Marimba',
    12: 'Iowa Xylophone',
    13: 'Chuck\'s Tubulars',
    14: 'Dulcimer',
    15: 'Drawbar Organ',
    16: 'Percuss 4 High',
    17: 'Rock Organ',
    18: 'Church Organ',
    19: 'Reed Organ',
    20: 'Accordian',
    21: 'Hohner C Harmonica',
    22: 'Bandoneon',
    23: 'FG460s_Hbr_Pr',
    24: 'FG460s_Hrd_Pr',
    25: 'SGM Jazz Guitar',
    26: 'E. Guitar Clean',
    27: 'E. Guitar Muted C.',
    28: 'SGM Overdriven',
    29: 'SGM Distortion',
    30: 'Gt.Harmonics',
    31: 'Ottos Fretless',
    32: 'Slap Bass 1',
    33: 'Slap Bass 2',
    34: 'SynBs1',
    35: 'SynBs2-a',
    36: 'SynBs2-c',
    37: 'SynBs2-b',
    38: 'Iowa Violin-ff',
    39: 'Iowa Viola-ff',
    40: 'JSCeltHarpExtra',
    41: 'JSCelticHarp',
    42: 'Timpani',
    43: 'Basses 1',
    44: 'Basses 2',
    45: 'Cellos 1',
    46: 'Cellos 2',
    47: 'Violas 1',
    48: 'Violas 2',
    49: 'Violins 1',
    50: 'Violins 2',
    51: 'Synth Strings 1',
    52: 'Synth Strings 2',
    53: 'Vocal Aaah',
    54: 'SynthVoice',
    55: 'Orchestra Hit',
    56: 'IowaTrumpet',
    57: 'iowa trombone',
    58: 'Tuba',
    59: 'MUTED TRMPET0',
    60: 'MUTED TRMPET01',
    61: 'MUTED TRMPET02',
    62: 'Horns 1',
    63: 'Horns 2',
    64: 'French Horns',
    65: 'Iowa Alto Sax',
    66: 'Tenor Saxophone',
    67: 'Bear Sax',
    68: 'Mute Trumpet',
    69: 'Eddie\'s English Horn',
    70: 'Synth Brass 1',
    71: 'Synth Brass 2',
    72: 'soprano sax',
    73: 'Iowa Oboe',
    74: 'iowa bassoon',
    75: 'legato forte',
    76: 'Piccolo',
    77: 'Ixox Flute',
    78: 'Recorder',
    79: 'Mr Shoe\'s Pan Flute',
    80: 'Bottle Blow',
    81: 'Shakuhachi',
    82: 'SGM WHISTLE',
    83: 'SGM Ocarina',
    84: 'Square Lead',
    85: 'Sawtooth',
    86: 'FP Synth Calliope',
    87: 'pad:Mute Vox',
    88: '5th Saw Wave',
    89: 'BassAndLead',
    90: 'Fantasia',
    91: 'EnhancedSGMBowedPad',
    92: 'MetalPadFG460sGtr',
    93: 'EnhancedSGM Halo Pad',
    94: 'EnhancedSGMSweepPad',
    95: 'Rain FX1',
    96: 'Rain FX1-2',
    97: 'E.SGM Soundtrack',
    98: 'Chuck\'s Tubulars',
    99: 'Iowa Bells',
    100: 'SGM Brightness',
    101: 'Bowed Sitars',
    102: 'Echo Drops',
    103: 'Star Theme',
    104: 'SynthStrs2Variation',
    105: 'Sitar',
    106: 'Banjo',
    107: 'Shamisen',
    108: 'Koto',
    109: 'Kalimba',
    110: 'Bagpipe',
    111: 'AAViolin X',
    112: 'Shenai',
    113: 'Agogo',
    114: 'Steel Drum',
    115: 'Iowa Woodblock',
    116: 'Taiko',
    117: 'OSDK tom1',
    118: 'Synth Drum',
    119: 'OSDK Reverse Cymbal',
    120: 'Guitar Fret Noise',
    121: 'Seashore',
    122: 'Bird0',
    123: 'Bird1',
    124: 'Telephone',
    125: 'Helicopter',
    126: 'Applause',
    127: 'Gunshot',
    128: 'Synth Bass 3',
    129: 'Papelmedia Trb',
    130: 'Papelmedia Trb Stacc',
    131: 'French Horns 2',
    132: 'Spectrum',
    133: 'synth mallet',
    134: 'Fantasia-Delayed',
    135: 'Sitar-1',
    136: 'Guitar Cut Noise',
    137: 'Key Click',
    138: 'Rain',
    139: 'Dog',
    140: 'Telephone 2',
    141: 'Car Engine',
    142: 'Laugh',
    143: 'MG',
    144: 'BassAndLeadDelayed',
    145: 'String Slap',
    146: 'Thunder',
    147: 'Horse',
    148: 'Door Creaking',
    149: 'Car Stop',
    150: 'Scream',
    151: 'Laser Gun',
    152: 'Wind',
    153: '000479',
    154: 'Door Closing',
    155: 'Car Pass',
    156: 'Punch',
    157: 'Explosion',
    158: 'Stream',
    159: 'Scratch',
    160: 'Car Crash',
    161: 'Heart Beat',
    162: 'Bubble',
    163: 'Wind Chime',
    164: 'Siren',
    165: 'Footsteps',
    166: 'Train',
    167: 'Jet Plane',
    168: 'Spatial Marimba',
    169: 'Church Bell',
    170: 'Pipe Organ',
    171: 'Manual',
    172: 'Ukelele',
    173: 'Hawaiian Guitar',
    174: 'MK MuteEGtr',
    175: 'MK Muted Guitar',
    176: 'MK Muted Gt.',
    177: 'Guitar Feedback',
    178: 'Strat Marshall',
    179: 'Synth Bass 5',
    180: 'Synth Brass 1-1',
    181: 'Synth Brass 1-2',
    182: 'Synth Brass Sfz',
    183: 'Sine Wave',
    184: 'Synth Square',
    185: 'Steel Guitar',
    186: 'Koto',
    187: 'Iowa Castanets',
    188: 'Bass Drum 1',
    189: 'Bass Drum 2',
    190: 'Melo Tom 1',
    191: 'T8 Tom',
    192: 'StarShip',
    193: 'OSDK tom1-room',
    194: 'Burst Noise',
    195: 'E-Mu 60\'s Organ 1',
    196: 'Gothic Organ I',
    197: 'Mandolin',
    198: 'Palm Muted Guitar',
    199: 'Synth Bass 3 Rubber',
    200: 'Wurlitzer EP1 dry',
    201: '70\'s Drawbar Organ',
    202: 'Classical Guitar 1',
    203: 'SGM Standard 1',
    204: 'SGM rhythm(cym1)',
    205: 'Drum Roll',
    206: 'SGM Analog kit',
    207: 'SGM rhythm(cym3)',
    208: 'SGM Jazz Kit',
    209: 'SFX Kit',
    210: 'SFX (Xioad/SGM/MK)',
    211: 'SGM rhythm(cym1)',
    212: 'Room Kit',
    213: 'POWER',
    214: 'SGM rhythm(cym4)',
    215: 'BRUSH',
    216: 'SGM rhythm(cym1)',
    217: 'Jazz',
    218: 'Orchestral',
    219: 'Timpani',
    220: 'ELECTRONIC',
    221: 'SGM rhythm(cym1)',
    222: 'Standard 1',
    223: 'FM E.Piano',
    224: 'FM E.Piano Hard',
    225: 'jRhodes3a',
    226: 'SalamanderGrandPiano',
    227: 'vibraphone',
    228: 'Iowa Arco Bass-ff',
    229: 'Iowa Cello-ff',
    230: 'Sawtooth Lead',
    231: 'Papelmedia Trumpet',
    232: 'BRS:Fat Sect 1dS',
    233: 'BRS:Tps f    2dS',
    234: 'Voice Oohs',
    235: 'Finger Bass',
    236: 'Picked Bass',
    237: 'Pizzicato',
    238: 'MeatBass',
    239: 'Snare',
    240: 'Cymbal',
    241: 'Harmo Pan0',
    242: 'Harmo Pan1',
    243: 'Glasses',
    244: 'Warm Bell0',
    245: 'Warm Bell1',
    246: 'Schooldaze',
    247: 'BellSinger',
    248: 'Wind Bell0',
    249: 'Wind Bell1',
    250: 'Sho0',
    251: 'Sho1',
    252: 'Taiko Rim',
    253: 'Triangle',
    254: 'OneNoteJam0',
    255: 'OneNoteJam1',
    256: 'WaterBells0',
    257: 'WaterBells1',
    258: 'JungleTune0',
    259: 'JungleTune1',
    260: 'cm-64/32l',
    261: 'sfx cm-64/32l',
    262: 'Wurlitzer',
    263: 'Classical Acoustic',
    264: 'Doo Vox',
    265: 'Doo Vox L2',
    266: 'Harpsichord',
    267: 'Church Organ',
    268: 'PercussiveOrgan',
    269: 'RockOrgan',
    270: 'Accordion'
  };

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
    
    // Write tempo
    buffer.writeln('tempo: ${midiData.tempo}');
    buffer.writeln();
    
    // Write tracks
    for (int i = 0; i < midiData.tracks.length; i++) {
      final track = midiData.tracks[i];
      
      buffer.writeln('instrument: ${track.instrument}');
      buffer.writeln();
      
      // Group notes by start time to create chords
      final noteGroups = <double, List<MIDINote>>{};
      double currentTime = 0;
      
      for (final note in track.notes) {
        noteGroups.putIfAbsent(currentTime, () => []);
        noteGroups[currentTime]!.add(note);
        currentTime += note.duration;
      }
      
      // Output grouped notes as chords or single notes
      for (final entry in noteGroups.entries) {
        final notes = entry.value;
        if (notes.length == 1) {
          // Single note
          final note = notes.first;
          final noteName = _pitchToNoteName(note.pitch);
          buffer.writeln('$noteName ${note.velocity} ${note.duration.toStringAsFixed(2)}');
        } else {
          // Chord - group notes with same velocity and duration
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
    
    // Check MIDI header
    if (data.length < 14 || 
        String.fromCharCodes(data.sublist(0, 4)) != 'MThd') {
      throw FormatException('Invalid MIDI file header');
    }
    
    // Parse header chunk
    final headerLength = _readInt32(data, 4);
    final format = _readInt16(data, 8);
    final numTracks = _readInt16(data, 10);
    final timeDivision = _readInt16(data, 12);
    
    // Validate header (these variables are used for validation)
    if (headerLength != 6 || format != 1) {
      throw FormatException('Unsupported MIDI format');
    }
    
    // Use timeDivision for ticks per beat calculation
    final ticksPerBeat = timeDivision;
    
    offset = 14; // Skip header chunk
    
    final tracks = <MIDITrack>[];
    int tempo = 120;
    
    for (int trackIndex = 0; trackIndex < numTracks; trackIndex++) {
      if (offset >= data.length) break;
      
      // Check for track chunk
      if (offset + 4 <= data.length && 
          String.fromCharCodes(data.sublist(offset, offset + 4)) == 'MTrk') {
        
        final trackLength = _readInt32(data, offset + 4);
        offset += 8; // Skip track header
        final trackEnd = offset + trackLength;
        
        final notes = <MIDINote>[];
        int currentTime = 0;
        int currentProgram = 0;
        final activeNotes = <int, _ActiveNote>{};
        
        int lastStatus = 0; // For running status

        while (offset < trackEnd && offset < data.length) {
          final deltaTimeResult = _readVarInt(data, offset);
          final deltaTime = deltaTimeResult.value;
          offset = deltaTimeResult.offset;
          
          if (offset >= trackEnd || offset >= data.length) break;
          
          currentTime += deltaTime;
          
          int status = data[offset];
          int channel;

          // Check for running status (data byte without a status byte)
          if (status < 0x80) {
            status = lastStatus;
            // Don't increment offset, we need to read this byte as data
          } else {
            offset++;
            lastStatus = status;
          }
          
          channel = status & 0x0F;
          final eventType = status & 0xF0;

          if (eventType == 0x90) { // Note On
            if (offset + 1 >= data.length) break;
            final note = data[offset];
            final velocity = data[offset + 1];
            offset += 2;
            
            if (velocity > 0) {
              // Store note start time with unique key (note + channel)
              final noteKey = note | (channel << 8);
              activeNotes[noteKey] = _ActiveNote(
                startTime: currentTime,
                channel: channel,
                velocity: velocity,
              );
            } else {
              final noteKey = note | (channel << 8);
              _finalizeNote(activeNotes, noteKey, note, currentTime, notes, ticksPerBeat, tempo);
            }
          } else if (eventType == 0x80) { // Note Off
            if (offset + 1 >= data.length) break;
            final note = data[offset];
            offset += 2;
            final noteKey = note | (channel << 8);
            _finalizeNote(activeNotes, noteKey, note, currentTime, notes, ticksPerBeat, tempo);
          } else if (eventType == 0xC0) { // Program Change
            if (offset >= data.length) break;
            currentProgram = data[offset];
            offset += 1;
          } else if (status == 0xFF) { // Meta Event
            if (offset + 1 >= data.length) break;
            final metaType = data[offset];
            final metaLengthResult = _readVarInt(data, offset + 1);
            offset = metaLengthResult.offset;
            
            if (metaType == 0x51 && offset + 2 < data.length) { // Set Tempo
              final tempoValue = (data[offset] << 16) | (data[offset + 1] << 8) | data[offset + 2];
              tempo = 60000000 ~/ tempoValue;
            }
            offset += metaLengthResult.value; // Skip the rest of the meta event data
          } 
          // --- CORRECTLY SKIP UNHANDLED EVENTS ---
          else if (eventType == 0xA0 || eventType == 0xB0 || eventType == 0xE0) { // 2 data bytes
              offset += 2;
          } else if (eventType == 0xD0) { // 1 data byte
              offset += 1;
          }
          // This robustly handles all standard events, preventing the parser from desyncing.
        }
        
        // Finalize any remaining active notes
        for (final noteKey in activeNotes.keys.toList()) {
          final notePitch = noteKey & 0xFF; // Extract original note pitch
          _finalizeNote(activeNotes, noteKey, notePitch, currentTime, notes, ticksPerBeat, tempo);
        }
        
        if (notes.isNotEmpty) {
          tracks.add(MIDITrack(
            instrument: _getInstrumentName(currentProgram),
            program: currentProgram,
            notes: notes,
          ));
        }
        
        // Move to next track
        offset = trackEnd;
      } else {
        offset++;
      }
    }
    
    return MIDIData(tempo: tempo, tracks: tracks);
  }

  static void _finalizeNote(
    Map<int, _ActiveNote> activeNotes, 
    int noteKey, 
    int notePitch, 
    int currentTime, 
    List<MIDINote> notes, 
    int ticksPerBeat, 
    int tempo
  ) {
    final activeNote = activeNotes.remove(noteKey);
    if (activeNote != null) {
      final durationInTicks = currentTime - activeNote.startTime;
      final durationInBeats = durationInTicks / ticksPerBeat.toDouble();
      final durationInSeconds = durationInBeats * (60.0 / tempo);
      notes.add(MIDINote(
        pitch: notePitch,
        velocity: activeNote.velocity,
        startTime: activeNote.startTime / ticksPerBeat * (60.0/tempo),
        duration: durationInSeconds,
      ));
    }
  }

  static int _readInt16(Uint8List data, int offset) {
    return (data[offset] << 8) | data[offset + 1];
  }

  static int _readInt32(Uint8List data, int offset) {
    return (data[offset] << 24) | (data[offset + 1] << 16) | (data[offset + 2] << 8) | data[offset + 3];
  }

  static _VarIntResult _readVarInt(Uint8List data, int offset) {
    int value = 0;
    int currentOffset = offset;
    
    while (currentOffset < data.length) {
      final byte = data[currentOffset++];
      value = (value << 7) | (byte & 0x7F); // FIX: Correct bit order
      if ((byte & 0x80) == 0) break;
    }
    
    return _VarIntResult(value: value, offset: currentOffset);
  }
}

class _ActiveNote {
  final int startTime;
  final int channel;
  final int velocity;
  
  _ActiveNote({
    required this.startTime,
    required this.channel,
    required this.velocity,
  });
}

class _VarIntResult {
  final int value;
  final int offset;
  
  _VarIntResult({
    required this.value,
    required this.offset,
  });
}

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
  State<MIDIGeneratorHome> createState() => _MIDIGeneratorHomeState();
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


C4 80 1.0
D4 80 1.0
Eb4 80 1.0
F4 80 1.0


C4+Eb4+G4 90 1.0
D4+F4+Ab4 90 1.0
Eb4+G4+Bb4 90 1.0
F4+Ab4+C5 90 1.0
G4+Bb4+D5 90 1.0
Ab4+C5+Eb5 90 1.0
Bb4+D5+F5 90 1.0
C5+Eb5+G5 90 1.0

instrument: Acoustic Guitar (nylon)


C3 85 0.75
D3 85 0.75
Eb3 85 0.75
F3 85 0.75
G3 85 0.75
Ab3 85 0.75
Bb3 85 0.75
C4 85 1.5


C3+Eb3+G3 80 1.0
D3+F3+Ab3 80 1.0
Eb3+G3+Bb3 80 1.0
F3+Ab3+C4 80 1.0

instrument: Violin


C5 95 0.5
D5 95 0.5
Eb5 95 0.5
F5 95 0.5
G5 95 0.5
Ab5 95 0.5
Bb5 95 0.5
C6 95 1.0


E5 85 1.0
F5 85 1.0
G5 85 1.0
Ab5 85 1.0

instrument: Trumpet


C4 100 0.5
D4 100 0.5
Eb4 100 0.5
F4 100 0.5
G4 100 0.5
Ab4 100 0.5
Bb4 100 0.5
C5 100 1.0


C4+Eb4+G4 110 0.25
D4+F4+Ab4 110 0.25
Eb4+G4+Bb4 110 0.25
F4+Ab4+C5 110 0.25

instrument: Flute


C6 90 0.75
D6 90 0.75
Eb6 90 0.75
F6 90 0.75
G6 90 0.75
Ab6 90 0.75
Bb6 90 0.75
C7 90 1.5


E6 80 1.0
F6 80 1.0
G6 80 1.0
Ab6 80 1.0

instrument: Acoustic Grand Piano


C4+Eb4+G4+C5 95 2.0
D4+F4+Ab4+D5 95 2.0
Eb4+G4+Bb4+Eb5 95 2.0
F4+Ab4+C5+F5 95 2.0
G4+Bb4+D5+G5 95 2.0
Ab4+C5+Eb5+Ab5 95 2.0
Bb4+D5+F5+Bb5 95 2.0
C5+Eb5+G5+C6 95 3.0''';

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
      
      _checkAvailablePresets(); // ADD THIS
      
      // Initialize audio stream for playback
      _initializeAudioStream();
    } catch (e) {
      _addLog('Error loading SoundFont: $e');
    }
  }

  void _checkAvailablePresets() {
    if (_synthesizer == null) return;
    
    print('DEBUG: Checking available presets in SoundFont...');
    // Try a few common instruments to see if they work
    final testInstruments = [0, 24, 40, 56, 73]; // Piano, Guitar, Violin, Trumpet, Flute
    
    for (final program in testInstruments) {
      try {
        _synthesizer!.selectPreset(channel: 0, preset: program);
        print('DEBUG: Preset $program is available');
      } catch (e) {
        print('DEBUG: Preset $program failed: $e');
      }
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

    setState(() => _isGenerating = true); // Use the generate spinner
    _addLog('Generating audio for playback...');

    // Generate the audio file FIRST
    await _generateAudioFile();

    setState(() {
      _isGenerating = false;
      if (_currentAudioFile != null) {
        _isPlaying = true;
        _playButtonController.forward();
      }
    });

    if (_currentAudioFile != null) {
      _addLog('Starting playback...');
      // Simply play the generated file. No more timers needed here.
      await _audioPlayer.play(DeviceFileSource(_currentAudioFile!));
      // The audioplayers package can notify us when it's done.
      _audioPlayer.onPlayerComplete.first.then((_) {
        _addLog('Playback finished.');
        if (mounted) {
          _stopPlayback(); // Reset state when finished
        }
      });
    } else {
      _addLog('Failed to generate audio file for playback.');
    }
  }

  void _stopPlayback() {
    // Much simpler now
    if (_isPlaying) {
      _audioPlayer.stop();
      setState(() => _isPlaying = false);
      _playButtonController.reverse();
      _addLog('Playback stopped.');
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
      // Use the actual tempo from MIDI data
      final actualTempo = _currentMidiData!.tempo;
      _addLog('Using tempo: $actualTempo BPM');
      
      // Calculate duration using the actual tempo
      double totalDuration = 0;
      for (final track in _currentMidiData!.tracks) {
        double trackDuration = track.notes.fold(0.0, (sum, note) => sum + note.duration);
        if (trackDuration > totalDuration) {
          totalDuration = trackDuration;
        }
      }
      
      // Add some tail time
      totalDuration += 1.0;
      
      if (totalDuration <= 0) {
        _addLog('Error: No notes to play, duration is zero.');
        return;
      }

      _addLog('Rendering audio... Total duration: ${totalDuration.toStringAsFixed(2)}s');

      // Reset synthesizer state
      _synthesizer!.reset();

          // Set up instruments
    for (int i = 0; i < _currentMidiData!.tracks.length; i++) {
      final track = _currentMidiData!.tracks[i];
      print('DEBUG: Setting channel $i to program ${track.program} (${track.instrument})'); // ADD THIS
      _synthesizer!.selectPreset(channel: i, preset: track.program);
    }
      
      // Render the whole thing at once using the synthesizer directly
      final sampleRate = _synthesizerSettings.sampleRate;
      final totalSamples = (totalDuration * sampleRate).round();
      final buffer = ArrayInt16.zeros(numShorts: totalSamples);
      
      // Create timeline of events
      final events = <TimelineEvent>[];
      
      for (int trackIndex = 0; trackIndex < _currentMidiData!.tracks.length; trackIndex++) {
        final track = _currentMidiData!.tracks[trackIndex];
        
        for (final note in track.notes) {
          // Note On event - use actual start time
          events.add(TimelineEvent(
            time: note.startTime,
            type: EventType.noteOn,
            channel: trackIndex,
            pitch: note.pitch,
            velocity: note.velocity,
          ));
          
          // Note Off event - use actual start time + duration
          events.add(TimelineEvent(
            time: note.startTime + note.duration,
            type: EventType.noteOff,
            channel: trackIndex,
            pitch: note.pitch,
            velocity: 0,
          ));
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
      final path = (await getTemporaryDirectory()).path;
      final file = File('$path/$fileName');
      await file.writeAsBytes(_createWavHeader(sampleRate, totalSamples) + 
                             _arrayInt16ToBytes(buffer, totalSamples));
      
      _currentAudioFile = file.path;
      _addLog('Generated audio file: ${file.lengthSync()} bytes');
    } catch (e, st) {
      _addLog('Error generating audio file: $e\n$st');
      _currentAudioFile = null;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generate MIDI before saving!')),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully saved to $path')),
        );
      }
    } catch (e) {
      _addLog('Error saving file: $e');
    }
  }

  Future<void> _importMIDI() async {
    try {
      _addLog('Importing MIDI file...');
      
      // Use file picker to select MIDI file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mid', 'midi'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final bytes = await file.readAsBytes();
        
        _addLog('MIDI file loaded: ${file.path}');
        _addLog('File size: ${bytes.length} bytes');
        
        // Convert MIDI to text
        final text = await _convertMIDIToText(bytes);
        
        setState(() {
          _textController.text = text;
        });
        
        _addLog('MIDI converted to text successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('MIDI imported and converted to text!')),
          );
        }
      }
    } catch (e) {
      _addLog('Error importing MIDI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing MIDI: $e')),
        );
      }
    }
  }

  Future<String> _convertMIDIToText(Uint8List midiBytes) async {
    try {
      _addLog('Converting MIDI to text...');
      
      // Use the comprehensive MIDI to text converter
      final text = MIDIToTextConverter.midiDataToText(midiBytes);
      
      _addLog('Conversion completed');
      return text;
    } catch (e) {
      _addLog('Error converting MIDI: $e');
      rethrow;
    }
  }

  // Remove the old _parseMIDIFile and _convertMIDIDataToText methods
  // as they are replaced by the comprehensive MIDIToTextConverter

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
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
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                               const SizedBox(width: 12),
                               FilledButton.tonalIcon(
                                 onPressed: _importMIDI,
                                 icon: const Icon(CupertinoIcons.folder_fill),
                                 label: const Text('Import MIDI'),
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
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                              separatorBuilder: (_, __) => Divider(color: colorScheme.outline.withValues(alpha: 0.12)),
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final isError = log.contains('Error:');
                                return Text(
                                  log,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'SF Mono',
                                    color: isError ? colorScheme.error : colorScheme.onSurfaceVariant.withValues(alpha: 1.0),
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
  final double startTime; // in seconds
  final double duration; // in seconds
  MIDINote({
    required this.pitch, 
    required this.velocity, 
    required this.startTime,
    required this.duration,
  });
}

// Helper class to represent either a single note or a chord
class ChordOrNote {
  final List<int> pitches;
  final int velocity;
  final double duration;
  
  ChordOrNote({
    required this.pitches,
    required this.velocity,
    required this.duration,
  });
  
  bool get isChord => pitches.length > 1;
  
  @override
  String toString() {
    if (isChord) {
      return pitches.map((p) => _pitchToNoteName(p)).join('+');
    } else {
      return _pitchToNoteName(pitches.first);
    }
  }
  
  static String _pitchToNoteName(int pitch) {
    const noteNames = {
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
    return noteNames[pitch] ?? 'Unknown';
  }
}

class MIDITextParser {
  static const Map<String, int> noteMap = {
    'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5, 'F#': 6,
    'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
  };
  static const Map<String, int> instrumentMap = {
    'Acoustic Grand Piano': 0,
    'Bright Acoustic Piano': 1,
    'Electric Grand Piano': 2,
    'Honky-tonk Piano': 3,
    'Electric Piano 1': 4,
    'Electric Piano 2': 5,
    'Harpsichord': 6,
    'Clavi': 7,
    'Celesta': 8,
    'Glockenspiel': 9,
    'Music Box': 10,
    'Vibraphone': 11,
    'Marimba': 12,
    'Xylophone': 13,
    'Tubular Bells': 14,
    'Dulcimer': 15,
    'Drawbar Organ': 16,
    'Percussive Organ': 17,
    'Rock Organ': 18,
    'Church Organ': 19,
    'Reed Organ': 20,
    'Accordion': 21,
    'Harmonica': 22,
    'Tango Accordion': 23,
    'Acoustic Guitar (nylon)': 24,
    'Acoustic Guitar (steel)': 25,
    'Electric Guitar (jazz)': 26,
    'Electric Guitar (clean)': 27,
    'Electric Guitar (muted)': 28,
    'Overdriven Guitar': 29,
    'Distortion Guitar': 30,
    'Guitar Harmonics': 31,
    'Acoustic Bass': 32,
    'Electric Bass (finger)': 33,
    'Electric Bass (pick)': 34,
    'Fretless Bass': 35,
    'Slap Bass 1': 36,
    'Slap Bass 2': 37,
    'Synth Bass 1': 38,
    'Synth Bass 2': 39,
    'Violin': 40,
    'Viola': 41,
    'Cello': 42,
    'Contrabass': 43,
    'Tremolo Strings': 44,
    'Pizzicato Strings': 45,
    'Orchestral Harp': 46,
    'Timpani': 47,
    'String Ensemble 1': 48,
    'String Ensemble 2': 49,
    'Synth Strings 1': 50,
    'Synth Strings 2': 51,
    'Choir Aahs': 52,
    'Voice Oohs': 53,
    'Synth Voice': 54,
    'Orchestra Hit': 55,
    'Trumpet': 56,
    'Trombone': 57,
    'Tuba': 58,
    'Muted Trumpet': 59,
    'French Horn': 60,
    'Brass Section': 61,
    'Synth Brass 1': 62,
    'Synth Brass 2': 63,
    'Soprano Sax': 64,
    'Alto Sax': 65,
    'Tenor Sax': 66,
    'Baritone Sax': 67,
    'Oboe': 68,
    'English Horn': 69,
    'Bassoon': 70,
    'Clarinet': 71,
    'Piccolo': 72,
    'Flute': 73,
    'Recorder': 74,
    'Pan Flute': 75,
    'Blown Bottle': 76,
    'Shakuhachi': 77,
    'Whistle': 78,
    'Ocarina': 79,
    'Lead 1 (square)': 80,
    'Lead 2 (sawtooth)': 81,
    'Lead 3 (calliope)': 82,
    'Lead 4 (chiff)': 83,
    'Lead 5 (charang)': 84,
    'Lead 6 (voice)': 85,
    'Lead 7 (fifths)': 86,
    'Lead 8 (bass + lead)': 87,
    'Pad 1 (new age)': 88,
    'Pad 2 (warm)': 89,
    'Pad 3 (polysynth)': 90,
    'Pad 4 (choir)': 91,
    'Pad 5 (bowed)': 92,
    'Pad 6 (metallic)': 93,
    'Pad 7 (halo)': 94,
    'Pad 8 (sweep)': 95,
    'FX 1 (rain)': 96,
    'FX 2 (soundtrack)': 97,
    'FX 3 (crystal)': 98,
    'FX 4 (atmosphere)': 99,
    'FX 5 (brightness)': 100,
    'FX 6 (goblins)': 101,
    'FX 7 (echoes)': 102,
    'FX 8 (sci-fi)': 103,
    'Sitar': 104,
    'Banjo': 105,
    'Shamisen': 106,
    'Koto': 107,
    'Kalimba': 108,
    'Bagpipe': 109,
    'Fiddle': 110,
    'Shanai': 111,
    'Tinkle Bell': 112,
    'Agogo': 113,
    'Steel Drums': 114,
    'Woodblock': 115,
    'Taiko Drum': 116,
    'Melodic Tom': 117,
    'Synth Drum': 118,
    'Reverse Cymbal': 119,
    'Guitar Fret Noise': 120,
    'Breath Noise': 121,
    'Seashore': 122,
    'Bird Tweet': 123,
    'Telephone Ring': 124,
    'Helicopter': 125,
    'Applause': 126,
    'Gunshot': 127,
  };

  MIDIData parse(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);
    int tempo = 120;
    Map<String, List<ChordOrNote>> instrumentNotes = {};
    String currentInstrument = 'Acoustic Grand Piano';

    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip comment lines that start with *
      if (trimmed.startsWith('*')) {
        continue;
      }
      
      if (trimmed.startsWith('tempo:')) {
        tempo = int.tryParse(trimmed.substring(6).trim()) ?? 120;
      } else if (trimmed.startsWith('instrument:')) {
        currentInstrument = trimmed.substring(11).trim();
        print('DEBUG: Setting instrument to: $currentInstrument'); // ADD THIS
        instrumentNotes.putIfAbsent(currentInstrument, () => []);
      } else {
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          try {
            final notePart = parts[0];
            final velocity = int.parse(parts[1]);
            final durationInBeats = double.parse(parts[2]);
            // Convert from beats to seconds using tempo
            final durationInSeconds = durationInBeats * (60.0 / tempo);
            
            // Parse chord or single note
            List<int> pitches = [];
            if (notePart.contains('+')) {
              // Chord: C4+E4+G4
              final noteNames = notePart.split('+');
              print('DEBUG: Parsing chord: $notePart -> ${noteNames.length} notes');
              for (final noteName in noteNames) {
                final pitch = _parseNoteName(noteName.trim());
                pitches.add(pitch);
                print('DEBUG: Note $noteName -> pitch $pitch');
              }
            } else {
              // Single note: C4
              final pitch = _parseNoteName(notePart);
              pitches.add(pitch);
              print('DEBUG: Single note $notePart -> pitch $pitch');
            }
            
            instrumentNotes.putIfAbsent(currentInstrument, () => []);
            instrumentNotes[currentInstrument]!.add(
              ChordOrNote(pitches: pitches, velocity: velocity, duration: durationInSeconds),
            );
          } catch (e) {
            throw FormatException('Invalid note line: "$trimmed" ($e)');
          }
        }
      }
    }

    final tracks = instrumentNotes.entries.map((entry) {
      final program = instrumentMap[entry.key] ?? 0;
      print('DEBUG: Instrument "${entry.key}" -> Program $program'); // ADD THIS
      
      // Convert ChordOrNote to MIDINote with proper timing
      final midiNotes = <MIDINote>[];
      double currentTime = 0.0;
      
      for (final chordOrNote in entry.value) {
        // All notes in a chord start at the same time
        for (final pitch in chordOrNote.pitches) {
          midiNotes.add(MIDINote(
            pitch: pitch,
            velocity: chordOrNote.velocity,
            startTime: currentTime,
            duration: chordOrNote.duration,
          ));
        }
        // Move to next time position after the chord duration
        currentTime += chordOrNote.duration;
      }
      
      return MIDITrack(instrument: entry.key, program: program, notes: midiNotes);
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
      
      // Group notes by start time to handle overlapping notes (chords)
      final noteGroups = <int, List<MIDINote>>{};
      
      for (final note in track.notes) {
        // Convert start time from seconds to ticks
        final double beatsPerSecond = midiData.tempo / 60.0;
        final double startTimeInBeats = note.startTime * beatsPerSecond;
        final int startTicks = (startTimeInBeats * writer.ticksPerBeat).round();
        
        noteGroups.putIfAbsent(startTicks, () => []);
        noteGroups[startTicks]!.add(note);
      }
      
      // Add grouped notes to the writer
      for (final entry in noteGroups.entries) {
        final startTicks = entry.key;
        final notes = entry.value;
        
        for (final note in notes) {
          // Convert duration from seconds to ticks, accounting for tempo
          final double beatsPerSecond = midiData.tempo / 60.0;
          final double durationInBeats = note.duration * beatsPerSecond;
          final durationInTicks = (durationInBeats * writer.ticksPerBeat).round();
          
          writer.addNote(
            channel: i,
            pitch: note.pitch,
            velocity: note.velocity,
            startTicks: startTicks,
            endTicks: startTicks + durationInTicks,
          );
        }
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
      Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.big);
  static Uint8List _int32(int value) =>
      Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);
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


