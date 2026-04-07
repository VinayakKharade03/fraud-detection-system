import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class SpamScreen extends StatefulWidget {
  const SpamScreen({super.key});

  @override
  State<SpamScreen> createState() => _SpamScreenState();
}

class _SpamScreenState extends State<SpamScreen> {
  final TextEditingController controller = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? result;

  Future<void> analyzeSpam() async {
    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final res = await ApiService.analyzeSpam(controller.text);

      /// 🔥 GET STATUS + CONFIDENCE
      final status = res["status"] ?? "SAFE";
      final confidence = (res["confidence"] ?? 0).toDouble();

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "Spam");

      /// ✅ 🔥 SAVE TO DATABASE
      await ScanLogger.log(
        type: "Spam",
        status: status,
        confidence: confidence,
      );

      setState(() {
        result = res;
      });
    } catch (e) {
      setState(() {
        result = {
          "status": "ERROR",
          "confidence": 0,
          "reasons": ["Server connection failed"]
        };
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Color getColor(String status) {
    switch (status) {
      case "SAFE":
        return Colors.green;
      case "SUSPICIOUS":
        return Colors.orange;
      case "FRAUD":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView( // ✅ prevents overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spam Detection",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// INPUT
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter message...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : analyzeSpam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Analyze"),
            ),

            const SizedBox(height: 30),

            /// RESULT
            if (result != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: getColor(result!["status"])),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result!["status"],
                      style: TextStyle(
                        color: getColor(result!["status"]),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Confidence: ${(result!["confidence"] * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 10),

                    ...List.generate(
                      result!["reasons"].length,
                          (i) => Text(
                        "• ${result!["reasons"][i]}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}