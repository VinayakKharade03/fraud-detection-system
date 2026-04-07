import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  File? _image;
  Map<String, dynamic>? result;
  bool isLoading = false;

  final picker = ImagePicker();

  /// 📌 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        result = null;
      });
    }
  }

  /// 📌 ANALYZE QR
  Future<void> analyzeQR() async {
    if (_image == null) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.analyzeQR(_image!);

      final analysis = res["analysis"];
      final status = analysis?["status"] ?? "SAFE";
      final confidence = ((analysis?["risk_score"] ?? 0) / 100).toDouble();

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "QR");

      /// ✅ 🔥 SAVE TO DATABASE
      await ScanLogger.log(
        type: "QR",
        status: status,
        confidence: confidence,
      );

      setState(() {
        result = res;
      });
    } catch (e) {
      setState(() {
        result = {
          "analysis": {
            "status": "ERROR",
            "risk_score": 0,
            "reasons": ["Server error"]
          }
        };
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView( // ✅ prevents overflow
        child: Center(
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "QR Code Scanner",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 UPLOAD AREA
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.15),
                          Colors.black,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.6),
                      ),
                    ),
                    child: _image == null
                        ? const Center(
                      child: Text(
                        "Tap to upload QR image",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : analyzeQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                      "Analyze QR",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 RESULT
                if (result != null) buildResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 RESULT CARD
  Widget buildResultCard() {
    final analysis = result!["analysis"];
    final status = analysis["status"];
    final score = analysis["risk_score"];
    final reasons = analysis["reasons"];

    Color statusColor = Colors.green;
    if (status == "SUSPICIOUS") statusColor = Colors.orange;
    if (status == "FRAUD") statusColor = Colors.red;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F172A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Scan Result",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          /// RISK BAR
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Risk Score",
                  style: TextStyle(color: Colors.white)),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (score / 100).clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "$score / 100",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// REASONS
          if (reasons != null && reasons.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Analysis",
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                ...reasons.map<Widget>(
                      (r) => Text(
                    "• $r",
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            )
          else
            const Text(
              "No issues detected",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}