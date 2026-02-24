import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // التأكد من تهيئة الإطارات البرمجية
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة فايربيس
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على الإعدادات من الـ Provider (اللغة والثيم)
    final provider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'CV Builder',
      debugShowCheckedModeBanner: false,
      
      // إعدادات الثيم (فاتح / غامق)
      theme: provider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      
      // تحديد الصفحة الأولى (شاشة تسجيل الدخول)
      initialRoute: '/',
      
      // تعريف المسارات (Routes) للتنقل بين الصفحات
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}