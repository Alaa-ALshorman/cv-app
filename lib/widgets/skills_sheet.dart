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

  void _addNewSkill(AppProvider provider) {
    String text = _skillController.text.trim();
    if (text.isNotEmpty) {
      provider.addSkill(text);
      setState(() {
        _skillController.clear();
      });
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color accentGreen = widget.isDark ? const Color(0xFF004D40) : const Color(0xFFE8F5E9);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        left: 25, right: 25, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF002B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Column(
        children: [
          Container(
            width: 45, height: 4, 
            decoration: BoxDecoration(color: primaryGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(10))
          ),
          const SizedBox(height: 25),
          
          Text(
            widget.isAr ? "المهارات واللغات" : "Skills & Languages", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)
          ),
          const SizedBox(height: 25),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  autofocus: true,
                  onSubmitted: (value) => _addNewSkill(provider),
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: widget.isAr ? "أضف مهارة..." : "Add skill...",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                    prefixIcon: Icon(Icons.bolt_rounded, color: primaryGreen),
                    filled: true,
                    fillColor: accentGreen.withOpacity(widget.isDark ? 0.3 : 1.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _addNewSkill(provider),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              )
            ],
          ),
          const SizedBox(height: 25),

          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, skillsProvider, child) {
                if (skillsProvider.skills.isEmpty) {
                  return Opacity(
                    opacity: 0.3,
                    child: Center(child: Text(widget.isAr ? "القائمة فارغة" : "List is empty")),
                  );
                }
                
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: skillsProvider.skills.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryGreen.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: primaryGreen, size: 20),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              skillsProvider.skills[index],
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                          IconButton(
                            onPressed: () => skillsProvider.deleteSkill(index),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.isAr ? "تمت الإضافة" : "Finished", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}