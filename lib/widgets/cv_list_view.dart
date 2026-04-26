import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../app_provider.dart';
import '../theme/royal_theme.dart';
import '../templates/modern_cyan_template.dart';
import '../templates/royal_green_template.dart';
import '../templates/professional_template.dart';
import '../templates/classic_template.dart';
import '../templates/elegant_template.dart';
import '../templates/minimalist_template.dart';

class CVListView extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onEditCv;
  final VoidCallback onCreateFirstCv;

  const CVListView({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.onEditCv,
    required this.onCreateFirstCv,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allCVs = provider.allCVs.reversed.toList();
    final Color primary = RoyalTheme.primary(isDark);

    if (allCVs.isEmpty) {
      return _buildEmptyStateFallback(primary, isDark);
    }

    return ListView.builder(
      itemCount: allCVs.length,
      padding: const EdgeInsets.only(bottom: 12),
      itemBuilder: (context, index) {
        final cv = allCVs[index];
        final int originalIndex = provider.allCVs.length - 1 - index;

        return Dismissible(
          key: Key(cv.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async => await _showDeleteDialog(context),
          onDismissed: (direction) {
            provider.deleteCV(originalIndex);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Text(isAr ? "تم حذف السيرة الذاتية" : "CV deleted"),
              ),
            );
          },
          background: _buildDeleteBackground(isAr),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isDark ? RoyalTheme.surfaceDark : Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
                side: BorderSide(color: primary.withValues(alpha: 0.15)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
                onTap: () => _openCVPreview(context, provider, cv.templateId, cv.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.description_rounded, color: primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cv.fullName.isEmpty
                                  ? (isAr ? "سيرة بدون اسم" : "Unnamed CV")
                                  : cv.fullName,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: isAr ? TextAlign.right : TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr ? "معاينة وطباعة" : "Preview & print",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.55)
                                    : Colors.black.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: isAr ? TextAlign.right : TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: primary.withValues(alpha: 0.12),
                          foregroundColor: primary,
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 22),
                        onPressed: () {
                          provider.setActiveCvId(cv.id);
                          onEditCv();
                        },
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

  Future<void> _openCVPreview(
    BuildContext context,
    AppProvider provider,
    String? templateId,
    String cvId,
  ) async {
    final String tid = templateId ?? 'modern';

    final pdfData = await provider.withActiveCvForRender(cvId, () async {
      if (tid == 'modern') return await generateModernTemplate(provider);
      if (tid == 'royal') return await generateRoyalTemplate(provider);
      if (tid == 'pro') return await generateProfessionalTemplate(provider);
      if (tid == 'classic') return await generateClassicTemplate(provider);
      if (tid == 'elegant') return await generateElegantTemplate(provider);
      if (tid == 'minimal') return await generateMinimalistTemplate(provider);
      return await generateModernTemplate(provider);
    });

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(isAr ? "استعراض السيرة" : "CV Preview"),
            backgroundColor: RoyalTheme.forest,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: PdfPreview(
            build: (format) => pdfData,
            allowPrinting: true,
            allowSharing: true,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateFallback(Color primary, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            isAr ? "لا يوجد سيرات" : "No CVs found",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onCreateFirstCv,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: isDark ? RoyalTheme.nightBg : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
              ),
            ),
            child: Text(isAr ? "إنشاء سيرة" : "Create CV"),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground(bool isAr) {
    return Container(
      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? "تأكيد الحذف" : "Confirm delete"),
        content: Text(isAr ? "حذف هذه السيرة؟" : "Delete this CV?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? "إلغاء" : "Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(isAr ? "حذف" : "Delete"),
          ),
        ],
      ),
    );
  }
}
