import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';

class SkillsSheet extends StatefulWidget {
  final bool isDark;
  final bool isAr;
  const SkillsSheet({super.key, required this.isDark, required this.isAr});

  @override
  State<SkillsSheet> createState() => _SkillsSheetState();
}

class _SkillsSheetState extends State<SkillsSheet> {
  final TextEditingController _skillController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // تعريف الباليت الملكية الموحدة
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color accentGreen = widget.isDark ? const Color(0xFF004D40) : const Color(0xFFE8F5E9);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF002B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), // زوايا الحبة المعتمدة
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(width: 45, height: 4, decoration: BoxDecoration(color: primaryGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),
          
          Text(
            widget.isAr ? "المهارات الإبداعية" : "Creative Skills", 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, // وضوح الخط المعتمد
              color: textColor
            )
          ),
          const SizedBox(height: 25),
          
          // حقل الإضافة المطور
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: widget.isAr ? "أضف مهارة جديدة" : "Add New Skill",
                    labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.bolt_rounded, color: primaryGreen),
                    filled: true,
                    fillColor: accentGreen,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: primaryGreen, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // زر الإضافة الدائري الملكي
              Container(
                decoration: BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: IconButton(
                  onPressed: () {
                    if (_skillController.text.trim().isNotEmpty) {
                      provider.addSkill(_skillController.text.trim());
                      _skillController.clear();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          
          // عرض المهارات بستايل الـ Modern Chips
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: provider.skills.asMap().entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: primaryGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => provider.removeSkill(entry.key),
                          child: Icon(Icons.cancel_rounded, size: 18, color: primaryGreen.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}