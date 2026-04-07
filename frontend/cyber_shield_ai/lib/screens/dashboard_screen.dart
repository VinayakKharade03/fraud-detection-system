import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/scan_logger.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int safe = 0;
  int warnings = 0;
  int frauds = 0;

  List<String> activities = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await ScanLogger.getScans();

      data.sort(
            (a, b) => b['created_at'].compareTo(a['created_at']),
      );

      int s = 0, w = 0, f = 0;
      List<String> acts = [];

      for (var item in data) {
        final status = item['status'];
        final type = item['type'];

        acts.add("$type → $status");

        if (status == "SAFE") s++;
        else if (status == "SUSPICIOUS") w++;
        else if (status == "FRAUD") f++;
      }

      setState(() {
        safe = s;
        warnings = w;
        frauds = f;
        activities = acts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final total = safe + warnings + frauds;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF0B0F1A),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top > 0 ? 10 : 20,
          20,
          20,
        ),

        /// ❌ NO SCROLL HERE
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your cyber command center",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// STATS
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth - 45) / 4;

                return Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    StatCard("Total Scans", "$total", Colors.cyan, cardWidth),
                    StatCard("Threats", "$frauds", Colors.red, cardWidth),
                    StatCard(
                      "Awareness",
                      total == 0
                          ? "0%"
                          : "${((safe / total) * 100).toStringAsFixed(0)}%",
                      Colors.purple,
                      cardWidth,
                    ),
                    StatCard("Badges", "0", Colors.orange, cardWidth),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// QUICK ACTIONS
            const Text(
              "Quick Actions",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth - 36) / 4;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ActionCard("Email", 2, widget.onNavigate, cardWidth),
                    ActionCard("QR", 3, widget.onNavigate, cardWidth),
                    ActionCard("URL", 4, widget.onNavigate, cardWidth),
                    ActionCard("Image", 5, widget.onNavigate, cardWidth),
                    ActionCard("Video", 6, widget.onNavigate, cardWidth),
                    ActionCard("Audio", 7, widget.onNavigate, cardWidth),
                    ActionCard("UPI", 8, widget.onNavigate, cardWidth),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            /// 🔥 GRAPH TAKES REMAINING SPACE
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: box(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Threat Distribution",
                      style: TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 10),

                    if (activities.isNotEmpty)
                      Text(
                        "Latest Scan: ${activities.first.replaceAll("→", "-")}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      )
                    else
                      const Text(
                        "No scans performed yet",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: total == 0
                          ? const Center(
                        child: Text(
                          "No data yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: safe.toDouble(),
                              color: Colors.green,
                              title: "Safe",
                            ),
                            PieChartSectionData(
                              value: warnings.toDouble(),
                              color: Colors.orange,
                              title: "Warn",
                            ),
                            PieChartSectionData(
                              value: frauds.toDouble(),
                              color: Colors.red,
                              title: "Fraud",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(20),
    );
  }
}

/// ================= STAT CARD =================
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double width;

  const StatCard(this.title, this.value, this.color, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= ACTION CARD =================
class ActionCard extends StatelessWidget {
  final String title;
  final int index;
  final Function(int) onNavigate;
  final double width;

  const ActionCard(this.title, this.index, this.onNavigate, this.width,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onNavigate(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan.withOpacity(0.25),
              Colors.blue.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}