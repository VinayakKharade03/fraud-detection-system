import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  File? _video;
  bool isLoading = false;
  Map<String, dynamic>? result;

  final picker = ImagePicker();

  /// 📌 PICK VIDEO
  Future<void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _video = File(picked.path);
        result = null;
      });
    }
  }

  /// 📌 ANALYZE VIDEO
  Future<void> analyzeVideo() async {
    if (_video == null) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.analyzeVideo(_video!);

      /// 🔥 NORMALIZE STATUS
      String status = res["status"] ?? "UNKNOWN";
      if (status == "FAKE") status = "FRAUD";

      final confidence = (res["confidence"] ?? 0).toDouble();

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "Video");

      /// ✅ 🔥 SAVE TO DATABASE
      await ScanLogger.log(
        type: "Video",
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
          "reasons": ["Server error"]
        };
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = result?["status"] ?? "";
    final confidence = (result?["confidence"] ?? 0).toDouble();
    final isFraud = status == "FAKE" || status == "FRAUD";

    return Container(
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(24),
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
                "Video Deepfake Detection",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 UPLOAD AREA
              GestureDetector(
                onTap: pickVideo,
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.15),
                        Colors.black,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.5),
                    ),
                  ),
                  child: _video == null
                      ? const Center(
                    child: Text(
                      "Tap to upload video",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                      : Stack(
                    children: [
                      /// 🎥 Preview
                      Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.play_circle_fill,
                              size: 80,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Video Selected",
                              style:
                              TextStyle(color: Colors.white70),
                            )
                          ],
                        ),
                      ),

                      /// 🔥 STATUS BADGE
                      if (result != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: buildBadge(status, isFraud),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : analyzeVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.black)
                      : const Text(
                    "Analyze Video",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

              if (result != null) ...[
                const SizedBox(height: 20),

                /// 🔥 CONFIDENCE
                buildConfidence(confidence, isFraud),

                const SizedBox(height: 15),

                /// 🔥 REASONS
                if (result!["reasons"] != null &&
                    result!["reasons"].isNotEmpty)
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text("Analysis",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),

                      ...List.generate(
                        result!["reasons"].length,
                            (i) => Text(
                          "• ${result!["reasons"][i]}",
                          style:
                          const TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  )
                else
                  const Text(
                    "No major issues detected",
                    style: TextStyle(color: Colors.grey),
                  )
              ]
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 BADGE
  Widget buildBadge(String status, bool isFraud) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isFraud ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔥 CONFIDENCE BAR
  Widget buildConfidence(double value, bool isFraud) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confidence",
            style: TextStyle(color: Colors.white)),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation(
                isFraud ? Colors.red : Colors.green),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "${(value * 100).toStringAsFixed(1)}%",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}