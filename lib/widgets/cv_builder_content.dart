import 'package:flutter/material.dart';
import 'dart:ui';

class CVBuilderContent extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onPersonalInfoTap;
  final VoidCallback onEducationTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onSkillsTap;
  final VoidCallback onBioTap;

  const CVBuilderContent({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.onPersonalInfoTap,
    required this.onEducationTap,
    required this.onExperienceTap,
    required this.onSkillsTap,
    required this.onBioTap,
  });

  @override
  Widget build(BuildContext context) {
    // توحيد اللون الأخضر الملكي المعتمد في تطبيقك
    final Color primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            // جعل العرض والارتفاع مرناً بناءً على مساحة الشاشة المتوفرة
            width: constraints.maxWidth * 0.9,
            height: constraints.maxHeight * 0.9, 
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // أيقونة علوية مصغرة قليلاً
                      Icon(Icons.auto_awesome, color: primaryGreen, size: 30),
                      const SizedBox(height: 10),
                      
                      // استخدام FittedBox لمنع النص العلوي من الخروج عن الحدود
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAr ? "منشئ السيرة الاحترافية" : "Professional CV Builder",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w900, 
                            color: isDark ? Colors.white : Colors.black87
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAr ? "أكمل خطواتك نحو وظيفة الأحلام" : "Complete the steps to your dream job",
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // استخدام Expanded لكل عنصر ليقوم بتقسيم الارتفاع المتاح بالتساوي
                      Expanded(child: _buildItem(isAr ? "المعلومات الشخصية" : "Personal Info", Icons.person_add_alt_1_outlined, primaryGreen, onPersonalInfoTap)),
                      const SizedBox(height: 10),
                      
                      Expanded(child: _buildItem(isAr ? "النبذة الشخصية" : "Professional Bio", Icons.edit_note_rounded, primaryGreen, onBioTap)),
                      const SizedBox(height: 10),
                      
                      Expanded(child: _buildItem(isAr ? "المؤهلات العلمية" : "Education Detail", Icons.school_outlined, primaryGreen, onEducationTap)),
                      const SizedBox(height: 10),
                      
                      Expanded(child: _buildItem(isAr ? "الخبرات العملية" : "Work Experiences", Icons.business_center_outlined, primaryGreen, onExperienceTap)),
                      const SizedBox(height: 10),
                      
                      Expanded(child: _buildItem(isAr ? "المهارات واللغات" : "Skills & Languages", Icons.psychology_outlined, primaryGreen, onSkillsTap)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            
            // Expanded مع FittedBox يضمنان بقاء النص داخل الزر مهما كان صغيراً
            Expanded(
              child: FittedBox(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  title, 
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87, 
                    fontSize: 15, 
                    fontWeight: FontWeight.w600
                  )
                ),
              ),
            ),
            
            const SizedBox(width: 5),
            Icon(isAr ? Icons.chevron_left : Icons.chevron_right, color: Colors.grey.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}