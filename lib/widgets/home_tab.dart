import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import 'cv_list_view.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onAddNew; 
  const HomeTab({super.key, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer هنا لضمان إعادة بناء الشاشة فوراً عند أي تغيير في الـ Provider
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final bool isDark = provider.isDarkMode;
        final bool isAr = provider.isArabic;
        final Color primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);

        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? "أهلاً بك، ${provider.userName} 👋" : "Welcome, ${provider.userName} 👋",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  color: isDark ? Colors.white : primaryGreen
                ),
              ),
              const SizedBox(height: 10),
              
              // عرض النص بناءً على وجود سير ذاتية أو عدمها
              Text(
                provider.allCVs.isEmpty 
                    ? (isAr ? "ابدأ بإنشاء سيرتك الأولى الآن" : "Start creating your first CV now")
                    : (isAr ? "سيرك الذاتية المحفوظة:" : "Your saved CVs:"),
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: isDark ? Colors.white70 : Colors.black54
                ),
              ),
              const SizedBox(height: 20),
              
              // التحكم في ما يظهر في الـ Expanded
              Expanded(
                child: provider.allCVs.isEmpty 
                    ? _buildEmptyState(isAr, primaryGreen) // شكل جميل إذا كانت القائمة فارغة
                    : CVListView(isDark: isDark, isAr: isAr, onAddNew: onAddNew),
              ),
            ],
          ),
        );
      },
    );
  }

  // ودجت بسيط يظهر عندما لا توجد سير ذاتية
  Widget _buildEmptyState(bool isAr, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 80, color: color.withOpacity(0.4)),
          const SizedBox(height: 15),
          Text(
            isAr ? "لا يوجد سير ذاتية محفوظة بعد" : "No saved CVs yet",
            style: TextStyle(color: color.withOpacity(0.6), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}