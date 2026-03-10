import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart'; 
import '../app_provider.dart';

// --- استيراد دوال توليد الـ PDF ---
import '../templates/modern_cyan_template.dart';
import '../templates/royal_green_template.dart';
import '../templates/professional_template.dart';
import '../templates/classic_template.dart';
import '../templates/elegant_template.dart';
import '../templates/minimalist_template.dart';

class CVListView extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onAddNew;

  const CVListView({
    super.key, 
    required this.isDark, 
    required this.isAr, 
    required this.onAddNew
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // --- التعديل 1: ترتيب السير من الأحدث للأقدم ---
    final allCVs = provider.allCVs.reversed.toList(); 
    
    final Color primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);

    if (allCVs.isEmpty) {
      return _buildEmptyState(primaryGreen);
    }

    return ListView.builder(
      itemCount: allCVs.length,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemBuilder: (context, index) {
        final cv = allCVs[index];
        // ملاحظة: عند الحذف نحتاج الـ index الحقيقي من القائمة الأصلية
        final int originalIndex = provider.allCVs.length - 1 - index;
        
        return Dismissible(
          key: Key(cv.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _showDeleteDialog(context);
          },
          onDismissed: (direction) {
            provider.deleteCV(originalIndex);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isAr ? "تم حذف السيرة الذاتية" : "CV deleted"))
            );
          },
          background: _buildDeleteBackground(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF003D33) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryGreen.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 5, 
                  offset: const Offset(0, 2)
                )
              ],
            ),
            // --- التعديل 2: تصميم أفقي أنيق بـ Row بدلاً من ListTile ---
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                _openCVPreview(context, provider, cv.templateId);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryGreen.withOpacity(0.1),
                      radius: 22,
                      child: Icon(Icons.description_rounded, color: primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cv.fullName.isEmpty ? (isAr ? "سيرة بدون اسم" : "Unnamed CV") : cv.fullName, 
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black, 
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isAr ? "اضغط للمعاينة والطباعة" : "Tap to preview & print", 
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_note_rounded, color: primaryGreen, size: 28),
                      onPressed: () {
                        provider.currentCVIndex = originalIndex; 
                        onAddNew(); 
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openCVPreview(BuildContext context, AppProvider provider, String? templateId) async {
    dynamic pdfData;

    if (templateId == 'modern') pdfData = await generateModernTemplate(provider);
    else if (templateId == 'royal') pdfData = await generateRoyalTemplate(provider);
    else if (templateId == 'pro') pdfData = await generateProfessionalTemplate(provider);
    else if (templateId == 'classic') pdfData = await generateClassicTemplate(provider);
    else if (templateId == 'elegant') pdfData = await generateElegantTemplate(provider);
    else if (templateId == 'minimal') pdfData = await generateMinimalistTemplate(provider);

    if (pdfData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(isAr ? "استعراض السيرة" : "CV Preview"),
              backgroundColor: const Color(0xFF1B5E20),
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
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(isAr ? "لا يوجد سير ذاتية حالياً" : "No CVs found yet"),
          const SizedBox(height: 25),
          ElevatedButton(onPressed: onAddNew, child: Text(isAr ? "إنشاء أول سيرة" : "Create New")),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
      child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? "تأكيد الحذف" : "Confirm"),
        content: Text(isAr ? "حذف السيرة؟" : "Delete CV?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(isAr ? "إلغاء" : "No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}