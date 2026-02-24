import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_scaffold.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 1. وظيفة تسجيل الدخول
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "خطأ في تسجيل الدخول");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. وظيفة استعادة كلمة المرور (Forgot Password)
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError("يرجى كتابة البريد الإلكتروني أولاً لإرسال الرابط");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showError("تم إرسال رابط تعيين كلمة المرور إلى بريدك الإلكتروني");
    } catch (e) {
      _showError("حدث خطأ: تأكد من صحة البريد الإلكتروني");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isAr = provider.isArabic;

    return GlassScaffold(
      isDark: provider.isDarkMode,
      isAr: isAr,
      onThemeToggle: () => provider.toggleTheme(),
      onLanguageToggle: () => provider.toggleLanguage(),
      showUserIcon: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isAr ? "تسجيل الدخول" : "Login",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          
          _buildTextField(_emailController, isAr ? "البريد الإلكتروني" : "Email", Icons.email),
          const SizedBox(height: 20),
          
          _buildTextField(_passwordController, isAr ? "كلمة المرور" : "Password", Icons.lock, isObscure: true),
          
          // زر نسيت كلمة المرور
          Align(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text(
                isAr ? "نسيت كلمة المرور؟" : "Forgot Password?",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(isAr ? "دخول" : "Login", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          
          const SizedBox(height: 20),
          
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            child: Text(
              isAr ? "ليس لديك حساب؟ سجل الآن" : "Don't have an account? Sign Up",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}