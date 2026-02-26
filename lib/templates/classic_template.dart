import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateClassicTemplate(AppProvider provider) async {
  final pdf = pw.Document();
  final arabicFont = await PdfGoogleFonts.cairoRegular();
  final arabicFontBold = await PdfGoogleFonts.cairoBold();

  
  pw.ImageProvider? profileImage;
  if (provider.profileImagePath != null && provider.profileImagePath!.isNotEmpty) {
    final file = File(provider.profileImagePath!);
    if (file.existsSync()) {
      profileImage = pw.MemoryImage(file.readAsBytesSync());
    }
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- الرأس: الاسم، الوظيفة، والصورة ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(provider.userName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(provider.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800)),
                      pw.SizedBox(height: 5),
                      pw.Text("${provider.email} | ${provider.phone}", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  if (profileImage != null)
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 0.5),
                        image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                ],
              ),
              
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 10),

              // --- الملخص المهني ---
              if (provider.bio.isNotEmpty) ...[
                pw.Text(provider.isArabic ? "الملخص المهني" : "Summary", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 10.5)),
                pw.SizedBox(height: 20),
              ],

              // --- قسم الخبرات ---
              pw.Text(provider.isArabic ? "الخبرات العملية" : "Professional Experience", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 0.5),
              ...provider.experiences.map((exp) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${exp['position']} @ ${exp['company']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text(exp['duration'] ?? "", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )).toList(),

              pw.SizedBox(height: 20),

              // --- قسم التعليم ---
              pw.Text(provider.isArabic ? "التعليم" : "Education", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(provider.gradYear, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text(provider.degree, style: const pw.TextStyle(fontSize: 10)),

              pw.SizedBox(height: 20),

              // --- قسم المهارات ---
              if (provider.skills.isNotEmpty) ...[
                pw.Text(provider.isArabic ? "المهارات" : "Skills", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 5),
                pw.Text(provider.skills.join(" , "), style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}