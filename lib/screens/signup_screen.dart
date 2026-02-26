import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_scaffold.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final Color primaryGreen = const Color(0xFF1B5E20); 
  final Color accentGreen = const Color(0xFFE8F5E9);

  Future<void> _signUpWithEmail() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError(context.read<AppProvider>().isArabic ? "يرجى ملء جميع الحقول" : "Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Error");
    } finally {
      setState(() => _isLoading = false);
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
    final Color primaryColor = isDark ? const Color(0xFF00E676) : primaryGreen;

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
            Icon(Icons.stars_rounded, size: 70, color: primaryColor),
            const SizedBox(height: 15),
            
            Text(
              isAr ? "انضم إلينا" : "Join Us",
              style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(_nameController, isAr ? "الاسم الكامل" : "Full Name", Icons.person_outline_rounded, fieldColor, textColor, primaryColor),
            const SizedBox(height: 15),
            
            _buildTextField(_emailController, isAr ? "البريد الإلكتروني" : "Email", Icons.alternate_email_rounded, fieldColor, textColor, primaryColor),
            const SizedBox(height: 15),
            
            _buildTextField(_passwordController, isAr ? "كلمة المرور" : "Password", Icons.lock_outline_rounded, fieldColor, textColor, primaryColor, isObscure: true),
            
            const SizedBox(height: 40),

            _isLoading 
              ? CircularProgressIndicator(color: primaryColor)
              : ElevatedButton(
                  onPressed: _signUpWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                  ),
                  child: Text(isAr ? "إنشاء حساب ملكي" : "Create Royal Account", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            
            const SizedBox(height: 25),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isAr ? "لديك حساب بالفعل؟ سجل دخولك" : "Already have an account? Login",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
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
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
    );
  }
}