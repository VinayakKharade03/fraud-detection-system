import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF0B0F1A),
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// 🔷 Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield, color: Colors.cyan),
              SizedBox(width: 8),
              Text(
                "CyberShield",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 30),

          /// 🔹 Menu Items
          _buildItem(Icons.dashboard, "Dashboard", 0),
          _buildItem(Icons.smart_toy, "Assistant", 1),

          /// Analyze Section Title
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Analyze",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          _buildItem(Icons.email, "Email", 2),
          _buildItem(Icons.link, "URL / QR", 3),
          _buildItem(Icons.mic, "Audio", 4),
          _buildItem(Icons.image, "Image", 5),
          _buildItem(Icons.videocam, "Video", 6),

          const SizedBox(height: 20),

          _buildItem(Icons.school, "Awareness", 7),
          _buildItem(Icons.bar_chart, "Reports", 8),
          _buildItem(Icons.help_outline, "Help", 9),

          const Spacer(),

          /// 👤 User Section
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.cyan,
                  child: Text("N"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "User Name",
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 🔧 Sidebar Item Widget
  Widget _buildItem(IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyan.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.cyan : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}