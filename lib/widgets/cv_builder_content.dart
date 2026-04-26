import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../theme/royal_theme.dart';
import 'app_template_picker.dart';

class CVBuilderContent extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onTemplateTap;
  final VoidCallback onPersonalInfoTap;
  final VoidCallback onEducationTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onSkillsTap;
  final VoidCallback onBioTap;

  const CVBuilderContent({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.onTemplateTap,
    required this.onPersonalInfoTap,
    required this.onEducationTap,
    required this.onExperienceTap,
    required this.onSkillsTap,
    required this.onBioTap,
  });

  String _labelForTemplate(String? id) {
    if (id == null || id.isEmpty) {
      return isAr ? "مطلوب — اختر أولاً" : "Required — select first";
    }
    for (final m in buildTemplateCatalog(isAr)) {
      if (m['id'] == id) return m['name'] as String;
    }
    return isAr ? "محدد" : "Selected";
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = RoyalTheme.primary(isDark);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            width: constraints.maxWidth * 0.9,
            height: constraints.maxHeight * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.34),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : RoyalTheme.forest.withValues(alpha: 0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.auto_awesome, color: primaryGreen, size: 30),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAr ? "منشئ السيرة" : "CV builder",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAr ? "اختر القالب ثم املأ بياناتك" : "Choose a template, then fill in your details",
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Consumer<AppProvider>(
                          builder: (context, p, _) {
                            final bool unlocked = p.isCurrentCvContentReady;
                            return Column(
                              children: [
                                _buildTemplateCard(
                                  primaryGreen,
                                  isDark,
                                  p.currentCV?.templateId,
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Opacity(
                                    opacity: unlocked ? 1 : 0.42,
                                    child: IgnorePointer(
                                      ignoring: !unlocked,
                                      child: ListView(
                                        children: [
                                          _buildItem(
                                            isAr ? "المعلومات الشخصية" : "Personal info",
                                            Icons.person_add_alt_1_outlined,
                                            primaryGreen,
                                            isDark,
                                            onPersonalInfoTap,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildItem(
                                            isAr ? "النبذة الشخصية" : "Professional bio",
                                            Icons.edit_note_rounded,
                                            primaryGreen,
                                            isDark,
                                            onBioTap,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildItem(
                                            isAr ? "المؤهلات العلمية" : "Education",
                                            Icons.school_outlined,
                                            primaryGreen,
                                            isDark,
                                            onEducationTap,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildItem(
                                            isAr ? "الخبرات العملية" : "Work experience",
                                            Icons.business_center_outlined,
                                            primaryGreen,
                                            isDark,
                                            onExperienceTap,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildItem(
                                            isAr ? "المهارات واللغات" : "Skills & languages",
                                            Icons.psychology_outlined,
                                            primaryGreen,
                                            isDark,
                                            onSkillsTap,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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

  Widget _buildTemplateCard(Color primaryGreen, bool isDark, String? templateId) {
    return Material(
      color: isDark
          ? primaryGreen.withValues(alpha: 0.1)
          : const Color(0xFFE8F5E9).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTemplateTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryGreen.withValues(alpha: 0.5), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.palette_outlined, color: primaryGreen, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? "قالب السيرة" : "CV template",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labelForTemplate(templateId),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: (templateId == null || templateId.isEmpty)
                            ? (isAr ? Colors.orangeAccent : const Color(0xFFEF6C00))
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: (templateId == null || templateId.isEmpty) ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isAr ? Icons.chevron_left : Icons.chevron_right,
                color: primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              isAr ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.grey.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
