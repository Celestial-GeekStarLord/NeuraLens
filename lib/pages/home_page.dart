import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../widgets/neural_background.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _cameraInitialized = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastHeard = '';
  String _geminiText = '';
  bool _processing = false;
  bool _showResponse = false;

  final FlutterTts _tts = FlutterTts();

  late AnimationController _glowController;
  late AnimationController _particleController;

  /// NEW: mode toggle — false = describe, true = list items
  bool _listMode = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initCamera();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = widget.cameras.first; // 👈 use cameras from widget
      _cameraController = CameraController(backCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _cameraInitialized = true);
    } catch (e) {
      _showSnack("Camera error: $e");
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() => _lastHeard = result.recognizedWords);
        },
      );
    } else {
      _showSnack("Speech recognition not available");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_lastHeard.isNotEmpty) {
      _captureAndAskGemini(_lastHeard);
    }
  }

  Future<void> _captureAndAskGemini(String query) async {
    if (!_cameraInitialized || _cameraController == null) {
      _showSnack("Camera not ready.");
      return;
    }

    setState(() {
      _processing = true;
      _geminiText = '';
    });

    try {
      final picture = await _cameraController!.takePicture();

      final answer = await GeminiService.analyzeImage(
        mode: _listMode
            ? GeminiVisionMode.listItems
            : GeminiVisionMode.describe,
        query: query.isNotEmpty
            ? query
            : (_listMode
                  ? "List the items visible in the scene."
                  : "Describe the scene in detail."),
        imageFile: File(picture.path),
      );

      if (!mounted) return;
      setState(() {
        _geminiText = answer;
        _showResponse = true;
      });

      await _tts.stop();
      await _tts.speak(answer);
    } catch (e) {
      if (!mounted) return;
      setState(() => _geminiText = "⚠️ $e");
      _showSnack("Error: $e");
    } finally {
      if (!mounted) return;
      setState(() => _processing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _speech.stop();
    _tts.stop();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.cyanAccent, // 👈 changes drawer (hamburger) icon color
        ),
        title: Text(
          "NeuraLens",
          style: TextStyle(
            fontFamily: "OldEnglishTextMT",
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 158, 77, 11),
            shadows: const [
              Shadow(color: Color.fromARGB(255, 2, 2, 2), blurRadius: 8),
              Shadow(color: Color.fromARGB(255, 0, 0, 0), blurRadius: 8),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Animated Neural Background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: NeuralBackgroundPainter(
                  progress: _particleController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          /// Camera Preview
          if (_cameraInitialized)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      70,
                      184,
                      41,
                    ).withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        57,
                        216,
                        208,
                      ).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          /// Response Box
          if (_showResponse)
            Positioned(
              bottom: 200,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.85),
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      189,
                      98,
                      14,
                    ).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        196,
                        114,
                        8,
                      ).withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _processing ? "🔮 Thinking..." : _geminiText,
                    style: GoogleFonts.cormorantGaramond(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          /// Status Hint Bar (shows mode too)
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.6)),
                ),
                child: Text(
                  _processing
                      ? "Analyzing Image… • Mode: ${_listMode ? "List" : "Describe"}"
                      : _isListening
                      ? "Listening… • Mode: ${_listMode ? "List" : "Describe"}"
                      : "Idle • Mode: ${_listMode ? "List" : "Describe"}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ),

          /// Controls Row (mode toggle • mic • response toggle)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 👈 spreads them out
                children: [
                  // 🧭 Mode Toggle (left of mic)
                  GestureDetector(
                    onTap: () {
                      setState(() => _listMode = !_listMode);
                      _showSnack(
                        _listMode
                            ? "List Mode: only items will be listed."
                            : "Describe Mode: full scene description.",
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _listMode
                            ? const LinearGradient(
                                colors: [Colors.tealAccent, Colors.cyan],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  Colors.deepPurpleAccent,
                                  Colors.indigo,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: _listMode
                                ? Colors.tealAccent.withOpacity(0.7)
                                : Colors.deepPurpleAccent.withOpacity(0.7),
                            blurRadius: 25,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedScale(
                        scale: _listMode ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          _listMode
                              ? Icons.format_list_bulleted
                              : Icons.article,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // 🎙 Mic Button (center)
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        // oscillates between 0.4 → 1.0 glow intensity
                        double glow = (_glowController.value * 0.6) + 0.2;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _isListening
                                ? const LinearGradient(
                                    colors: [
                                      Colors.redAccent,
                                      Colors.deepOrange,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [Colors.blueAccent, Colors.cyan],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isListening
                                            ? Colors.redAccent
                                            : Colors.cyanAccent)
                                        .withOpacity(
                                          glow,
                                        ), // 👈 pulsating intensity
                                blurRadius: 40 * glow, // 👈 expands/contracts
                                spreadRadius: 6 * glow,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              _isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              key: ValueKey<bool>(_isListening),
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 📖 Response Toggle (right of mic)
                  GestureDetector(
                    onTap: () {
                      setState(() => _showResponse = !_showResponse);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _showResponse
                            ? const LinearGradient(
                                colors: [Colors.redAccent, Colors.deepOrange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Colors.greenAccent, Colors.teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: _showResponse
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.greenAccent.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          final rotate = Tween(
                            begin: pi,
                            end: 0.0,
                          ).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (context, child) {
                              final isUnder =
                                  (ValueKey(_showResponse) != child!.key);
                              var tilt = (animation.value - 0.5).abs() - 0.5;
                              tilt *= isUnder
                                  ? -0.003
                                  : 0.003; // little perspective
                              return Transform(
                                transform: Matrix4.rotationY(rotate.value)
                                  ..setEntry(3, 0, tilt),
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                          );
                        },
                        child: Icon(
                          _showResponse
                              ? Icons.menu_book
                              : Icons.menu_book_outlined,
                          key: ValueKey<bool>(_showResponse),
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Color.fromARGB(255, 245, 247, 246)],
              ),
            ),
            child: Text(
              "NeuraLens Menu",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.cyanAccent),
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            // Intentionally no navigation: you're already on Home.
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.cyanAccent),
            title: const Text(
              "About Us",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushNamed(context, "/about"),
          ),
          ListTile(
            leading: const Icon(Icons.memory, color: Colors.cyanAccent),
            title: const Text(
              "Neural Insights",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushNamed(context, "/insights"),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.cyanAccent),
            title: const Text(
              "Settings",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushNamed(context, "/settings"),
          ),
          ListTile(
            leading: const Icon(
              Icons.rocket_launch_sharp,
              color: Colors.cyanAccent,
            ),
            title: const Text(
              "Your Thoughts",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/feedback"),
          ),
        ],
      ),
    );
  }
}
