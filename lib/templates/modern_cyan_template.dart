import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateModernTemplate(AppProvider provider) async {
  final pdf = pw.Document();
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  
  pw.ImageProvider? profileImage;
  if (provider.profileImagePath != null) {
    final file = File(provider.profileImagePath!);
    if (await file.exists()) {
      profileImage = pw.MemoryImage(await file.readAsBytes());
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
          child: pw.Column(
            children: [
             
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                color: PdfColors.cyan800,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(provider.userName, style: pw.TextStyle(fontSize: 26, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                        pw.Text(provider.jobTitle, style: const pw.TextStyle(color: PdfColors.white, fontSize: 14)),
                        pw.SizedBox(height: 8),
                        pw.Text("${provider.email}  |  ${provider.phone}", style: const pw.TextStyle(color: PdfColors.cyan100, fontSize: 10)),
                      ],
                    ),
                    if (profileImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.white, width: 3),
                          image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),

              // --- محتوى الـ CV الأسفل ---
              pw.Padding(
                padding: const pw.EdgeInsets.all(35),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // قسم عني (Bio)
                    _buildModernSection(provider.isArabic ? "نبذة تعريفية" : "About Me", provider.bio),

                    pw.SizedBox(height: 20),

                    // قسم التعليم
                    pw.Text(provider.isArabic ? "التعليم" : "Education", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan800)),
                    pw.Divider(color: PdfColors.cyan800, thickness: 1),
                    pw.SizedBox(height: 5),
                    pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text("${provider.degree} (${provider.gradYear})", style: const pw.TextStyle(fontSize: 10)),

                    pw.SizedBox(height: 25),

                    // قسم الخبرات
                    if (provider.experiences.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "الخبرات العملية" : "Work Experience", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan800)),
                      pw.Divider(color: PdfColors.cyan800, thickness: 1),
                      ...provider.experiences.map((exp) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
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
                            pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 10, color: PdfColors.cyan900)),
                          ],
                        ),
                      )).toList(),
                    ],

                    pw.SizedBox(height: 25),

                    // قسم المهارات (Modern Chips Style)
                    if (provider.skills.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "المهارات" : "Skills", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan800)),
                      pw.Divider(color: PdfColors.cyan800, thickness: 1),
                      pw.SizedBox(height: 8),
                      pw.Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.skills.map((skill) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.cyan50,
                            borderRadius: pw.BorderRadius.circular(5),
                            border: pw.Border.all(color: PdfColors.cyan100),
                          ),
                          child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9, color: PdfColors.cyan900)),
                        )).toList(),
                      ),
                    ],
                  ],
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

// دالة مساعدة لبناء الأقسام
pw.Widget _buildModernSection(String title, String content) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan800)),
      pw.Divider(color: PdfColors.cyan800, thickness: 1),
      pw.SizedBox(height: 5),
      pw.Text(content, style: const pw.TextStyle(fontSize: 10)),
    ],
  );
}