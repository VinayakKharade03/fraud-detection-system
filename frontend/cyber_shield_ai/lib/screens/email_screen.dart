import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final subjectController = TextEditingController();
  final senderController = TextEditingController();
  final bodyController = TextEditingController();
  final urlController = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? result;

  /// ✅ FIXED LOGIC HERE
  Future<void> analyzeEmail() async {
    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      /// 🔹 1. SPAM CHECK (Subject + Body)
      final spamRes = await ApiService.analyzeSpam(
        "${subjectController.text} ${bodyController.text}",
      );

      /// 🔹 2. URL CHECK
      final urlRes = await ApiService.analyzeUrl(
        urlController.text,
      );

      /// 🔹 3. EMAIL CHECK
      final emailRes = await ApiService.analyzeEmail(
        """
Subject: ${subjectController.text}
Sender: ${senderController.text}
Body: ${bodyController.text}
""",
      );

      double spamScore = (spamRes["confidence"] ?? 0).toDouble();
      double urlScore = (urlRes["confidence"] ?? 0).toDouble();
      double emailScore = (emailRes["confidence"] ?? 0).toDouble();

      String status = "SAFE";

      /// 🚨 RULE 1: ANY HIGH → FRAUD
      if (spamScore > 0.8 || urlScore > 0.8 || emailScore > 0.8) {
        status = "FRAUD";
      }

      /// 🚨 RULE 2: TWO MEDIUM → FRAUD
      else if (
      (spamScore > 0.5 && urlScore > 0.5) ||
          (spamScore > 0.5 && emailScore > 0.5) ||
          (urlScore > 0.5 && emailScore > 0.5)) {
        status = "FRAUD";
      }

      /// ⚠️ RULE 3: ONE MEDIUM → SUSPICIOUS
      else if (spamScore > 0.5 ||
          urlScore > 0.5 ||
          emailScore > 0.5) {
        status = "SUSPICIOUS";
      }

      /// ✅ CONFIDENCE = MAX SIGNAL
      double finalScore = [spamScore, urlScore, emailScore]
          .reduce((a, b) => a > b ? a : b);

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "Email");

      /// 🔥 SAVE LOG
      await ScanLogger.log(
        type: "Email",
        status: status,
        confidence: finalScore,
      );

      setState(() {
        result = {
          "status": status,
          "confidence": finalScore,
          "reasons": [
            ...?spamRes["reasons"],
            ...?urlRes["reasons"],
            ...?emailRes["reasons"],
          ]
        };
      });
    } catch (e) {
      setState(() {
        result = {
          "status": "ERROR",
          "confidence": 0,
          "reasons": ["Server error"]
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
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Email Analyzer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: buildField(subjectController, "Subject"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildField(senderController, "Sender Email"),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildField(bodyController, "Email Body", maxLines: 5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildField(urlController, "URLs", maxLines: 5),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : analyzeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Analyze Email"),
                  ),
                ),

                const SizedBox(height: 20),

                if (result != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: getColor(result!["status"])),
                      borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }

  Widget buildField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF0B0F1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}