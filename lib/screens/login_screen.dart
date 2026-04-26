import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_scaffold.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../theme/royal_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _keyRemember = 'login_remember_me';
  static const String _keySavedEmail = 'login_saved_email';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color accentGreen = const Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  Future<void> _loadRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final remember = prefs.getBool(_keyRemember) ?? false;
    final savedEmail = prefs.getString(_keySavedEmail) ?? '';
    setState(() {
      _rememberMe = remember;
      if (remember && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  Future<void> _applyRememberPreference(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool(_keyRemember, true);
      await prefs.setString(_keySavedEmail, email);
    } else {
      await prefs.remove(_keyRemember);
      await prefs.remove(_keySavedEmail);
    }
  }

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
      await FirebaseAuth.instance.currentUser?.reload();
      await _applyRememberPreference(email);
      if (!mounted) return;
      context.read<AppProvider>().fetchFirebaseUserData();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RoyalTheme.forest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isAr = provider.isArabic;
    final bool isDark = provider.isDarkMode;

    final Color textColor = isDark ? Colors.white : const Color(0xFF002B22);
    final Color fieldColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : accentGreen;

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
            
            Icon(Icons.lock_person_rounded, size: 76, color: RoyalTheme.primary(isDark)),
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
              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 14),
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
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  activeColor: isDark ? const Color(0xFF00E676) : primaryGreen,
                  side: BorderSide(
                    color: isDark ? Colors.white54 : primaryGreen.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      isAr ? "تذكرني (حفظ البريد على هذا الجهاز)" : "Remember me (save email on this device)",
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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

            const SizedBox(height: 12),

            _isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: RoyalTheme.primary(isDark)),
                  )
                : FilledButton(
                    onPressed: _handleLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: RoyalTheme.primary(isDark),
                      foregroundColor: isDark ? RoyalTheme.nightBg : Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isAr ? "دخول ملكي" : "Royal Login",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
            
            const SizedBox(height: 25),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAr ? "ليس لديك حساب؟ " : "Don't have an account? ",
                  style: TextStyle(color: textColor.withValues(alpha: 0.8)),
                ),
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
        hintStyle: TextStyle(color: text.withValues(alpha: 0.4)),
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