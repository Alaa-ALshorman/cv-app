import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../app_provider.dart';
// استيراد ملفات القوالب التي برمجناها
import '../templates/modern_cyan_template.dart';
import '../templates/royal_green_template.dart';

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

    // قائمة الـ 6 قوالب
    final List<Map<String, dynamic>> myTemplates = [
      {
        'id': 'modern',
        'name': isAr ? 'القالب العصري' : 'Modern Template',
        'image': 'assets/templates/temp1.png', // استبدليها بصورتك لاحقاً
        'color': Colors.cyan
      },
      {
        'id': 'royal',
        'name': isAr ? 'القالب الملكي' : 'Royal Template',
        'image': 'assets/templates/temp2.png',
        'color': const Color(0xFF1B5E20)
      },
      {
        'id': 'classic',
        'name': isAr ? 'الكلاسيكي' : 'Classic',
        'image': 'assets/templates/temp3.png',
        'color': Colors.grey
      },
      {
        'id': 'elegant',
        'name': isAr ? 'الأنيق' : 'Elegant',
        'image': 'assets/templates/temp4.png',
        'color': Colors.purple
      },
      {
        'id': 'pro',
        'name': isAr ? 'الاحترافي' : 'Professional',
        'image': 'assets/templates/temp5.png',
        'color': Colors.blueGrey
      },
      {
        'id': 'minimal',
        'name': isAr ? 'البسيط' : 'Minimalist',
        'image': 'assets/templates/temp6.png',
        'color': Colors.black
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7, // شكل ورقة A4
      ),
      itemCount: myTemplates.length,
      itemBuilder: (context, index) {
        final temp = myTemplates[index];
        return InkWell(
          onTap: () async {
            if (temp['id'] == 'modern') {
              final data = await generateModernTemplate(provider);
              _showPreview(context, data, temp['name'], provider);
            } else if (temp['id'] == 'royal') {
              final data = await generateRoyalTemplate(provider);
              _showPreview(context, data, temp['name'], provider);
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
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF002B22) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryGreen.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
                    ],
                    // عرض صورة القالب إذا توفرت
                    image: DecorationImage(
                      image: AssetImage(temp['image']),
                      fit: BoxFit.cover,
                      // في حال عدم وجود الصورة بعد، يظهر لون مؤقت
                      onError: (e, s) => {}, 
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.insert_drive_file, 
                      size: 40, color: temp['color'].withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                temp['name'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة فتح صفحة المعاينة والطباعة
  void _showPreview(BuildContext context, dynamic data, String title, AppProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: const Color(0xFF1B5E20),
          ),
          body: PdfPreview(
            build: (format) => data,
            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: "${provider.userName}_CV.pdf",
          ),
        ),
      ),
    );
  }
}