import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart'; // ✅ NEW

class UPIScreen extends StatefulWidget {
  const UPIScreen({super.key});

  @override
  State<UPIScreen> createState() => _UPIScreenState();
}

class _UPIScreenState extends State<UPIScreen> {
  final txnId = TextEditingController();
  final date = TextEditingController();
  final sender = TextEditingController();
  final receiver = TextEditingController();
  final amount = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? result;

  Future<void> analyze() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.analyzeUPI(
        sender: sender.text,
        receiver: receiver.text,
        amount: double.tryParse(amount.text) ?? 0,
      );

      /// 🔥 CONVERT BACKEND → STATUS
      final isFraud = res["fraud"] == true;
      final status = isFraud ? "FRAUD" : "SAFE";
      final confidence = (res["risk_score"] ?? 0) / 100;

      /// 🔥 UPDATE DASHBOARD
      Provider.of<AppState>(context, listen: false)
          .addScan(status, "UPI");

      /// ✅ 🔥 SAVE TO DATABASE
      await ScanLogger.log(
        type: "UPI",
        status: status,
        confidence: confidence,
      );

      setState(() {
        result = {
          "status": status,
          "confidence": confidence
        };
      });
    } catch (e) {
      setState(() {
        result = {
          "status": "ERROR",
          "confidence": 0
        };
      });
    }

    setState(() => isLoading = false);
  }

  Color getColor(String status) {
    switch (status) {
      case "SAFE":
        return Colors.green;
      case "FRAUD":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = result?["status"] ?? "";
    final confidence = (result?["confidence"] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF0B0F1A),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildField(txnId, "Transaction ID"),
            buildField(date, "Date (YYYY-MM-DD)"),
            buildField(sender, "Sender UPI"),
            buildField(receiver, "Receiver UPI"),
            buildField(amount, "Amount"),

            const SizedBox(height: 20),

            /// 🔥 BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                "Check Fraud",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 25),

            /// 🔥 RESULT
            if (result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: getColor(status)),
                  color: const Color(0xFF111827),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: getColor(status),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Risk Confidence",
                      style: TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 6),

                    LinearProgressIndicator(
                      value: confidence,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation(
                        getColor(status),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${(confidence * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget buildField(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF111827),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}