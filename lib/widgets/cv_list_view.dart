import 'package:flutter/material.dart';

class CVListView extends StatelessWidget {
  final bool isDark;
  final bool isAr;

  const CVListView({
    super.key,
    required this.isDark,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    // حالة مؤقتة لعرض رسالة "لا يوجد بيانات"
    bool hasNoCVs = true; 

    if (hasNoCVs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded, 
              size: 70, 
              color: isDark ? Colors.white12 : Colors.black12
            ),
            const SizedBox(height: 15),
            Text(
              isAr ? "لا يوجد سير ذاتية حالياً" : "No CVs found yet",
              style: TextStyle(
                fontSize: 17, 
                color: isDark ? Colors.white38 : Colors.black38
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) => const SizedBox(),
    );
  }
}