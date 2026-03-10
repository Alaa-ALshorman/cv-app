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
import '../widgets/bio_sheet.dart';
import 'templates_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return GlassScaffold(
      isDark: provider.isDarkMode,
      isAr: provider.isArabic,
      onThemeToggle: () => provider.toggleTheme(),
      onLanguageToggle: () => provider.toggleLanguage(),
      showUserIcon: true,
      bottomBar: HomeBottomBar(
        currentIndex: _currentIndex,
        isDark: provider.isDarkMode,
        isAr: provider.isArabic,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      child: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onAddNew: () {
              provider.currentCVIndexSet = -1; // تصفير المؤشر لإنشاء سيرة جديدة
              setState(() => _currentIndex = 1);
            },
          ),

          CVBuilderContent(
            isDark: provider.isDarkMode,
            isAr: provider.isArabic,
            // 1. المعلومات الشخصية
            onPersonalInfoTap: () => _showSheet(
              context,
              PersonalSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            // 2. النبذة المهنية
            onBioTap: () => _showSheet(
              context,
              BioSheet(isDark: provider.isDarkMode, isAr: provider.isArabic),
            ),
            // 3. التعليم
            onEducationTap: () => _showSheet(
              context,
              EducationSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            // 4. الخبرات
            onExperienceTap: () => _showSheet(
              context,
              ExperienceSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            // 5. المهارات
            onSkillsTap: () => _showSheet(
              context,
              SkillsSheet(isDark: provider.isDarkMode, isAr: provider.isArabic),
            ),
          ),

          TemplatesContent(
            isDark: provider.isDarkMode,
            isAr: provider.isArabic,
          ),
        ],
      ),
    );
  }
}
