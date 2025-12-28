import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- Need to import dotenv

/// Modes for vision response
enum GeminiVisionMode { describe, listItems }

class GeminiService {
  /// 🌐 Render backend endpoint
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  static const Duration _timeout = Duration(seconds: 60);

  static Future<String> analyzeImage({
    required String query,
    required File imageFile,
    GeminiVisionMode mode = GeminiVisionMode.describe,
  }) async {
    try {
      // 🔒 Ensure file exists
      if (!await imageFile.exists()) {
        return "Image file not found.";
      }

      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await http
          .post(
            Uri.parse("$_baseUrl/gemini-vision"),
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode({
              "query": query,
              "base64Image": base64Image,
              "mode": mode == GeminiVisionMode.listItems ? "list" : "describe",
            }),
          )
          .timeout(_timeout);

      // ❌ Backend failure
      if (response.statusCode != 200) {
        return _mapHttpError(response);
      }

      final decoded = jsonDecode(response.body);

      final candidates = decoded["candidates"];
      if (candidates == null || candidates is! List || candidates.isEmpty) {
        return "No description available.";
      }

      final content = candidates[0]["content"];
      final parts = content?["parts"];

      if (parts == null || parts is! List || parts.isEmpty) {
        return "Gemini returned an empty response.";
      }

      final text = parts[0]["text"];
      if (text == null || text.toString().trim().isEmpty) {
        return "Nothing recognizable in the image.";
      }

      // 📝 Format list mode
      if (mode == GeminiVisionMode.listItems) {
        final cleaned = text
            .toString()
            .replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ')
            .trim();
        return cleaned.isEmpty ? "• No distinct items detected" : cleaned;
      }

      return text.toString().trim();
    } on SocketException {
      return "No internet connection.";
    } on HttpException {
      return "Could not reach the server.";
    } on FormatException {
      return "Invalid response from server.";
    } on TimeoutException {
      return "Server is waking up. Please try again in a few seconds.";
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
  }

  /// 🔎 Map HTTP errors clearly
  static String _mapHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return "Invalid image or request.";
      case 401:
        return "Unauthorized request.";
      case 404:
        return "Service not found.";
      case 429:
        return "Too many requests. Please slow down.";
      case 500:
        return "Server error. Try again later.";
      default:
        return "Error ${response.statusCode}: ${response.reasonPhrase}";
    }
  }
}
