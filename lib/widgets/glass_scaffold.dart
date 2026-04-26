import 'package:flutter/material.dart';
import 'user_info_sheet.dart';
import '../theme/royal_theme.dart';

class GlassScaffold extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool isAr;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final bool showUserIcon;
  final Widget? bottomBar;
  final Widget? floatingActionButton;

  const GlassScaffold({
    super.key,
    required this.child,
    required this.isDark,
    required this.isAr,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    this.showUserIcon = false,
    this.bottomBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = RoyalTheme.primary(isDark);
    final Color cardColor = isDark ? RoyalTheme.cardDark : RoyalTheme.cardLight;
    final Color textColor = isDark ? Colors.white : RoyalTheme.forest;

    return Scaffold(
      backgroundColor: isDark ? RoyalTheme.nightBg : RoyalTheme.dayBg,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderPillButton(
                    icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    onTap: onThemeToggle,
                    color: primary,
                    isDark: isDark,
                  ),
                  if (showUserIcon) _simpleAvatar(primary, context),
                  _HeaderPillButton(
                    label: isAr ? "EN" : "AR",
                    onTap: onLanguageToggle,
                    color: primary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(RoyalTheme.radiusOuter),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : RoyalTheme.forest.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: RoyalTheme.cardShadow(isDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(RoyalTheme.radiusOuter),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: TextTheme(
                          bodyLarge: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                          bodyMedium: TextStyle(
                            color: textColor.withValues(alpha: 0.82),
                          ),
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
      bottomNavigationBar: bottomBar,
    );
  }

  Widget _simpleAvatar(Color color, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => UserInfoSheet(
              isAr: isAr,
              isDark: isDark,
            ),
          );
        },
        customBorder: const CircleBorder(),
        child: Ink(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}

class _HeaderPillButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;

  const _HeaderPillButton({
    this.icon,
    this.label,
    required this.onTap,
    required this.color,
    required this.isDark,
  }) : assert(icon != null || label != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : RoyalTheme.forest.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: icon != null
              ? Icon(icon, color: color, size: 22)
              : Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}
