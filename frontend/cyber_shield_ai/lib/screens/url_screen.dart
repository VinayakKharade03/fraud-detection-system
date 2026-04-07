import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart';

class URLScreen extends StatefulWidget {
  const URLScreen({super.key});

  @override
  State<URLScreen> createState() => _URLScreenState();
}

class _URLScreenState extends State<URLScreen> {
  final TextEditingController controller = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? result;

  /// 📌 ANALYZE URL
  Future<void> analyzeUrl() async {
    final url = controller.text.trim();
    if (url.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.analyzeUrl(url);

      final status = res["status"] ?? "SAFE";
      final confidence = ((res["risk_score"] ?? 0) / 100).toDouble();

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "URL");

      /// ✅ SAVE TO DATABASE
      await ScanLogger.log(
        type: "URL",
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
          "risk_score": 0,
          "reasons": ["Server error"]
        };
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = result?["status"] ?? "";
    final score = result?["risk_score"] ?? 0;
    final reasons = result?["reasons"] ?? [];

    Color statusColor = Colors.green;
    if (status == "SUSPICIOUS") statusColor = Colors.orange;
    if (status == "FRAUD") statusColor = Colors.red;
    if (status == "ERROR") statusColor = Colors.grey;

    return Container(
      width: double.infinity, // ✅ IMPORTANT FIX
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(20),

      child: SingleChildScrollView(
        child: content(context, statusColor, status, score, reasons), // ✅ FIXED
      ),
    );
  }

  /// 🔥 UI CONTENT
  Widget content(
      BuildContext context,
      Color statusColor,
      String status,
      int score,
      List reasons,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        const Text(
          "URL Detection",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        /// 🔗 INPUT BOX
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter URL (e.g. https://example.com)",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔥 ANALYZE BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : analyzeUrl,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
              "Analyze URL",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔥 RESULT CARD
        if (result != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF111827),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Result",
                      style:
                      TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                /// SCORE BAR
                const Text("Risk Score",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 6),

                LinearProgressIndicator(
                  value: (score / 100).clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),

                const SizedBox(height: 6),

                Text(
                  "$score / 100",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                /// REASONS
                if (reasons.isNotEmpty)
                  ...reasons.map<Widget>(
                        (r) => Text(
                      "• $r",
                      style:
                      const TextStyle(color: Colors.orange),
                    ),
                  )
                else
                  const Text(
                    "No major issues detected",
                    style: TextStyle(color: Colors.grey),
                  )
              ],
            ),
          )
      ],
    );
  }
}