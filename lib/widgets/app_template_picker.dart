import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import '../app_provider.dart';
import '../templates/modern_cyan_template.dart';
import '../templates/royal_green_template.dart';
import '../templates/classic_template.dart';
import '../templates/elegant_template.dart';
import '../templates/minimalist_template.dart';
import '../templates/professional_template.dart';

List<Map<String, dynamic>> buildTemplateCatalog(bool isAr) {
  return [
    {'id': 'modern', 'name': isAr ? 'القالب العصري' : 'Modern', 'image': 'assets/templates/temp1.png', 'color': Colors.cyan},
    {'id': 'royal', 'name': isAr ? 'القالب الملكي' : 'Royal', 'image': 'assets/templates/temp2.png', 'color': const Color(0xFF1B5E20)},
    {'id': 'classic', 'name': isAr ? 'الكلاسيكي' : 'Classic', 'image': 'assets/templates/temp3.png', 'color': Colors.grey},
    {'id': 'elegant', 'name': isAr ? 'الأنيق' : 'Elegant', 'image': 'assets/templates/temp4.png', 'color': Colors.purple},
    {'id': 'minimal', 'name': isAr ? 'البسيط' : 'Minimalist', 'image': 'assets/templates/temp6.png', 'color': Colors.black},
    {'id': 'pro', 'name': isAr ? 'الاحترافي' : 'Professional', 'image': 'assets/templates/temp5.png', 'color': Colors.blueGrey},
  ];
}

Future<Uint8List> _pdfForId(String id, AppProvider provider) async {
  if (id == 'modern') return await generateModernTemplate(provider);
  if (id == 'royal') return await generateRoyalTemplate(provider);
  if (id == 'classic') return await generateClassicTemplate(provider);
  if (id == 'elegant') return await generateElegantTemplate(provider);
  if (id == 'minimal') return await generateMinimalistTemplate(provider);
  if (id == 'pro') return await generateProfessionalTemplate(provider);
  return await generateModernTemplate(provider);
}

Future<void> _openTemplatePreview(
  BuildContext context,
  AppProvider provider,
  String templateId,
  String displayName,
  bool isAr,
) async {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final data = await _pdfForId(templateId, provider);
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!context.mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 16)),
            backgroundColor: const Color(0xFF1B5E20),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              TextButton.icon(
                onPressed: () {
                  provider.applyTemplateToCurrentCv(templateId);
                  Navigator.of(context)..pop()..pop();
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  isAr ? "حفظ" : "Save",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => data,
            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: "${provider.userName.replaceAll(' ', '_')}_CV.pdf",
            maxPageWidth: 700,
          ),
        ),
      ),
    );
  } catch (_) {
    if (context.mounted) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAr ? "خطأ في تحميل القالب" : "Error loading template")),
        );
      }
    }
  }
}

Future<void> showBuilderTemplateSelector(
  BuildContext context, {
  bool createDraftIfMissing = true,
}) async {
  final provider = context.read<AppProvider>();
  if (provider.currentCV == null) {
    if (!createDraftIfMissing) {
      if (context.mounted) {
        final isAr = provider.isArabic;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? "أنشئ أو افتح سيرة من (المُنشئ) أولاً"
                  : "Create or open a CV in the Builder tab first",
            ),
          ),
        );
      }
      return;
    }
  }
  if (createDraftIfMissing) {
    provider.ensureDraftForBuilder();
  }
  if (!context.mounted) return;

  final isDark = provider.isDarkMode;
  final isAr = provider.isArabic;
  final primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
  final catalog = buildTemplateCatalog(isAr);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: isDark ? const Color(0xFF002B22) : const Color(0xFFE8F5E9),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        initialChildSize: 0.6,
        builder: (c, sc) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isAr ? "اختر قالب السيرة" : "Choose a CV template",
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? "اضغط قالباً لمعاينته، ثم احفظ." : "Tap a template to preview, then save.",
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    controller: sc,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: catalog.length,
                    itemBuilder: (c, i) {
                      final temp = catalog[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openTemplatePreview(
                          c,
                          provider,
                          temp['id'] as String,
                          temp['name'] as String,
                          isAr,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF002B32) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    temp['image'] as String,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stack) => Center(
                                      child: Icon(
                                        Icons.insert_drive_file,
                                        size: 36,
                                        color: (temp['color'] as Color).withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              temp['name'] as String,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
