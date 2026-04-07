import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  File? _audio;
  bool isLoading = false;
  Map<String, dynamic>? result;

  Future<void> pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (res != null) {
      setState(() {
        _audio = File(res.files.single.path!);
        result = null;
      });
    }
  }

  Future<void> analyzeAudio() async {
    if (_audio == null) return;

    setState(() => isLoading = true);

    final res = await ApiService.analyzeAudio(_audio!);

    final status = res["status"] ?? "SAFE";
    final confidence = (res["confidence"] ?? 0).toDouble();

    /// ✅ DASHBOARD
    Provider.of<AppState>(context, listen: false)
        .addScan(status, "Audio");

    /// ✅ 🔥 DATABASE SAVE
    await ScanLogger.log(
      type: "Audio",
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

      /// ✅ FIX overflow on small screens
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: pickAudio,
              child: Container(
                height: 240,
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
                child: _audio == null
                    ? const Center(
                  child: Text(
                    "Click to upload audio",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.graphic_eq,
                          size: 60,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            30,
                                (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 4,
                              height: (i % 7 + 2) * 8,
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

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

                    if (result != null)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFraud ? Colors.red : Colors.green,
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

            ElevatedButton(
              onPressed: isLoading ? null : analyzeAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                "Analyze Audio",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 25),

            if (result != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Confidence",
                    style: TextStyle(color: Colors.white),
                  ),
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
                ],
              )
          ],
        ),
      ),
    );
  }
}