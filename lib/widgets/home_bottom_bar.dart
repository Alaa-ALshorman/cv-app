import 'package:flutter/material.dart';

class HomeBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;
  // أضفت المعامل isAr هنا لحل خطأ التيرمينال في الملفات التي تستدعي هذا الوجت
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
    // باليت الألوان الملكية المتناغمة مع الأخضر
    final Color activeColor = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color inactiveColor = isDark ? Colors.white38 : Colors.black38;
    final Color barBg = isDark ? const Color(0xFF002B22).withOpacity(0.95) : Colors.white.withOpacity(0.9);

    return Container(
      // جعل الشريط "طافياً" ومنفصلاً تماماً عن المربع العلوي
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.circular(35), // شكل كبسولة أنيق
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, isAr ? "الرئيسية" : "Home", activeColor, inactiveColor),
          _buildNavItem(1, Icons.edit_document, isAr ? "المحرر" : "Builder", activeColor, inactiveColor),
          _buildNavItem(2, Icons.grid_view_rounded, isAr ? "القوالب" : "Templates", activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color active, Color inactive) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // تأثير خلفية خفيف يبرز الأيقونة المختارة
          color: isSelected ? active.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? active : inactive,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? active : inactive,
                fontSize: 11,
                // استخدام w900 بدلاً من black لتجنب أخطاء التيرمينال
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}