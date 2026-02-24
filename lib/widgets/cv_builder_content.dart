import 'package:flutter/material.dart';
import 'dart:ui';

class CVBuilderContent extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onPersonalInfoTap;
  final VoidCallback onEducationTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onSkillsTap;

  const CVBuilderContent({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.onPersonalInfoTap,
    required this.onEducationTap,
    required this.onExperienceTap,
    required this.onSkillsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center( // يضمن أن المحتوى الزجاجي في المنتصف تماماً
      child: IntrinsicHeight( // يمنع التمرير غير الضروري بجعل الطول حسب المحتوى
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // يأخذ 90% من عرض الشاشة
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // التأثير الزجاجي هنا فقط وليس في كامل الصفحة
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // السطر السحري لتقليص الحجم
                  children: [
                    Text(
                      isAr ? "صانع السيرة الذاتية" : "Build Your CV",
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isAr ? "أكمل البيانات التالية لتجهيز سيرتك" : "Complete to prepare your CV",
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(height: 30),
                    
                    // الأزرار الأربعة (المحتوى الحقيقي)
                    _buildItem(isAr ? "المعلومات الشخصية" : "Personal Info", Icons.person_outline, Colors.blueAccent, onPersonalInfoTap),
                    const SizedBox(height: 12),
                    _buildItem(isAr ? "التعليم والدراسة" : "Education", Icons.school_outlined, Colors.purpleAccent, onEducationTap),
                    const SizedBox(height: 12),
                    _buildItem(isAr ? "الخبرات العملية" : "Work Experience", Icons.work_outline, Colors.greenAccent, onExperienceTap),
                    const SizedBox(height: 12),
                    _buildItem(isAr ? "المهارات واللغات" : "Skills & Languages", Icons.psychology_outlined, Colors.orangeAccent, onSkillsTap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}