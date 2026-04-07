import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  /// 🔥 INIT
  static Future<void> init() async {
    await Supabase.initialize(
      url: "https://sghduqfilwpphblrbkeb.supabase.co",
      anonKey: "sb_publishable_wkzDOY5-P50gZRxEDSRZ-A_p8KBU2Ie",
    );
  }

  /// 🔐 CHECK LOGIN
  bool get isLoggedIn => supabase.auth.currentUser != null;

  /// 🔐 LOGIN
  Future<bool> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print("LOGIN USER: ${res.user}");

      return res.user != null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  /// 🆕 SIGNUP
  Future<bool> signup(String email, String password) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      print("SIGNUP USER: ${res.user}");

      return res.user != null;
    } catch (e) {
      print("SIGNUP ERROR: $e");
      return false;
    }
  }

  /// 📩 SEND OTP
  Future<void> sendOTP(String email) async {
    await supabase.auth.signInWithOtp(email: email);
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}