import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';

class EducationSheet extends StatefulWidget {
  final bool isDark;
  final bool isAr;

  const EducationSheet({super.key, required this.isDark, required this.isAr});

  @override
  State<EducationSheet> createState() => _EducationSheetState();
}

class _EducationSheetState extends State<EducationSheet> {
  late TextEditingController _uniController;
  late TextEditingController _degreeController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _uniController = TextEditingController(text: provider.university);
    _degreeController = TextEditingController(text: provider.degree);
    _yearController = TextEditingController(text: provider.gradYear);
  }

  @override
  void dispose() {
    _uniController.dispose();
    _degreeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color accentGreen = widget.isDark ? const Color(0xFF004D40) : const Color(0xFFE8F5E9);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20, left: 25, right: 25,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF002B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), 
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            
            Text(
              widget.isAr ? "المؤهلات العلمية" : "Education Detail",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(widget.isAr ? "الجامعة / المؤسسة" : "University / School", Icons.school_outlined, _uniController, primaryGreen, accentGreen, textColor),
            const SizedBox(height: 18),
            _buildTextField(widget.isAr ? "التخصص / الدرجة" : "Degree / Major", Icons.history_edu_outlined, _degreeController, primaryGreen, accentGreen, textColor),
            const SizedBox(height: 18),
            _buildTextField(widget.isAr ? "سنة التخرج" : "Graduation Year", Icons.calendar_today_outlined, _yearController, primaryGreen, accentGreen, textColor),
            
            const SizedBox(height: 35),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 5,
                shadowColor: primaryGreen.withOpacity(0.4),
              ),
              onPressed: () {
                provider.updateEducation(
                  _uniController.text, 
                  _degreeController.text, 
                  _yearController.text
                );
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.isAr ? "تم حفظ المؤهلات" : "Education saved"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                widget.isAr ? "حفظ البيانات" : "Save Education",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
    );
  }
}