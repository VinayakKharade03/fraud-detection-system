import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int totalScans = 0;
  int threats = 0;
  int safe = 0;
  int warnings = 0;
  int frauds = 0;

  List<String> activities = [];

  /// 🔥 ADD RESULT (call this after every scan)
  void addScan(String status, String type) {
    totalScans++;

    if (status == "SAFE") {
      safe++;
      activities.insert(0, "Safe $type scanned");
    } else if (status == "SUSPICIOUS") {
      warnings++;
      activities.insert(0, "Suspicious $type detected");
    } else {
      frauds++;
      threats++;
      activities.insert(0, "Fraud $type detected");
    }

    notifyListeners();
  }

  double get awareness {
    if (totalScans == 0) return 0;
    return ((safe / totalScans) * 100);
  }

  int get badges {
    return (safe ~/ 5); // simple badge logic
  }
}