import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateMinimalistTemplate(AppProvider provider) async {
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
              // الهيدر: بسيط جداً وواضح
              pw.Text(provider.userName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text(provider.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Text(provider.email, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text(provider.phone, style: const pw.TextStyle(fontSize: 10)),
              ]),
              pw.Divider(thickness: 1, color: PdfColors.black),
              
              pw.SizedBox(height: 20),
              // الملخص
              pw.Text(provider.isArabic ? "الملخص المهني" : "Summary", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 11)),

              pw.SizedBox(height: 20),
              // الخبرات
              pw.Text(provider.isArabic ? "الخبرات" : "Experience", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ...provider.experiences.map((exp) => pw.Bullet(
                text: "${exp['position']} - ${exp['company']}",
                style: const pw.TextStyle(fontSize: 11)
              )),

              pw.SizedBox(height: 20),
              // المهارات
              pw.Text(provider.isArabic ? "المهارات" : "Skills", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(provider.skills.join(" | "), style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}