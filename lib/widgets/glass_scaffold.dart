import 'package:flutter/material.dart';
import 'user_info_sheet.dart'; // تأكدي من استيراد ملف معلومات المستخدم

class GlassScaffold extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool isAr;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final bool showUserIcon;
  final Widget? bottomBar;

  const GlassScaffold({
    super.key,
    required this.child,
    required this.isDark,
    required this.isAr,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    this.showUserIcon = false,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    // 1. باليت الألوان الملكية (Royal Green Palette)
    final Color dayBg = const Color(0xFFA5D6A7); 
    final Color nightBg = const Color(0xFF001A15);

    final Color primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color cardColor = isDark ? const Color(0xFF002B22) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: isDark ? nightBg : dayBg,
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر العلوي - الأيقونات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر الثيم
                  _headerIcon(
                    icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    onTap: onThemeToggle,
                    color: primaryGreen,
                  ),

                  // أيقونة المستخدم (الآن أصبحت قابلة للضغط!)
                  if (showUserIcon) _simpleAvatar(primaryGreen, context),

                  // زر اللغة
                  _headerIcon(
                    text: isAr ? "EN" : "AR",
                    onTap: onLanguageToggle,
                    color: primaryGreen,
                  ),
                ],
              ),
            ),

            // المربع الرئيسي (شكل الحبة - Capsule Shape)
            Expanded(
              child: Container(
                width: double.infinity,
                // المسافة (Margin) التي طلبناها ليفصل عن القائمة السفلية
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 20), 
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(55), // انحناء كامل وفخم
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 40, 25, 30),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: TextTheme(
                          bodyLarge: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18),
                          bodyMedium: TextStyle(color: textColor.withOpacity(0.8)),
                        ),
                      ),
                      child: child, 
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // القائمة السفلية العائمة
      bottomNavigationBar: bottomBar, 
    );
  }

  // دالة الأيقونات العلوية
  Widget _headerIcon({IconData? icon, String? text, required VoidCallback onTap, required Color color}) {
    return IconButton(
      onPressed: onTap,
      icon: icon != null 
        ? Icon(icon, color: color, size: 28) 
        : Text(text!, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
    );
  }

  // دالة الأفاتار مع ميزة الضغط وفتح الصفحة الشخصية
  Widget _simpleAvatar(Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // فتح نافذة معلومات المستخدم (UserInfoSheet)
        showDialog(
          context: context,
          builder: (context) => UserInfoSheet(
            isAr: isAr,
            isDark: isDark,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.person_rounded, color: color, size: 22),
        ),
      ),
    );
  }
}