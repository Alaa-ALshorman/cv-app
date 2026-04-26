import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../theme/royal_theme.dart';
import 'cv_list_view.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onStartNewCv;
  final VoidCallback onOpenBuilder;

  const HomeTab({
    super.key,
    required this.onStartNewCv,
    required this.onOpenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final bool isDark = provider.isDarkMode;
        final bool isAr = provider.isArabic;
        final Color primary = RoyalTheme.primary(isDark);
        final bool hasCvs = provider.allCVs.isNotEmpty;
        final Color subtitleColor =
            isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.45);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    end: isAr ? Alignment.centerLeft : Alignment.centerRight,
                    colors: [
                      primary.withValues(alpha: isDark ? 0.14 : 0.1),
                      primary.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
                  border: Border.all(color: primary.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? "أهلاً بك" : "Welcome back",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${provider.userName} 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : RoyalTheme.forest,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (hasCvs) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? "السير الذاتية المحفوظة" : "Your saved CVs",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onStartNewCv,
                      style: FilledButton.styleFrom(
                        foregroundColor: primary,
                        backgroundColor: primary.withValues(alpha: isDark ? 0.18 : 0.12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
                        ),
                      ),
                      icon: Icon(Icons.add_rounded, color: primary, size: 20),
                      label: Text(
                        isAr ? "سيرة جديدة" : "New CV",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  isAr ? "ابدأ بإنشاء سيرتك الأولى" : "Start with your first CV",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: !hasCvs
                    ? _buildEmptyState(isAr, primary, isDark, onStartNewCv)
                    : CVListView(
                        isDark: isDark,
                        isAr: isAr,
                        onEditCv: onOpenBuilder,
                        onCreateFirstCv: onStartNewCv,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isAr, Color primary, bool isDark, VoidCallback onStartNewCv) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 72,
              color: primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? "لا توجد سيرات محفوظة" : "No saved CVs yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr ? "أنشئ سيرتك الاحترافية في خطوات بسيطة" : "Build a professional CV in a few steps",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black45,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onStartNewCv,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: isDark ? RoyalTheme.nightBg : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: Text(
                isAr ? "إنشاء سيرة" : "Create CV",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
