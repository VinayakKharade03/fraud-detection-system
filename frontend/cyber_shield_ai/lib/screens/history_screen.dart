import 'package:flutter/material.dart';
import '../services/scan_logger.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> scans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await ScanLogger.getScans();

    setState(() {
      scans = data;
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

  String formatDate(String? date) {
    if (date == null) return "";
    final d = DateTime.parse(date).toLocal();
    return "${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0F1A),
      padding: const EdgeInsets.all(20),

      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scans.isEmpty
          ? const Center(
        child: Text(
          "No scan history yet",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: scans.length,
        itemBuilder: (context, i) {
          final item = scans[i];

          final type = item["type"] ?? "Unknown";
          final status = item["status"] ?? "UNKNOWN";
          final confidence =
          ((item["confidence"] ?? 0) * 100).toStringAsFixed(1);
          final date = formatDate(item["created_at"]);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: getColor(status)),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                /// LEFT SIDE
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style:
                      const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                /// RIGHT SIDE
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: getColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$confidence%",
                      style:
                      const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}