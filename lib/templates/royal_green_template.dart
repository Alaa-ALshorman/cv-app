import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateRoyalTemplate(AppProvider provider) async {
  final pdf = pw.Document();

  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  // --- جلب صورة البروفايل بأمان ---
  pw.ImageProvider? profileImage;
  if (provider.profileImagePath != null && provider.profileImagePath!.isNotEmpty) {
    try {
      final file = File(provider.profileImagePath!);
      if (file.existsSync()) {
        profileImage = pw.MemoryImage(file.readAsBytesSync());
      }
    } catch (e) {
      print("Error loading profile image: $e");
    }
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Row(
            children: [
              // --- العمود الجانبي (الأخضر الغامق) ---
              pw.Container(
                width: 200,
                color: const PdfColor.fromInt(0xFF1B5E20),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 40),
                    // الصورة الشخصية
                    pw.Container(
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        shape: pw.BoxShape.circle,
                        image: profileImage != null 
                            ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover) 
                            : null,
                        border: pw.Border.all(color: PdfColors.white, width: 2),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(provider.fullName.toUpperCase(), 
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(provider.jobTitle, 
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                    
                    pw.SizedBox(height: 40),
                    // معلومات التواصل
                    _buildSidebarContact(provider.isArabic ? "التواصل" : "Contact"),
                    _buildSidebarText(provider.email),
                    _buildSidebarText(provider.phone),
                    
                    pw.SizedBox(height: 40),
                    // المهارات (تنسيق Wrap لجلب القائمة كاملة)
                    if (provider.skills.isNotEmpty) ...[
                      _buildSidebarContact(provider.isArabic ? "المهارات" : "Skills"),
                      pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        alignment: pw.WrapAlignment.center,
                        children: provider.skills.map((skill) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: const PdfColor.fromInt(0xFF2E7D32),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(skill, style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // --- المحتوى الرئيسي (الأبيض) ---
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // الملخص المهني
                      if (provider.bio.isNotEmpty) ...[
                        _buildSectionHeader(provider.isArabic ? "الملخص المهني" : "Professional Summary"),
                        pw.SizedBox(height: 10),
                        pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 30),
                      ],

                      // التعليم (آمن)
                      if (provider.university.isNotEmpty) ...[
                        _buildSectionHeader(provider.isArabic ? "المؤهلات العلمية" : "Education"),
                        pw.Divider(color: const PdfColor.fromInt(0xFF1B5E20), thickness: 1),
                        pw.SizedBox(height: 5),
                        pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(provider.degree, style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(provider.gradYear, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                        pw.SizedBox(height: 30),
                      ],

                      // الخبرات العملية (جلب القائمة كاملة)
                      if (provider.experiences.isNotEmpty) ...[
                        _buildSectionHeader(provider.isArabic ? "الخبرات العملية" : "Work Experience"),
                        pw.Divider(color: const PdfColor.fromInt(0xFF1B5E20), thickness: 1),
                        pw.SizedBox(height: 10),
                        ...provider.experiences.map((exp) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 15),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(exp['position'] ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                                  pw.Text(exp['duration'] ?? "", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                                ],
                              ),
                              pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF1B5E20))),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

// دالات مساعدة
pw.Widget _buildSectionHeader(String title) {
  return pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1B5E20)));
}

pw.Widget _buildSidebarContact(String title) {
  return pw.Column(
    children: [
      pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
      pw.Divider(color: PdfColors.white, thickness: 0.5),
      pw.SizedBox(height: 10),
    ]
  );
}

pw.Widget _buildSidebarText(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Text(text, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
  );
}