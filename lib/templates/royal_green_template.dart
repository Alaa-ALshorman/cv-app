import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateRoyalTemplate(AppProvider provider) async {
  final pdf = pw.Document();

  // تحميل الخطوط العربية لضمان ظهور النصوص بشكل صحيح
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  // تجهيز الصورة الشخصية من المسار المخزن في الـ Provider
  pw.ImageProvider? profileImage;
  if (provider.profileImagePath != null && provider.profileImagePath!.isNotEmpty) {
    profileImage = pw.MemoryImage(File(provider.profileImagePath!).readAsBytesSync());
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Directionality(
            // تحديد اتجاه النص بناءً على لغة المستخدم لضمان التناسق
            textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Row(
              children: [
                // 1. الجانب الأخضر الملكي (Sidebar)
                pw.Container(
                  width: 210,
                  color: const PdfColor.fromInt(0xFF1B5E20), // اللون الأخضر الغامق
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 30),
                      // إطار الصورة الدائري (حل مشكلة CircleAvatar)
                      pw.Container(
                        width: 110,
                        height: 110,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                          image: profileImage != null 
                              ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover) 
                              : null,
                        ),
                        child: profileImage == null 
                            ? pw.Center(child: pw.Text("Photo", style: const pw.TextStyle(color: PdfColors.grey))) 
                            : null,
                      ),
                      pw.SizedBox(height: 20),
                      // ربط الاسم المحدث حقيقياً
                      pw.Text(provider.userName, 
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text(provider.jobTitle, 
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                      
                      pw.SizedBox(height: 40),
                      // معلومات التواصل
                      _buildSidebarItem(provider.email),
                      _buildSidebarItem(provider.phone),
                      
                      pw.SizedBox(height: 40),
                      pw.Text(provider.isArabic ? "المهارات" : "Skills", 
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(color: PdfColors.white),
                      // حل مشكلة withOpacity في قسم المهارات
                      pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: provider.skills.map((skill) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white, 
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(skill, style: const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                // 2. المحتوى الأساسي (Main Content)
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(provider.isArabic ? "الملخص المهني" : "Summary"),
                        pw.SizedBox(height: 10),
                        // حل مشكلة lineHeight المتسببة في الخطأ
                        pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 11)),
                        
                        pw.SizedBox(height: 30),
                        _buildSectionHeader(provider.isArabic ? "الخبرات العملية" : "Work Experience"),
                        pw.Divider(color: const PdfColor.fromInt(0xFF1B5E20), thickness: 1.5),
                        // ربط قائمة الخبرات الحقيقية من الـ Provider
                        ...provider.experiences.map((exp) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(exp['position'] ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 11, color: PdfColor.fromInt(0xFF1B5E20))),
                              pw.Text(exp['duration'] ?? "", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  return pdf.save();
}

// دالات مساعدة لتقليل تكرار الكود
pw.Widget _buildSectionHeader(String title) {
  return pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1B5E20)));
}

pw.Widget _buildSidebarItem(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Text(text, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
  );
}