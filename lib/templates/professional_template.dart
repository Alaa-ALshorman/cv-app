import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../app_provider.dart';


Future<dynamic> generateProfessionalTemplate(AppProvider provider) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(provider.userName.toUpperCase(), style: pw.TextStyle(fontSize: 24, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      pw.Text(provider.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey100)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("SUMMARY", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
            pw.Divider(),
            pw.Text(provider.bio),
            pw.SizedBox(height: 20),
            pw.Text("SKILLS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey)),
            pw.Divider(),
            pw.Text(provider.skills.join("  |  ")),
          ],
        );
      },
    ),
  );
  return pdf.save();
}