import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomConvexNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const CustomConvexNavBar({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23243A) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: GNav(
          gap: 8,
          backgroundColor: Colors.transparent,
          color: isDark ? Colors.white70 : Colors.grey[500],
          tabBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          selectedIndex: selectedIndex,
          onTabChange: onTap,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Accueil',
            ),
            GButton(
              icon: Icons.quiz,
              text: 'Quiz',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Param',
            ),
          ],
        ),
      ),
    );
  }
}
