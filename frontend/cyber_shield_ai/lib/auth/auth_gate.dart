import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';                 // ✅ go up from auth → lib
import '../screens/login_screen.dart'; // ✅ go up then into screens

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    /// ✅ USER LOGGED IN
    if (session != null) {
      return const MainScreen();
    }

    /// ❌ NOT LOGGED IN
    return LoginScreen(
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      },
    );
  }
}