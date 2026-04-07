import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/app_state.dart';
import 'services/auth_service.dart';

import 'package:cyber_shield_ai/screens/login_screen.dart';

import 'screens/dashboard_screen.dart';
import 'screens/email_screen.dart';
import 'screens/spam_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/url_screen.dart';

// MEDIA
import 'screens/image_screen.dart';
import 'screens/video_screen.dart';
import 'screens/audio_screen.dart';

// FINANCE
import 'screens/upi_screen.dart';
import 'screens/transaction_screen.dart';

// 🤖 AI
import 'screens/ai_screen.dart';

// 📜 HISTORY
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const FraudDetectionApp(),
    ),
  );
}

class FraudDetectionApp extends StatelessWidget {
  const FraudDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberShield AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

/// 🔐 AUTH GATE
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return auth.isLoggedIn
        ? const MainScreen()
        : LoginScreen(
      onSuccess: () => setState(() {}),
    );
  }
}

/// 🧠 MAIN APP
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  final auth = AuthService();

  void navigate(int index) {
    setState(() => selectedIndex = index);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigate: navigate),
      const SpamScreen(),
      const EmailScreen(),
      const QRScreen(),
      const URLScreen(),
      const ImageScreen(),
      const VideoScreen(),
      const AudioScreen(),
      const UPIScreen(),
      const TransactionScreen(),
      const AIScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      /// ✅ CHANGE: Drawer now works on ALL screens (mobile + desktop)
      drawer: Drawer(child: sidebar()),

      body: Column(
        children: [
          /// TOP BAR
          SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFF0B0F1A),
              child: Row(
                children: [
                  /// MENU BUTTON (always visible now)
                  Builder(
                    builder: (context) => IconButton(
                      icon:
                      const Icon(Icons.menu, color: Colors.white),
                      onPressed: () =>
                          Scaffold.of(context).openDrawer(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    "🛡 CyberShield AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }

  /// SIDEBAR (UNCHANGED)
  Widget sidebar() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            buildNavItem("Dashboard", 0),
            buildNavItem("Spam Detection", 1),
            buildNavItem("Email Analyzer", 2),
            buildNavItem("QR Scanner", 3),
            buildNavItem("URL Detection", 4),

            const Divider(),

            buildNavItem("Image Deepfake", 5),
            buildNavItem("Video Deepfake", 6),
            buildNavItem("Audio Deepfake", 7),

            const Divider(),

            buildNavItem("UPI Fraud", 8),
            buildNavItem("Transaction Fraud", 9),

            const Divider(),

            buildNavItem("AI Assistant", 10),
            buildNavItem("History", 11),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () async {
                  await auth.logout();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem(String title, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => navigate(index),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        color: isSelected
            ? Colors.cyan.withOpacity(0.2)
            : Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.cyan : Colors.white,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}