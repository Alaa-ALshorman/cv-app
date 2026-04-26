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
import '../widgets/app_template_picker.dart';
import 'profile_page.dart';

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
      showUserIcon: false,
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
            onStartNewCv: () {
              provider.startNewCvDraft();
              setState(() => _currentIndex = 1);
            },
            onOpenBuilder: () {
              setState(() => _currentIndex = 1);
            },
          ),

          CVBuilderContent(
            isDark: provider.isDarkMode,
            isAr: provider.isArabic,
            onTemplateTap: () => showBuilderTemplateSelector(context),
            onPersonalInfoTap: () => _showSheet(
              context,
              PersonalSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            onBioTap: () => _showSheet(
              context,
              BioSheet(isDark: provider.isDarkMode, isAr: provider.isArabic),
            ),
            onEducationTap: () => _showSheet(
              context,
              EducationSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            onExperienceTap: () => _showSheet(
              context,
              ExperienceSheet(
                isDark: provider.isDarkMode,
                isAr: provider.isArabic,
              ),
            ),
            onSkillsTap: () => _showSheet(
              context,
              SkillsSheet(isDark: provider.isDarkMode, isAr: provider.isArabic),
            ),
          ),

          ProfilePage(
            isDark: provider.isDarkMode,
            isAr: provider.isArabic,
            onThemeToggle: () => provider.toggleTheme(),
            onLanguageToggle: () => provider.toggleLanguage(),
          ),
        ],
      ),
    );
  }
}
