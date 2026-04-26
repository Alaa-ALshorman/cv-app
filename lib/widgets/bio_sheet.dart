import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../app_provider.dart';

class BioSheet extends StatefulWidget {
  final bool isDark;
  final bool isAr;

  const BioSheet({super.key, required this.isDark, required this.isAr});

  @override
  State<BioSheet> createState() => _BioSheetState();
}

class _BioSheetState extends State<BioSheet> {
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final currentBio = Provider.of<AppProvider>(context, listen: false).bio;
    _bioController = TextEditingController(text: currentBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
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
            Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.3), 
                borderRadius: BorderRadius.circular(10)
              )
            ),
            const SizedBox(height: 25),
            
            Text(
              widget.isAr ? "النبذة الشخصية" : "Professional Bio",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
            ),
            const SizedBox(height: 30),
            
            TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 300,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                labelText: widget.isAr ? "اكتب نبذة مختصرة عنك" : "Professional Summary",
                labelStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
                prefixIcon: Icon(Icons.edit_note_rounded, color: primaryGreen),
                filled: true,
                fillColor: accentGreen,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), 
                  borderSide: BorderSide(color: primaryGreen, width: 1.5)
                ),
              ),
            ),
            
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
                provider.updateBio(_bioController.text);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.isAr ? "تم حفظ النبذة بنجاح" : "Bio updated successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                widget.isAr ? "حفظ النبذة" : "Save Bio",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}