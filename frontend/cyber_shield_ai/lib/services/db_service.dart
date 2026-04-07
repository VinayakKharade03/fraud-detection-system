import 'package:supabase_flutter/supabase_flutter.dart';

class DBService {
  final supabase = Supabase.instance.client;

  /// 🔥 SAVE SCAN
  Future<void> saveScan({
    required String type,
    required String input,
    required String result,
    required double confidence,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('scans').insert({
      'user_id': user.id,
      'type': type,
      'input': input,
      'result': result,
      'confidence': confidence,
    });
  }

  /// 🔥 GET USER SCANS
  Future<List<Map<String, dynamic>>> getScans() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final res = await supabase
        .from('scans')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}