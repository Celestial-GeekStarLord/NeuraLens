import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Modes for vision response
enum GeminiVisionMode { describe, listItems }

class GeminiService {
  /// 🔐 Firebase Function endpoint
  static const String _endpoint =
      "https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/analyzeImage";

  static Future<String> analyzeImage({
    required String query,
    required File imageFile,
    GeminiVisionMode mode = GeminiVisionMode.describe,
  }) async {
    final base64Image = base64Encode(await imageFile.readAsBytes());

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "query": query,
        "base64Image": base64Image,
        "mode": mode == GeminiVisionMode.listItems ? "list" : "describe",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final candidates = data["candidates"] as List?;

    if (candidates == null || candidates.isEmpty) {
      return "No response from Gemini.";
    }

    final parts = candidates[0]["content"]["parts"] as List?;
    final text = parts?[0]?["text"] ?? "Empty response.";

    if (mode == GeminiVisionMode.listItems) {
      final cleaned = text
          .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ')
          .trim();
      return cleaned.isEmpty ? "• (No items detected)" : cleaned;
    }

    return text;
  }
}
