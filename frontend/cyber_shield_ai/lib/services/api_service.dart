import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.222.25.62:8000";

  /// =========================
  /// 📧 EMAIL ANALYZER
  /// =========================
  static Future<Map<String, dynamic>> analyzeEmail(String text) async {
    final res = await http.post(
      Uri.parse("$baseUrl/email/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    return jsonDecode(res.body);
  }

  /// =========================
  /// 💬 SPAM DETECTION
  /// =========================
  static Future<Map<String, dynamic>> analyzeSpam(String text) async {
    final res = await http.post(
      Uri.parse("$baseUrl/spam/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": text}),
    );

    return jsonDecode(res.body);
  }

  /// =========================
  /// 🔗 URL DETECTION
  /// =========================
  static Future<Map<String, dynamic>> analyzeUrl(String url) async {
    final res = await http.post(
      Uri.parse("$baseUrl/phishing-url/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"url": url}),
    );

    return jsonDecode(res.body);
  }

  /// =========================
  /// 🔳 QR SCANNER
  /// =========================
  static Future<Map<String, dynamic>> analyzeQR(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/qr/"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    return jsonDecode(resBody);
  }

  /// =========================
  /// 🖼 IMAGE DEEPFAKE
  /// =========================
  static Future<Map<String, dynamic>> analyzeImage(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/image/"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    return jsonDecode(resBody);
  }

  /// =========================
  /// 🎥 VIDEO DEEPFAKE
  /// =========================
  static Future<Map<String, dynamic>> analyzeVideo(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/video/"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    return jsonDecode(resBody);
  }

  /// =========================
  /// 🎵 AUDIO DEEPFAKE
  /// =========================
  static Future<Map<String, dynamic>> analyzeAudio(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/audio/"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    return jsonDecode(resBody);
  }

  /// =========================
  /// 💳 UPI FRAUD
  /// =========================
  static Future<Map<String, dynamic>> analyzeUPI({
    required String sender,
    required String receiver,
    required double amount,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/upi-check"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "transaction_id": "TXN123456",
        "date": "2026-01-01",
        "sender_upi": sender,
        "receiver_upi": receiver,
        "amount": amount,
      }),
    );

    return jsonDecode(res.body);
  }

  /// =========================
  /// 🧾 TRANSACTION FRAUD
  /// =========================
  static Future<Map<String, dynamic>> analyzeTransaction(
      Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  //// =========================
  /// 🤖 AI FRAUD ASSISTANT (BACKEND)
  /// =========================
  static Future<String> askFraudAssistant(String message) async {
    final res = await http.post(
      Uri.parse("$baseUrl/ai"), // 🔥 backend endpoint
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message, // ✅ sending message properly
      }),
    );

    print("AI STATUS: ${res.statusCode}");
    print("AI BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("AI API Failed");
    }

    final data = jsonDecode(res.body);

    return data["response"] ?? "No response";
  }

  /// 🔁 WRAPPER (KEEP FOR UI)
  static Future<String> askAI(String message) async {
    return await askFraudAssistant(message);
  }}