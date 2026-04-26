import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; 
import '../app_provider.dart';

class PersonalSheet extends StatefulWidget {
  final bool isDark;
  final bool isAr;

  const PersonalSheet({super.key, required this.isDark, required this.isAr});

  @override
  State<PersonalSheet> createState() => _PersonalSheetState();
}

class _PersonalSheetState extends State<PersonalSheet> {
  late TextEditingController _nameController;
  late TextEditingController _jobController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final p = Provider.of<AppProvider>(context, listen: false);
    _nameController = TextEditingController(text: p.fullName);
    _jobController = TextEditingController(text: p.jobTitle);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color accentGreen = widget.isDark ? const Color(0xFF004D40) : const Color(0xFFE8F5E9);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF002B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), 
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 45, 
              height: 4, 
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.3), 
                borderRadius: BorderRadius.circular(10)
              )
            ),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: () {
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: accentGreen,
                      backgroundImage: (provider.profileImagePath != null && provider.profileImagePath!.isNotEmpty)
                          ? FileImage(File(provider.profileImagePath!))
                          : null,
                      child: (provider.profileImagePath == null || provider.profileImagePath!.isEmpty)
                          ? Icon(Icons.person_add_rounded, size: 55, color: primaryGreen)
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.isDark ? const Color(0xFF002B22) : Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.camera_enhance_rounded, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isAr ? "الصورة الشخصية" : "Profile Picture",
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 35),

            _buildField(widget.isAr ? "الاسم الكامل" : "Full Name", Icons.person_outline_rounded, _nameController, primaryGreen, accentGreen, textColor),
            const SizedBox(height: 15),
            _buildField(widget.isAr ? "المسمى الوظيفي" : "Job Title", Icons.work_outline_rounded, _jobController, primaryGreen, accentGreen, textColor),
            const SizedBox(height: 15),
            _buildField(widget.isAr ? "البريد الإلكتروني" : "Email", Icons.alternate_email_rounded, _emailController, primaryGreen, accentGreen, textColor),
            const SizedBox(height: 15),
            _buildField(widget.isAr ? "رقم الهاتف" : "Phone Number", Icons.phone_iphone_rounded, _phoneController, primaryGreen, accentGreen, textColor),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 6,
                shadowColor: primaryGreen.withOpacity(0.4),
              ),
              onPressed: () {
                provider.updatePersonalInfo(
                  _nameController.text,
                  _jobController.text,
                  _emailController.text,
                  _phoneController.text,
                );
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.isAr ? "تم حفظ البيانات بنجاح" : "Data saved successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                widget.isAr ? "حفظ المعلومات" : "Save Information",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, Color primary, Color bg, Color text) {
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), 
          borderSide: BorderSide(color: primary, width: 1.5)
        ),
      ),
    );
  }
}