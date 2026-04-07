import 'package:supabase_flutter/supabase_flutter.dart';

class ScanLogger {
  static final supabase = Supabase.instance.client;

  /// =========================
  /// 🔥 LOG SCAN (INSERT)
  /// =========================
  static Future<void> log({
    required String type,
    required String status,
    double? confidence,
    String? input, // optional (future use)
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        print("No user logged in");
        return;
      }

      await supabase.from('scans').insert({
        'user_id': user.id,
        'type': type,
        'status': status, // ✅ matches DB
        'confidence': confidence ?? 0,
        'input': input, // optional column (safe even if null)
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Scan logged: $type - $status");
    } catch (e) {
      print("❌ DB Error: $e");
    }
  }

  /// =========================
  /// 📊 GET ALL SCANS
  /// =========================
  static Future<List<Map<String, dynamic>>> getScans() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return [];

      final res = await supabase
          .from('scans')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      print("📊 Fetched scans: $res");

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Fetch Error: $e");
      return [];
    }
  }

  /// =========================
  /// 📈 GET STATS (FOR DASHBOARD)
  /// =========================
  static Future<Map<String, int>> getStats() async {
    try {
      final data = await getScans();

      int safe = 0;
      int warning = 0;
      int fraud = 0;

      for (var item in data) {
        final status = item['status'];

        if (status == "SAFE") safe++;
        else if (status == "SUSPICIOUS") warning++;
        else if (status == "FRAUD") fraud++;
      }

      return {
        "safe": safe,
        "warning": warning,
        "fraud": fraud,
      };
    } catch (e) {
      print("❌ Stats Error: $e");
      return {
        "safe": 0,
        "warning": 0,
        "fraud": 0,
      };
    }
  }

  /// =========================
  /// 🧹 CLEAR USER DATA (OPTIONAL)
  /// =========================
  static Future<void> clearScans() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      await supabase
          .from('scans')
          .delete()
          .eq('user_id', user.id);

      print("🗑️ All scans deleted");
    } catch (e) {
      print("❌ Delete Error: $e");
    }
  }
}