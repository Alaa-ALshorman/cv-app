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
  // المعرفات (Controllers) لجلب النصوص الحقيقية من الحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 1. وظيفة إنشاء حساب بالإيميل والباسورد وحفظ "الاسم"
  Future<void> _signUpWithEmail() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // تحديث اسم المستخدم في Firebase فوراً بعد الإنشاء
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. وظيفة تسجيل الدخول بـ Google (الحقيقية)
  Future<void> _signUpWithGoogle() async {
    // هنا نضع كود الـ Google Sign In الذي ربطناه بالفايربيس
    print("Google Sign In Triggered");
  }

  // 3. وظيفة تسجيل الدخول بالهاتف (الحقيقية)
  Future<void> _signUpWithPhone() async {
    // هنا نضع كود الـ Phone Auth الذي ربطناه بالفايربيس
    print("Phone Sign In Triggered");
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
      showUserIcon: false, // لا يظهر زر اليوزر في صفحة التسجيل
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isAr ? "إنشاء حساب جديد" : "Create Account",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          // حقل الاسم الحقيقي
          _buildTextField(_nameController, isAr ? "الاسم الكامل" : "Full Name", Icons.person),
          const SizedBox(height: 15),
          
          // حقل الإيميل الحقيقي
          _buildTextField(_emailController, isAr ? "البريد الإلكتروني" : "Email", Icons.email),
          const SizedBox(height: 15),
          
          // حقل الباسورد
          _buildTextField(_passwordController, isAr ? "كلمة المرور" : "Password", Icons.lock, isObscure: true),
          const SizedBox(height: 30),

          // زر الإنشاء الرئيسي
          _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : ElevatedButton(
                onPressed: _signUpWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(isAr ? "تسجيل" : "Sign Up", style: const TextStyle(color: Colors.white)),
              ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // أزرار التواصل الاجتماعي (Google & Phone)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialButton(Icons.phone, Colors.green, _signUpWithPhone),
              _socialButton(Icons.g_mobiledata, Colors.red, _signUpWithGoogle),
            ],
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

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}