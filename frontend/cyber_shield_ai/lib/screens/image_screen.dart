import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  bool isLoading = false;
  Map<String, dynamic>? result;

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

  /// 📌 ANALYZE IMAGE
  Future<void> analyzeImage() async {
    if (_image == null) return;

    setState(() => isLoading = true);

    final res = await ApiService.analyzeImage(_image!);

    /// ✅ DASHBOARD UPDATE
    final status = res["status"] ?? "SAFE";
    final confidence = (res["confidence"] ?? 0).toDouble();

    Provider.of<AppState>(context, listen: false)
        .addScan(status, "Image");

    /// ✅ 🔥 SAVE TO DATABASE
    await ScanLogger.log(
      type: "Image",
      status: status,
      confidence: confidence,
    );

    setState(() {
      result = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = result?["status"] ?? "";
    final confidence = (result?["confidence"] ?? 0).toDouble();
    final isFraud = status == "FAKE" || status == "FRAUD";

    return Container(
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// 🔥 IMAGE UPLOAD CARD
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.15),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
              ),
              child: _image == null
                  ? const Center(
                child: Text(
                  "Click to upload image",
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : Stack(
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),

                  /// STATUS BADGE
                  if (result != null)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                          isFraud ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 BUTTON
          ElevatedButton(
            onPressed: isLoading ? null : analyzeImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(
                  horizontal: 50, vertical: 15),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
              "Analyze Image",
              style: TextStyle(color: Colors.black),
            ),
          ),

          const SizedBox(height: 25),

          /// 🔥 RESULT
          if (result != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Confidence",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: confidence,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFraud ? Colors.red : Colors.green,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${(confidence * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 15),

                if (result!["reasons"] != null &&
                    result!["reasons"].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            )
        ],
      ),
    );
  }
}