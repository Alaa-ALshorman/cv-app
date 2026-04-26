import 'package:flutter/material.dart';
import '../theme/royal_theme.dart';

class HomeBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;
  final bool isAr;

  const HomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final Color active = RoyalTheme.primary(isDark);
    final Color inactive = isDark ? Colors.white38 : Colors.black38;
    final Color barBg = isDark
        ? RoyalTheme.cardDark.withValues(alpha: 0.97)
        : Colors.white.withValues(alpha: 0.94);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active.withValues(alpha: isDark ? 0.12 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, isAr ? "الرئيسية" : "Home", active, inactive),
          _buildNavItem(1, Icons.edit_document, isAr ? "المحرر" : "Builder", active, inactive),
          _buildNavItem(2, Icons.person_rounded, isAr ? "الحساب" : "Profile", active, inactive),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color active, Color inactive) {
    final bool selected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? active.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? active : inactive,
                size: selected ? 26 : 23,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? active : inactive,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
