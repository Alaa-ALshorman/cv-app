import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';

class ExperienceSheet extends StatefulWidget {
  final bool isDark;
  final bool isAr;

  const ExperienceSheet({super.key, required this.isDark, required this.isAr});

  @override
  State<ExperienceSheet> createState() => _ExperienceSheetState();
}

class _ExperienceSheetState extends State<ExperienceSheet> {
  // تعريف وحدات التحكم في النصوص
  final _compController = TextEditingController();
  final _posController = TextEditingController();
  final _durController = TextEditingController();

  @override
  void dispose() {
    _compController.dispose();
    _posController.dispose();
    _durController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // الاتصال بالـ Provider
    final provider = Provider.of<AppProvider>(context);
    
    // الألوان الملكية الموحدة للتصميم
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color accentGreen = widget.isDark ? const Color(0xFF004D40) : const Color(0xFFE8F5E9);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);

    return Container(
      // تحديد ارتفاع مناسب للشاشة
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF002B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), // تصميم الحبة
      ),
      child: Column(
        children: [
          // مقبض سحب علوي للتزيين
          Container(
            width: 45, 
            height: 4, 
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.3), 
              borderRadius: BorderRadius.circular(10)
            )
          ),
          const SizedBox(height: 25),
          
          Text(
            widget.isAr ? "الخبرات العملية" : "Work Experiences",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: textColor
            ),
          ),
          const SizedBox(height: 30),
          
          // حقول الإدخال
          _buildTextField(widget.isAr ? "الشركة" : "Company", Icons.business_rounded, _compController, primaryGreen, accentGreen, textColor),
          const SizedBox(height: 15),
          _buildTextField(widget.isAr ? "المسمى الوظيفي" : "Job Position", Icons.badge_rounded, _posController, primaryGreen, accentGreen, textColor),
          const SizedBox(height: 15),
          _buildTextField(widget.isAr ? "المدة (مثلاً: 2020 - 2022)" : "Duration (e.g., 2020 - 2022)", Icons.timer_rounded, _durController, primaryGreen, accentGreen, textColor),
          
          const SizedBox(height: 25),
          
          // زر إضافة الخبرة
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 4,
              shadowColor: primaryGreen.withOpacity(0.4),
            ),
            onPressed: () {
              // التحقق من أن حقل الشركة ليس فارغاً على الأقل
              if (_compController.text.isNotEmpty) {
                provider.addExperience(
                  _compController.text, 
                  _posController.text, 
                  _durController.text
                );
                // مسح الحقول بعد الإضافة لتسهيل إضافة خبرة أخرى
                _compController.clear(); 
                _posController.clear(); 
                _durController.clear();
                
                // إخفاء الكيبورد بعد الإضافة
                FocusScope.of(context).unfocus();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.isAr ? "الرجاء إدخال اسم الشركة" : "Please enter company name"))
                );
              }
            },
            child: Text(
              widget.isAr ? "إضافة خبرة +" : "Add Experience +",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          
          const SizedBox(height: 20),
          Divider(color: primaryGreen.withOpacity(0.1), thickness: 1.5),
          const SizedBox(height: 15),
          
          // قائمة الخبرات المضافة
          Expanded(
            child: provider.experiences.isEmpty 
              ? Center(
                  child: Text(
                    widget.isAr ? "لم تضف أي خبرات بعد" : "No experiences added yet",
                    style: TextStyle(color: textColor.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.experiences.length,
                  itemBuilder: (context, index) {
                    final exp = provider.experiences[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(widget.isDark ? 0.2 : 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryGreen.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.15), 
                            shape: BoxShape.circle
                          ),
                          child: Icon(Icons.work_outline_rounded, color: primaryGreen, size: 24),
                        ),
                        title: Text(
                          exp['company'] ?? "", 
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w900)
                        ),
                        subtitle: Text(
                          "${exp['position'] ?? ''} | ${exp['duration'] ?? ''}",
                          style: TextStyle(
                            color: textColor.withOpacity(0.7), 
                            fontSize: 13, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                          onPressed: () => provider.deleteExperience(index),
                        ),
                      ),
                    );
                  },
                ),
          ),
          
          // زر نهائي لإغلاق الشاشة بعد الانتهاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.isAr ? "تم" : "Done",
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ودجت بناء حقل النص الموحد
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, Color primary, Color bg, Color text) {
    return TextField(
      controller: controller,
      style: TextStyle(color: text, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: text.withOpacity(0.6), fontSize: 14),
        prefixIcon: Icon(icon, color: primary),
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), 
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), 
          borderSide: BorderSide(color: primary, width: 1.5)
        ),
      ),
    );
  }
}