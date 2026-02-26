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

  
  final Color primaryGreen = const Color(0xFF1B5E20); 
  final Color accentGreen = const Color(0xFFE8F5E9);

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: primaryGreen,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isAr = provider.isArabic;
    final bool isDark = provider.isDarkMode;

    final Color textColor = isDark ? Colors.white : const Color(0xFF002B22);
    final Color fieldColor = isDark ? Colors.white.withOpacity(0.1) : accentGreen;

    return GlassScaffold(
      isDark: isDark,
      isAr: isAr,
      onThemeToggle: () => provider.toggleTheme(),
      onLanguageToggle: () => provider.toggleLanguage(),
      showUserIcon: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Icon(Icons.lock_person_rounded, size: 80, color: isDark ? const Color(0xFF00E676) : primaryGreen),
            const SizedBox(height: 20),
            
            Text(
              isAr ? "تسجيل الدخول" : "Login",
              style: TextStyle(
                color: textColor, 
                fontSize: 30, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAr ? "مرحباً بك في صانع السيرة الذاتية الملكي" : "Welcome to Royal CV Maker",
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 40),
            
            _buildTextField(
              _emailController, 
              isAr ? "البريد الإلكتروني" : "Email", 
              Icons.alternate_email_rounded, 
              fieldColor, 
              textColor, 
              isDark ? const Color(0xFF00E676) : primaryGreen
            ),
            const SizedBox(height: 20),
            
            _buildTextField(
              _passwordController, 
              isAr ? "كلمة المرور" : "Password", 
              Icons.lock_outline_rounded, 
              fieldColor, 
              textColor, 
              isDark ? const Color(0xFF00E676) : primaryGreen,
              isObscure: true
            ),
            
            Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: TextButton(
                onPressed: _resetPassword,
                child: Text(
                  isAr ? "نسيت كلمة المرور؟" : "Forgot Password?",
                  style: TextStyle(color: isDark ? Colors.white70 : primaryGreen, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _isLoading 
              ? CircularProgressIndicator(color: isDark ? const Color(0xFF00E676) : primaryGreen)
              : ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF00E676) : primaryGreen,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: primaryGreen.withOpacity(0.5),
                  ),
                  child: Text(
                    isAr ? "دخول ملكي" : "Royal Login", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
            
            const SizedBox(height: 25),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isAr ? "ليس لديك حساب؟ " : "Don't have an account? ", style: TextStyle(color: textColor.withOpacity(0.8))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    isAr ? "سجل الآن" : "Sign Up",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF00E676) : primaryGreen, 
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color bg, Color text, Color primary, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: text, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primary),
        hintText: hint,
        hintStyle: TextStyle(color: text.withOpacity(0.4)),
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