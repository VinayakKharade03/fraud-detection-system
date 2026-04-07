import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/scan_logger.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final merchant = TextEditingController();
  final amt = TextEditingController();
  final gender = TextEditingController();
  final lat = TextEditingController();
  final longi = TextEditingController();
  final merchLat = TextEditingController();
  final merchLong = TextEditingController();
  final day = TextEditingController();
  final month = TextEditingController();
  final hour = TextEditingController();

  // ✅ NEW: Selected Category
  String? selectedCategory;

  bool isLoading = false;
  Map<String, dynamic>? result;

  /// 🔥 CATEGORY PICKER (SCROLLABLE)
  void showCategoryPicker() {
    final List<String> categories = [
      "misc_net",
      "grocery_pos",
      "entertainment",
      "gas_transport",
      "misc_pos",
      "grocery_net",
      "shopping_net",
      "shopping_pos",
      "food_dining",
      "personal_care",
      "health_fitness",
      "travel",
      "kids_pets",
      "home",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];

              return ListTile(
                title: Text(
                  cat.replaceAll("_", " ").toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = cat;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> analyze() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.analyzeTransaction({
        "merchant": merchant.text,
        "category": selectedCategory ?? "", // ✅ UPDATED
        "amt": double.tryParse(amt.text) ?? 0,
        "gender": gender.text,
        "lat": double.tryParse(lat.text) ?? 0,
        "long": double.tryParse(longi.text) ?? 0,
        "merch_lat": double.tryParse(merchLat.text) ?? 0,
        "merch_long": double.tryParse(merchLong.text) ?? 0,
        "day": int.tryParse(day.text) ?? 1,
        "month": int.tryParse(month.text) ?? 1,
        "hour": int.tryParse(hour.text) ?? 12,
      });

      final isFraud = res["fraud"] == true;
      final status = isFraud ? "FRAUD" : "SAFE";
      final confidence = (res["confidence"] ?? 0).toDouble();

      Provider.of<AppState>(context, listen: false)
          .addScan(status, "Transaction");

      await ScanLogger.log(
        type: "Transaction",
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
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildField(merchant, "Merchant"),

            /// ✅ NEW CATEGORY SELECTOR
            GestureDetector(
              onTap: showCategoryPicker,
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Text(
                  selectedCategory == null
                      ? "Select Category"
                      : selectedCategory!
                      .replaceAll("_", " ")
                      .toUpperCase(),
                  style: TextStyle(
                    color: selectedCategory == null
                        ? Colors.grey
                        : Colors.white,
                  ),
                ),
              ),
            ),

            buildField(amt, "Amount"),
            buildField(gender, "Gender (M/F)"),
            buildField(lat, "Latitude"),
            buildField(longi, "Longitude"),
            buildField(merchLat, "Merchant Lat"),
            buildField(merchLong, "Merchant Long"),
            buildField(day, "Day"),
            buildField(month, "Month"),
            buildField(hour, "Hour"),

            const SizedBox(height: 20),

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
                "Analyze Transaction",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 25),

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
                    const Text("Confidence",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: confidence,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade800,
                      valueColor:
                      AlwaysStoppedAnimation(getColor(status)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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