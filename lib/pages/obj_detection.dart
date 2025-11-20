/*

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  late CameraController _cameraController;
  late Interpreter _interpreter;
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  int _frameCount = 0;
  double _fps = 0;

  List<Map<String, dynamic>> _detections = [];
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLabels();
    await _initCamera();
    await _loadModel();
  }

  Future<void> _loadLabels() async {
    final labelData = await rootBundle.loadString('assets/models/labels.txt');
    setState(() {
      _labels = labelData.split('\n');
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    await _cameraController.startImageStream(_processCameraImage);
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('models/detect.tflite');
    setState(() => _isModelLoaded = true);
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isModelLoaded || _isDetecting) return;
    _isDetecting = true;

    final startTime = DateTime.now();

    try {
      // Convert camera image (YUV) to model input (RGB)
      var input = _convertYUV420ToRGB(image, 300, 300);

      // Prepare output tensors
      var outputLocations = List.generate(
        1 * 10 * 4,
        (_) => 0.0,
      ).reshape([1, 10, 4]);
      var outputClasses = List.generate(1 * 10, (_) => 0.0).reshape([1, 10]);
      var outputScores = List.generate(1 * 10, (_) => 0.0).reshape([1, 10]);
      var numDetections = List.generate(1, (_) => 0.0).reshape([1]);

      var outputs = {
        0: outputLocations,
        1: outputClasses,
        2: outputScores,
        3: numDetections,
      };

      // Run inference
      _interpreter.runForMultipleInputs([input], outputs);

      List<Map<String, dynamic>> results = [];
      for (int i = 0; i < outputScores[0].length; i++) {
        double score = outputScores[0][i];
        if (score > 0.5) {
          int classIndex = outputClasses[0][i].toInt();
          String label = classIndex < _labels.length
              ? _labels[classIndex]
              : "Unknown";
          results.add({
            "class": label,
            "score": score,
            "rect": {
              "ymin": outputLocations[0][i][0],
              "xmin": outputLocations[0][i][1],
              "ymax": outputLocations[0][i][2],
              "xmax": outputLocations[0][i][3],
            },
          });
        }
      }

      final endTime = DateTime.now();
      final elapsed = endTime.difference(startTime).inMilliseconds;
      _fps = 1000 / elapsed;

      setState(() => _detections = results);
    } catch (e) {
      debugPrint("Detection error: $e");
    }

    _isDetecting = false;
  }

  List<List<List<List<double>>>> _convertYUV420ToRGB(
    CameraImage image,
    int targetWidth,
    int targetHeight,
  ) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        targetHeight,
        (_) => List.generate(targetWidth, (_) => List.filled(3, 0.0)),
      ),
    );

    // Downscale to 300x300 (naive nearest neighbor)
    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final px = (x * width / targetWidth).floor();
        final py = (y * height / targetHeight).floor();
        final uvIndex =
            uvPixelStride * (px / 2).floor() + uvRowStride * (py / 2).floor();

        final yp = image.planes[0].bytes[py * width + px];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        double r = yp + vp * 1436 / 1024 - 179;
        double g = yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91;
        double b = yp + up * 1814 / 1024 - 227;

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        input[0][y][x][0] = r / 255.0;
        input[0][y][x][1] = g / 255.0;
        input[0][y][x][2] = b / 255.0;
      }
    }

    return input;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detection"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          ..._detections.map((d) {
            final rect = d["rect"];
            final width = MediaQuery.of(context).size.width;
            final height = MediaQuery.of(context).size.height;

            return Positioned(
              left: rect["xmin"] * width,
              top: rect["ymin"] * height,
              width: (rect["xmax"] - rect["xmin"]) * width,
              height: (rect["ymax"] - rect["ymin"]) * height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${d["class"]} ${(d["score"] * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      backgroundColor: Colors.black54,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              color: Colors.black54,
              child: Text(
                "FPS: ${_fps.toStringAsFixed(1)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/
