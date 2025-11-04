import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Modes for vision response
enum GeminiVisionMode { describe, listItems }

class GeminiService {
  static final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  /// Keep history if you want continuity; it’s fine to keep as-is.
  static final List<Map<String, dynamic>> _history = [];

  static Future<String> analyzeImage({
    required String query,
    required File imageFile,
    GeminiVisionMode mode = GeminiVisionMode.describe,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception("GEMINI_API_KEY not found in .env file");
    }

    final base64Image = base64Encode(await imageFile.readAsBytes());

    // Mode-specific instruction
    final instruction = mode == GeminiVisionMode.describe
        ? "You are a helpful vision assistant. Describe the scene clearly and concisely for voice narration."
        : "You are a vision enumerator. ONLY list visible items/objects in a plain bullet list. Include simple counts if obvious. NO extra sentences or descriptions.";

    // Push a fresh turn that includes instruction + user query + image
    _history.add({
      "role": "user",
      "parts": [
        {"text": "$instruction\n\nUser request: $query"},
        {
          "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
        },
      ],
    });

    final body = jsonEncode({"contents": _history});

    final response = await http.post(
      Uri.parse("$_endpoint?key=$_apiKey"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data["candidates"] as List?;
      if (candidates == null || candidates.isEmpty) {
        return "No response from Gemini.";
      }
      final parts = candidates[0]["content"]["parts"] as List?;
      if (parts == null || parts.isEmpty) {
        return "Gemini gave no text.";
      }
      final text = parts[0]["text"] ?? "Empty response.";

      _history.add({
        "role": "model",
        "parts": [
          {"text": text},
        ],
      });

      // For list mode, do a tiny cleanup: ensure bullets
      if (mode == GeminiVisionMode.listItems) {
        final cleaned = text
            .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ')
            .trim();
        return cleaned.isEmpty ? "• (No items detected)" : cleaned;
      }

      return text;
    } else {
      throw Exception("Gemini API error: ${response.body}");
    }
  }
}
