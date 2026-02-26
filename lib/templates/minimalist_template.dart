import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app_provider.dart';

Future<Uint8List> generateMinimalistTemplate(AppProvider provider) async {
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
      margin: const pw.EdgeInsets.all(35),
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: provider.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
             
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(provider.userName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                        pw.Text(provider.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                        pw.SizedBox(height: 5),
                        pw.Text("${provider.email}  |  ${provider.phone}", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  if (profileImage != null)
                    pw.Container(
                      width: 70,
                      height: 70,
                      child: pw.ClipOval(child: pw.Image(profileImage, fit: pw.BoxFit.cover)),
                    ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              pw.Container(height: 1, color: PdfColors.black),
              pw.SizedBox(height: 15),

              // الملخص المهني
              if (provider.bio.isNotEmpty) ...[
                pw.Text(provider.bio, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 20),
              ],

              // قسم التعليم
              _buildSectionTitle(provider.isArabic ? "التعليم" : "Education"),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(provider.university, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(provider.degree, style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(provider.gradYear, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // قسم الخبرات العملية
              if (provider.experiences.isNotEmpty) ...[
                _buildSectionTitle(provider.isArabic ? "الخبرة العملية" : "Work Experience"),
                ...provider.experiences.map((exp) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(exp['position'] ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text(exp['duration'] ?? "", style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Text(exp['company'] ?? "", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                )).toList(),
                pw.SizedBox(height: 10),
              ],

              // قسم المهارات
              if (provider.skills.isNotEmpty) ...[
                _buildSectionTitle(provider.isArabic ? "المهارات" : "Skills"),
                pw.Text(provider.skills.join("  •  "), style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}


pw.Widget _buildSectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
  );
}