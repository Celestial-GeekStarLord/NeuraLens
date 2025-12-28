import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart';
import '../widgets/neural_background.dart';

class OCRPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const OCRPage({super.key, required this.cameras});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _processing = false;

  String _recognizedText = '';
  bool _showText = false;

  final FlutterTts _tts = FlutterTts();
  late AnimationController _bgController;

  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  void initState() {
    super.initState();
    _initCamera();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  Future<void> _initCamera() async {
    try {
      final cam = widget.cameras.first;
      _cameraController = CameraController(cam, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _cameraReady = true);
    } catch (e) {
      _showSnack("Camera error: $e");
    }
  }

  Future<void> _captureAndReadText() async {
    if (!_cameraReady || _cameraController == null) return;

    setState(() {
      _processing = true;
      _recognizedText = '';
    });

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(image.path));
      final recognized = await _textRecognizer.processImage(inputImage);

      String text = recognized.text.trim();
      if (text.isEmpty) {
        text = "No readable text detected.";
      }

      setState(() {
        _recognizedText = text;
        _showText = true;
      });

      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      _showSnack("OCR failed: $e");
    } finally {
      setState(() => _processing = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _tts.stop();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "OCR Vision",
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Neural Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return CustomPaint(
                painter: NeuralBackgroundPainter(progress: _bgController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          /// Camera Preview
          if (_cameraReady)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
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

          /// OCR Result Box
          if (_showText)
            Positioned(
              bottom: 180,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _processing ? "Reading text…" : _recognizedText,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          /// Capture Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTap: _processing ? null : _captureAndReadText,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.7),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _processing ? Icons.hourglass_top : Icons.document_scanner,
                    color: Colors.black,
                    size: 42,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
