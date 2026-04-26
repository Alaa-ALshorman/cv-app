import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../theme/royal_theme.dart';

class ProfilePage extends StatefulWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;

  const ProfilePage({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.onThemeToggle,
    required this.onLanguageToggle,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  String? _userEmail;
  String? _userPhotoUrl;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? "");
    _userEmail = user?.email;
    _userPhotoUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color get _primary => RoyalTheme.primary(widget.isDark);
  Color get _text => widget.isDark ? Colors.white : const Color(0xFF002B22);
  Color get _card =>
      widget.isDark ? RoyalTheme.surfaceDark : const Color(0xFFF1F8E9);

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('${user.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      if (mounted) {
        Provider.of<AppProvider>(context, listen: false).fetchFirebaseUserData();
        setState(() => _userPhotoUrl = user.photoURL);
      }
    } catch (e) {
      debugPrint("Profile photo upload: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
        if (mounted) {
          Provider.of<AppProvider>(context, listen: false).fetchFirebaseUserData();
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: RoyalTheme.forest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Text(widget.isAr ? "تم تحديث الاسم" : "Name updated"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Name update: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    final app = Provider.of<AppProvider>(context, listen: false);
    app.clearActiveCv();
    app.clearSignUpSessionLabel();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Text(
          widget.isAr ? "الملف الشخصي" : "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isAr ? "حسابك وإعدادات المظهر" : "Account & appearance",
          style: TextStyle(
            fontSize: 13,
            color: _text.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primary.withValues(alpha: 0.45), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _primary.withValues(alpha: 0.1),
                  backgroundImage: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                      ? NetworkImage(_userPhotoUrl!)
                      : null,
                  child: _userPhotoUrl == null || _userPhotoUrl!.isEmpty
                      ? Icon(Icons.person_rounded, color: _primary, size: 52)
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: _primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _isLoading ? null : _pickAndUploadImage,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _sectionCard(
          child: TextField(
            controller: _nameController,
            onChanged: (_) => setState(() => _isEditing = true),
            textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: _text, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined, color: _primary),
              labelText: widget.isAr ? "الاسم" : "Display name",
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _saveName,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: widget.isDark ? RoyalTheme.nightBg : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isAr ? "حفظ الاسم" : "Save name",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _sectionCard(
          child: Row(
            children: [
              Icon(Icons.alternate_email_rounded, color: _primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAr ? "البريد" : "Email",
                      style: TextStyle(
                        fontSize: 12,
                        color: _text.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userEmail ?? (widget.isAr ? "غير متوفر" : "N/A"),
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.isAr ? "المظهر" : "Appearance",
          style: TextStyle(
            color: _text.withValues(alpha: 0.55),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _sectionCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              widget.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: _primary,
            ),
            title: Text(
              widget.isAr ? "الوضع الليلي" : "Dark mode",
              style: TextStyle(color: _text, fontWeight: FontWeight.w600),
            ),
            trailing: Switch(
              value: widget.isDark,
              activeThumbColor: _primary,
              onChanged: (_) => widget.onThemeToggle(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _sectionCard(
          child: ListTile(
            onTap: widget.onLanguageToggle,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.translate_rounded, color: _primary),
            title: Text(
              widget.isAr ? "لغة التطبيق" : "App language",
              style: TextStyle(color: _text, fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              context.watch<AppProvider>().isArabic
                  ? (widget.isAr ? "العربية" : "Arabic")
                  : (widget.isAr ? "الإنجليزية" : "English"),
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _logout,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent, width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: Text(
            widget.isAr ? "تسجيل الخروج" : "Log out",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Royal CV Maker",
            style: TextStyle(
              color: _text.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Material(
      color: _card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RoyalTheme.radiusButton),
        side: BorderSide(
          color: _text.withValues(alpha: widget.isDark ? 0.08 : 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: child,
      ),
    );
  }
}

