import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/home_tab.dart'; 
import '../widgets/cv_builder_content.dart';
import '../widgets/personal_info_sheet.dart'; 
import '../widgets/education_sheet.dart';
import '../widgets/experience_sheet.dart';
import '../widgets/skills_sheet.dart';
import 'templates_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // إعادة الألوان التي صممتِها: Cyan لليلي و Pink للنهاري
    final Color primaryAccent = provider.isDarkMode ? const Color(0xFF00E5FF) : Colors.pinkAccent;

    return GlassScaffold(
      isDark: provider.isDarkMode,
      isAr: provider.isArabic,
      showUserIcon: true,
      // كبسات القائمة العلوية تعمل الآن مع الثيم الخاص بكِ
      onThemeToggle: () => provider.toggleTheme(),
      onLanguageToggle: () => provider.toggleLanguage(),
      
      bottomBar: HomeBottomBar(
        currentIndex: _currentIndex,
        isDark: provider.isDarkMode,
        isAr: provider.isArabic,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      
      child: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeTab(), 

          CVBuilderContent(
            isDark: provider.isDarkMode,
            isAr: provider.isArabic,
            onPersonalInfoTap: () => _openSheet(
              context, 
              PersonalSheet(isDark: provider.isDarkMode, isAr: provider.isArabic) // تم تعديل الاسم ليطابق كودك
            ),
            onEducationTap: () => _openSheet(
              context, 
              EducationSheet(isDark: provider.isDarkMode, isAr: provider.isArabic)
            ),
            onExperienceTap: () => _openSheet(
              context, 
              ExperienceSheet(isDark: provider.isDarkMode, isAr: provider.isArabic)
            ),
            onSkillsTap: () => _openSheet(
              context, 
              SkillsSheet(isDark: provider.isDarkMode, isAr: provider.isArabic)
            ),
          ),

          TemplatesContent(isDark: provider.isDarkMode, isAr: provider.isArabic),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }
}