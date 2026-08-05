import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team_project/constants.dart';


/// Home page with recorder, notes list, search bar
class Voice_to_text extends StatefulWidget {
  const Voice_to_text({Key? key}) : super(key: key);

  @override
  State<Voice_to_text> createState() => _Voice_to_textState();
}

class _Voice_to_textState extends State<Voice_to_text> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _transcribedText = '';
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late Box _notesBox;
  List<Map> _notes = [];
  List<Map> _filteredNotes = [];
  FToast? fToast;

  // neon glow animation for mic button
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast!.init(context);
    _notesBox = Hive.box('notesBox');
    _loadNotes();
    _initSpeech();
    _searchController.addListener(_applySearch);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        // no-op - we will show toast on error
      },
    );
    setState(() {});
  }

  void _loadNotes() {
    _notes = [];
    final keys = _notesBox.keys.cast<String>().toList();
    // keys are timestamps string
    for (var k in keys) {
      final stored = _notesBox.get(k);
      // stored is Map
      if (stored != null && stored is Map) {
        _notes.add(Map<String, dynamic>.from(stored));
      }
    }
    // sort descending
    _notes.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    _filteredNotes = List.from(_notes);
    setState(() {});
  }

  void _applySearch() {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes.where((n) {
        final text = (n['text'] as String).toLowerCase();
        final ts = DateFormat('dd MMM yyyy, hh:mm a').format(n['timestamp'] as DateTime).toLowerCase();
        return text.contains(q) || ts.contains(q);
      }).toList();
    }
    setState(() {});
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showToast('Microphone permission denied. Please enable it in settings.');
    }
  }

  Future<void> _startOrStopListening() async {
    // ensure permission
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await _requestMicPermission();
      return;
    }

    if (!_speechAvailable) {
      _showToast('Speech service unavailable on this device.');
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'notListening' || val == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (err) {
          setState(() => _isListening = false);
          _showToast('Speech recognition error');
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          _transcribedText = '';
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _transcribedText = result.recognizedWords;
              _noteController.text = _transcribedText;
              _noteController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _noteController.text.length));
            });
          },
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
        );
      } else {
        _showToast('Speech recognition not available.');
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _saveNoteFromController() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      _showToast('Note is empty.');
      return;
    }
    final now = DateTime.now();
    final key = now.millisecondsSinceEpoch.toString();

    final note = {
      'id': key,
      'text': text,
      'timestamp': now,
    };
    await _notesBox.put(key, note);
    _noteController.clear();
    _showToast('Saved to NoteVault');
    _loadNotes();
  }

  Future<void> _deleteNote(String id) async {
    await _notesBox.delete(id);
    _showToast('Note deleted');
    _loadNotes();
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showToast('Copied to clipboard');
  }

  Future<void> _shareNote(String text) async {
    await Share.share(text);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: cardColor, // Using the new theme color
      textColor: onPrimaryWhite,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // formatted timestamp
  String _prettyTimestamp(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Widget _buildMicButton() {
    // glowing neon ring when listening
    return GestureDetector(
      onTap: _startOrStopListening,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
        child: Container(
          height: 78,
          width: 78,
          decoration: BoxDecoration(
            gradient: _isListening
                ? RadialGradient(
                colors: [micGlowColor, micGlowColor.withOpacity(0.2)], // Neon blue glow
                center: Alignment.center,
                radius: 0.9)
                : null,
            color: _isListening ? accentBlue : cardColor, // Dark card background when not listening
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isListening ? micGlowColor.withOpacity(0.3) : Colors.black.withOpacity(0.6),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: _isListening ? micGlowColor : cardColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 36,
            // White icon when not listening, black/dark color when glowing
            color: _isListening ? darkBackgroundColor : onPrimaryWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice to Text Converter',
                // Use theme.textTheme.headlineLarge for the title
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20, color: onPrimaryWhite) ?? 
                       GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: onPrimaryWhite),
              ),
              const SizedBox(height: 4),
              Text(
                'Smart Voice Notes', 
                style: GoogleFonts.spaceGrotesk(fontSize: 12, color: secondaryTextColor),
              ),
            ],
          ),
        ),
        // pulse mic
        _buildMicButton(),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      // The background color is now handled by the MaterialApp's InputDecorationTheme.fillColor
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.8), 
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: onPrimaryWhite),
            decoration: const InputDecoration(
              hintText: 'Speak or type your note here...',
              // input decoration is handled by the theme in main.dart
              fillColor: Colors.transparent, // Ensure inner fill is transparent here
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // ElevatedButton uses theme style
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
                onPressed: _saveNoteFromController,
              ),
              const SizedBox(width: 10),
              // OutlinedButton uses theme style
              OutlinedButton.icon(
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                onPressed: () {
                  _noteController.clear();
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (_transcribedText.isNotEmpty) {
                    _noteController.text = _transcribedText;
                    _noteController.selection = TextSelection.fromPosition(TextPosition(offset: _noteController.text.length));
                    _showToast('Inserted latest transcription');
                  } else {
                    _showToast('No transcription available');
                  }
                },
                icon: const Icon(Icons.keyboard_double_arrow_down_outlined),
                color: secondaryTextColor,
                tooltip: 'Use latest transcription',
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // Uses the global InputDecorationTheme
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search notes, timestamps, or text...',
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
          },
        )
            : null,
      ),
    );
  }

  Widget _buildNoteTile(Map note) {
    final id = note['id'] as String;
    final text = note['text'] as String;
    final timestamp = note['timestamp'] as DateTime;
    final preview = text.length > 120 ? '${text.substring(0, 120)}…' : text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Slidable(
        closeOnScroll: true,
        key: ValueKey(id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6,
          children: [
            SlidableAction(
              onPressed: (ctx) async => _copyToClipboard(text),
              backgroundColor: cardColor.withOpacity(0.8),
              foregroundColor: accentBlue,
              icon: Icons.copy,
              label: 'Copy',
            ),
            SlidableAction(
              onPressed: (ctx) async => _shareNote(text),
              backgroundColor: cardColor,
              foregroundColor: micGlowColor, // Use a secondary accent for variety
              icon: Icons.share,
              label: 'Share',
            ),
            SlidableAction(
              onPressed: (ctx) async {
                await _deleteNote(id);
              },
              backgroundColor: const Color(0xFFC62828), // Deep Red for Delete
              foregroundColor: onPrimaryWhite,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor, // Use theme card color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(preview, style: const TextStyle(fontSize: 14, height: 1.35, color: onPrimaryWhite)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(_prettyTimestamp(timestamp),
                      style: const TextStyle(fontSize: 12, color: secondaryTextColor)), // Secondary text color
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showFullNoteDialog(note),
                    icon: const Icon(Icons.open_in_full, size: 18),
                    color: secondaryTextColor,
                    tooltip: 'Open',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFullNoteDialog(Map note) {
    final text = note['text'] as String;
    final ts = note['timestamp'] as DateTime;
    showDialog(
        context: context,
        builder: (ctx) {
          // Dialog uses the theme's DialogTheme and TextButtonTheme
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Note', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(_prettyTimestamp(ts), style: const TextStyle(color: secondaryTextColor)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          await _copyToClipboard(text);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await _shareNote(text);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _filteredNotes.isEmpty;
    return Scaffold(
      appBar: AppBar(
        // Background and elevation are now set in main.dart
        title: _buildHeader(context),
        toolbarHeight: 90, // Give space for the custom header/mic button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            children: [
              _buildInputArea(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.note_outlined, size: 68, color: secondaryTextColor.withOpacity(0.2)),
                          const SizedBox(height: 10),
                          const Text('No notes yet', style: TextStyle(color: secondaryTextColor)),
                          const SizedBox(height: 8),
                          const Text('Press the mic and start speaking to create a note.',
                              style: TextStyle(color: secondaryTextColor), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredNotes.length,
                      itemBuilder: (ctx, idx) {
                        final note = _filteredNotes[idx];
                        return _buildNoteTile(note);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      // small floating hint to show mic status
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.8), // Using card color for bottom bar
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(_isListening ? Icons.graphic_eq : Icons.mic_none,
                color: _isListening ? micGlowColor : secondaryTextColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isListening ? 'Listening... speak now' : 'Tap mic to start voice input',
                style: const TextStyle(color: secondaryTextColor),
              ),
            ),
            if (_transcribedText.isNotEmpty)
              IconButton(
                onPressed: () {
                  _noteController.text = _transcribedText;
                  _noteController.selection = TextSelection.fromPosition(TextPosition(offset: _noteController.text.length));
                },
                icon: const Icon(Icons.arrow_downward),
                color: secondaryTextColor,
                tooltip: 'Insert latest transcription',
              ),
          ],
        ),
      ), 
    );
  }
}