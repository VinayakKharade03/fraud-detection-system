import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const LoginScreen({super.key, required this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();

  bool isLoading = false;
  String? error;

  /// 🔐 LOGIN
  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await auth.login(
      email.text.trim(),
      password.text.trim(),
    );

    if (success) {
      widget.onSuccess();
    } else {
      setState(() => error = "Invalid email or password");
    }

    setState(() => isLoading = false);
  }

  /// 🆕 SIGNUP
  Future<void> signup() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await auth.signup(
      email.text.trim(),
      password.text.trim(),
    );

    if (success) {
      widget.onSuccess();
    } else {
      setState(() => error = "Signup failed (user may already exist)");
    }

    setState(() => isLoading = false);
  }

  /// 📩 OTP LOGIN
  Future<void> otpLogin() async {
    if (email.text.isEmpty) {
      setState(() => error = "Enter email first");
      return;
    }

    await auth.sendOTP(email.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP sent to email")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CyberShield Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// 📧 EMAIL
              TextField(
                controller: email,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔑 PASSWORD
              TextField(
                controller: password,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              /// ❌ ERROR
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 10),

              /// 🔐 LOGIN BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  "Login",
                  style: TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 10),

              /// 🆕 SIGNUP BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 10),

              /// 📩 OTP LOGIN
              TextButton(
                onPressed: otpLogin,
                child: const Text("Login with OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}