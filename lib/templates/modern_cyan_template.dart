import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../app_provider.dart';

// دالة توليد القالب الحديث (Modern Cyan)
Future<Uint8List> generateModernTemplate(AppProvider provider) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 1. العنوان (اسم المستخدم ووظيفته)
            pw.Text(
              provider.userName, // الاسم اللي سحبناه من فايربيس
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(provider.jobTitle, style: const pw.TextStyle(fontSize: 16)),
            
            pw.Divider(), // خط فاصل
            
            // 2. قسم "عني" (Bio)
            pw.Text(provider.isArabic ? "نبذة شخصية" : "About Me", 
                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(provider.bio),
            
            pw.SizedBox(height: 20),

            // 3. قسم الخبرات (Experiences)
            pw.Text(provider.isArabic ? "الخبرات" : "Experience", 
                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            // عرض الخبرات من القائمة المخزنة في الـ Provider
            ...provider.experiences.map((exp) => pw.Bullet(
              text: "${exp['position']} @ ${exp['company']}",
            )),
          ],
        );
      },
    ),
  );

  return pdf.save(); // تحويل الملف لبيانات (Bytes) عشان نقدر نحفظه أو نعرضه
}