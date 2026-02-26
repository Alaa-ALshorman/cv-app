import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../app_provider.dart';

// استيراد ملفات القوالب
import '../templates/modern_cyan_template.dart';
import '../templates/royal_green_template.dart';
import '../templates/classic_template.dart';
import '../templates/elegant_template.dart';
import '../templates/minimalist_template.dart';
import '../templates/professional_template.dart'; 

class TemplatesContent extends StatelessWidget {
  final bool isDark;
  final bool isAr;

  const TemplatesContent({
    super.key, 
    required this.isDark, 
    required this.isAr
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final primaryGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);

    // قائمة القوالب مع مسارات الصور
    final List<Map<String, dynamic>> myTemplates = [
      {'id': 'modern', 'name': isAr ? 'القالب العصري' : 'Modern Template', 'image': 'assets/templates/temp1.png', 'color': Colors.cyan},
      {'id': 'royal', 'name': isAr ? 'القالب الملكي' : 'Royal Template', 'image': 'assets/templates/temp2.png', 'color': const Color(0xFF1B5E20)},
      {'id': 'classic', 'name': isAr ? 'الكلاسيكي' : 'Classic', 'image': 'assets/templates/temp3.png', 'color': Colors.grey},
      {'id': 'elegant', 'name': isAr ? 'الأنيق' : 'Elegant', 'image': 'assets/templates/temp4.png', 'color': Colors.purple},
      {'id': 'minimal', 'name': isAr ? 'البسيط' : 'Minimalist', 'image': 'assets/templates/temp6.png', 'color': Colors.black},
      {'id': 'pro', 'name': isAr ? 'الاحترافي' : 'Professional', 'image': 'assets/templates/temp5.png', 'color': Colors.blueGrey},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.65, // تعديل النسبة ليكون المربع متناسقاً مع طول صفحة الـ CV
      ),
      itemCount: myTemplates.length,
      itemBuilder: (context, index) {
        final temp = myTemplates[index];
        return InkWell(
          onTap: () async {
            dynamic data;
            
            if (temp['id'] == 'modern') {
              data = await generateModernTemplate(provider);
            } else if (temp['id'] == 'royal') {
              data = await generateRoyalTemplate(provider);
            } else if (temp['id'] == 'classic') {
              data = await generateClassicTemplate(provider);
            } else if (temp['id'] == 'elegant') {
              data = await generateElegantTemplate(provider);
            } else if (temp['id'] == 'minimal') {
              data = await generateMinimalistTemplate(provider);
            } else if (temp['id'] == 'pro') { 
              data = await generateProfessionalTemplate(provider);
            }

            if (data != null) {
              _showPreview(context, data, temp['name'], provider, temp['id']);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? "هذا القالب قيد التجهيز..." : "Coming Soon!"))
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8), // هامش داخلي لإظهار الصورة كإطار
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF002B22) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryGreen.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      temp['image'],
                      fit: BoxFit.contain, // هذا التغيير الجوهري ليظهر محتوى الصورة بالكامل دون قص
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.insert_drive_file, size: 40, color: temp['color'].withOpacity(0.4)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                temp['name'], 
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                )
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreview(BuildContext context, dynamic data, String title, AppProvider provider, String templateId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            backgroundColor: const Color(0xFF1B5E20),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              TextButton.icon(
                onPressed: () {
                  provider.saveSelectedTemplate(templateId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAr ? "تم حفظ السيرة والعودة للرئيسية" : "CV Saved & Returned Home"),
                      backgroundColor: Colors.green,
                    )
                  );
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(isAr ? "حفظ" : "Save", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: PdfPreview(
            build: (format) => data,
            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: "${provider.userName.replaceAll(' ', '_')}_CV.pdf",
            maxPageWidth: 700,
          ),
        ),
      ),
    );
  }
}