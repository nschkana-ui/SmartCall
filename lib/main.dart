import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() {
  runApp(const DialerApp());
}

class DialerApp extends StatelessWidget {
  const DialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KeypadView(),
    const VoicemailView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dialpad), label: 'डायलपॅड'),
          NavigationDestination(icon: Icon(Icons.voicemail), label: 'व्हॉईसमेल'),
        ],
      ),
    );
  }
}

// ------------------- डायलपॅड -------------------
class KeypadView extends StatefulWidget {
  const KeypadView({super.key});

  @override
  State<KeypadView> createState() => _KeypadViewState();
}

class _KeypadViewState extends State<KeypadView> {
  String _number = "";

  void _add(String val) => setState(() => _number += val);
  
  void _remove() {
    if (_number.isNotEmpty) {
      setState(() => _number = _number.substring(0, _number.length - 1));
    }
  }

  Future<void> _call() async {
    if (_number.isEmpty) return;
    final Uri uri = Uri(scheme: 'tel', path: _number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _btn(String digit, String sub) {
    return InkWell(
      onTap: () => _add(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(digit, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          Text(
            _number.isEmpty ? "नंबर टाईप करा" : _number,
            style: TextStyle(
              fontSize: _number.isEmpty ? 22 : 32,
              fontWeight: FontWeight.bold,
              color: _number.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_btn('1', ''), _btn('2', 'ABC'), _btn('3', 'DEF')],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_btn('4', 'GHI'), _btn('5', 'JKL'), _btn('6', 'MNO')],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_btn('7', 'PQRS'), _btn('8', 'TUV'), _btn('9', 'WXYZ')],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_btn('*', ''), _btn('0', '+'), _btn('#', '')],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60),
              FloatingActionButton(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                onPressed: _call,
                child: const Icon(Icons.call, color: Colors.white, size: 28),
              ),
              IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 28),
                onPressed: _remove,
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ------------------- व्हॉईसमेल आणि ऑडिओ प्लेअर -------------------
class VoicemailView extends StatefulWidget {
  const VoicemailView({super.key});

  @override
  State<VoicemailView> createState() => _VoicemailViewState();
}

class _VoicemailViewState extends State<VoicemailView> {
  final AudioPlayer _player = AudioPlayer();
  final Record _record = Record();
  
  bool _isPlaying = false;
  bool _isRecording = false;
  int? _activeTrack;
  int _recordingDuration = 0;
  String? _currentRecordingPath;

  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        "name": "आई",
        "time": "काल, ५:३० PM",
        "text": "घरी येताना चहा पावडर आणि साखर घेऊन ये, विसरू नकोस.",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "isLive": false,
      },
      {
        "name": "+91 98765 43210",
        "time": "२ दिवस आधी",
        "text": "नमस्कार, तुमची डिलिव्हरी पार्सल ऑफिसमध्ये आली आहे.",
        "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        "isLive": false,
      },
    ];
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${dir.path}/voicemail_$timestamp.m4a';
        
        await _record.start(
          path: path,
          encoder: AudioEncoder.aacLc,
        );
        
        setState(() {
          _isRecording = true;
          _currentRecordingPath = path;
          _recordingDuration = 0;
        });

        // Timer for recording duration
        Future.doWhile(() async {
          if (_isRecording) {
            setState(() => _recordingDuration++);
            await Future.delayed(const Duration(seconds: 1));
            return true;
          }
          return false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording error: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _record.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _messages.insert(
            0,
            {
              "name": "आपले रेकॉर्डिंग",
              "time": DateFormat('hh:mm a').format(DateTime.now()),
              "text": "रेकॉर्ड केलेला व्हॉईसमेल",
              "url": path,
              "isLive": true,
            },
          );
          _recordingDuration = 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  void _playAudio(int index, String url) async {
    if (_isPlaying && _activeTrack == index) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() {
        _activeTrack = index;
        _isPlaying = true;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    _record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("व्हॉईसमेल (AI Voicemail)", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Recording Section
          if (_isRecording)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Column(
                children: [
                  const Text("रेकॉर्डिंग सुरू...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 8),
                  Text(_formatDuration(_recordingDuration), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text("थांबवा"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Messages List
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final item = _messages[idx];
                final playingThis = _isPlaying && _activeTrack == idx;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item["name"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(item["time"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "\"${item["text"]!}\"",
                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: () => _playAudio(idx, item["url"]!),
                              icon: Icon(playingThis ? Icons.pause : Icons.play_arrow),
                            ),
                            const SizedBox(width: 8),
                            Text(playingThis ? "ऑडिओ वाजत आहे..." : "व्हॉईस मेसेज ऐका"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.blue,
        onPressed: _isRecording ? _stopRecording : _startRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
      ),
    );
  }
}
