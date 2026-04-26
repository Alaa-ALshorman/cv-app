import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateProfessionalTemplate(AppProvider provider) async {
  final pdf = pw.Document();
  
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(provider.fullName.toUpperCase(),
                              style: pw.TextStyle(fontSize: 24, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                          pw.Text(provider.jobTitle, 
                              style: const pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey100)),
                          pw.SizedBox(height: 5),
                          pw.Text("${provider.email} | ${provider.phone}", 
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey50)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (provider.bio.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "الملخص المهني" : "SUMMARY", 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                      pw.Divider(color: PdfColors.blueGrey),
                      pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 11)),
                      pw.SizedBox(height: 20),
                    ],

                    if (provider.university.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "التعليم" : "EDUCATION", 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                      pw.Divider(color: PdfColors.blueGrey),
                      pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text("${provider.degree} (${provider.gradYear})", style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 20),
                    ],

                    if (provider.experiences.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "الخبرات العملية" : "WORK EXPERIENCE", 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                      pw.Divider(color: PdfColors.blueGrey),
                      ...provider.experiences.map((exp) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
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
                            pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      )).toList(),
                      pw.SizedBox(height: 20),
                    ],

                    if (provider.skills.isNotEmpty) ...[
                      pw.Text(provider.isArabic ? "المهارات" : "SKILLS", 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
                      pw.Divider(color: PdfColors.blueGrey),
                      pw.Text(provider.skills.join("  |  "), style: const pw.TextStyle(fontSize: 11)),
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