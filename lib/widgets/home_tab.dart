import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import 'cv_list_view.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isDark = provider.isDarkMode;
    final bool isAr = provider.isArabic;
    
    // الألوان الملكية الموحدة
    final Color primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الترحيب باسم المستخدم من Firebase (userName)
          Text(
            isAr ? "أهلاً بك، ${provider.userName} 👋" : "Welcome, ${provider.userName} 👋",
            style: TextStyle(
              fontSize: 24, 
              // الوزن الملكي لضمان الوضوح
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : primaryGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAr ? "سيرك الذاتية المحفوظة:" : "Your saved CVs:",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54
            ),
          ),
          const SizedBox(height: 20),
          // عرض القائمة
          Expanded(
            child: CVListView(isDark: isDark, isAr: isAr),
          ),
        ],
      ),
    );
  }
}