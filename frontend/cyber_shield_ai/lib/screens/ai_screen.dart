import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, String>> chat = [];
  bool isLoading = false;

  final suggestions = [
    "How to spot a phishing email?",
    "Is this UPI payment safe?",
    "What to do if I'm scammed?",
    "How do deepfake calls work?",
    "Tips for safe online banking"
  ];

  /// ================= ASK AI =================
  Future<void> askAI([String? text]) async {
    final query = text ?? controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      chat.add({"role": "user", "text": query});
      controller.clear();
      isLoading = true;
    });

    _scrollToBottom();

    try {
      final res = await ApiService.askAI(query);
      setState(() {
        chat.add({"role": "bot", "text": res});
      });
    } catch (e) {
      setState(() {
        chat.add({"role": "bot", "text": "Error"});
      });
    }

    setState(() => isLoading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),

      /// INPUT BAR
      bottomNavigationBar: _buildInputBar(),

      body: SafeArea(
        child: Column(
          children: [

            /// ================= HEADER =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Color(0xFF111827),
                    child: Icon(Icons.shield, color: Colors.cyan),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CyberShield Assistant",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                          "AI cybersecurity advisor for India",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// ================= BODY =================
  Widget _buildBody() {
    return chat.isEmpty ? _buildIntro() : _buildChat();
  }

  /// ================= INTRO =================
  Widget _buildIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _iconBox(),

            const SizedBox(height: 24),

            const Text(
              "Ask me about cyber safety",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            const Text(
              "UPI fraud, phishing, deepfakes — I'm your Indian cybersecurity guide.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions.map(_chip).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CHAT =================
  Widget _buildChat() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chat.length,
      itemBuilder: (_, i) {
        final msg = chat[i];
        final isUser = msg["role"] == "user";

        return Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
              isUser ? Colors.cyan : const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              msg["text"]!,
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// ================= INPUT =================
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFF05070D),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => askAI(),
                decoration: const InputDecoration(
                  hintText: "Ask about cybersecurity, scams...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.cyan,
            child: IconButton(
              onPressed: isLoading ? null : () => askAI(),
              icon: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
                  : const Icon(Icons.arrow_upward,
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  /// ================= CHIP =================
  Widget _chip(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => askAI(text),
        splashColor: Colors.cyan.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// ================= ICON =================
  Widget _iconBox() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.lightbulb,
          color: Colors.white, size: 42),
    );
  }
}