import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateElegantTemplate(AppProvider provider) async {
  
  if (provider.currentCV == null) {
    
    final emptyPdf = pw.Document();
    emptyPdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Text("No Data Available"))));
    return emptyPdf.save();
  }

  final pdf = pw.Document();
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  
  pw.ImageProvider? profileImage;
  final String? imagePath = provider.profileImagePath;
  if (imagePath != null && imagePath.isNotEmpty) {
    final file = File(imagePath);
    if (await file.exists()) {
      profileImage = pw.MemoryImage(await file.readAsBytes());
    }
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(35),
          child: pw.Directionality(
            textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded( 
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(provider.fullName.toUpperCase(), 
                              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                          pw.Text(provider.jobTitle, 
                              style: const pw.TextStyle(fontSize: 14, color: PdfColors.teal700)),
                          pw.SizedBox(height: 10),
                          pw.Text("${provider.email}  |  ${provider.phone}", 
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                        ],
                      ),
                    ),
                    if (profileImage != null)
                      pw.Container(
                        width: 80, height: 80,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                          border: pw.Border.all(color: PdfColors.teal, width: 2),
                        ),
                      ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Divider(thickness: 1.5, color: PdfColors.teal),

                // --- الملخص المهني ---
                if (provider.bio.isNotEmpty) ...[
                  pw.SizedBox(height: 15),
                  _buildSectionTitle(provider.isArabic ? "الملخص المهني" : "Professional Summary"),
                  pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 11)),
                ],

               
                if (provider.university.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildSectionTitle(provider.isArabic ? "المؤهلات العلمية" : "Education"),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(provider.degree, style: const pw.TextStyle(fontSize: 11)),
                          pw.Text(provider.gradYear, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ],

                // --- الخبرات ---
                if (provider.experiences.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildSectionTitle(provider.isArabic ? "الخبرات العملية" : "Work Experience"),
                  ...provider.experiences.map((exp) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(exp['position'] ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                            pw.Text(exp['duration'] ?? "", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                        pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 10, color: PdfColors.teal900)),
                      ],
                    ),
                  )).toList(),
                ],

                // --- المهارات ---
                if (provider.skills.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildSectionTitle(provider.isArabic ? "المهارات" : "Skills"),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: provider.skills.map((skill) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal50,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(skill, style: const pw.TextStyle(fontSize: 10, color: PdfColors.teal900)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
  return pdf.save();
}

pw.Widget _buildSectionTitle(String title) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
      pw.SizedBox(height: 3),
      pw.Container(width: 40, height: 2, color: PdfColors.teal),
      pw.SizedBox(height: 8),
    ],
  );
}