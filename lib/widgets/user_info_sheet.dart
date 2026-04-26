import 'dart:ui';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:provider/provider.dart';
import '../app_provider.dart';

class UserInfoSheet extends StatefulWidget {
  final bool isAr;
  final bool isDark;

  const UserInfoSheet({super.key, required this.isAr, required this.isDark});

  @override
  State<UserInfoSheet> createState() => _UserInfoSheetState();
}

class _UserInfoSheetState extends State<UserInfoSheet> {
  late TextEditingController _nameController;
  String? userEmail;
  String? userPhotoUrl;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? "");
    userEmail = user?.email ?? "No Email";
    userPhotoUrl = user?.photoURL;
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
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
          setState(() => userPhotoUrl = downloadUrl);
        }
      } catch (e) {
        debugPrint("Upload Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
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
              backgroundColor: const Color(0xFF1B5E20),
              content: Text(widget.isAr ? "تم تحديث الاسم بنجاح!" : "Name Updated Successfully!")
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
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
    final Color primaryGreen = widget.isDark ? const Color(0xFF00E676) : const Color(0xFF1B5E20);
    final Color textColor = widget.isDark ? Colors.white : const Color(0xFF002B22);
    final Color subTextColor = textColor.withOpacity(0.7);
    final Color cardBg = widget.isDark ? const Color(0xFF002B22) : Colors.white;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                    child: userPhotoUrl == null 
                        ? Icon(Icons.person_rounded, color: primaryGreen, size: 50) 
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: primaryGreen,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                widget.isAr ? "الملف الشخصي" : "User Profile",
                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                onChanged: (val) => setState(() => _isEditing = true),
                textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline_rounded, color: primaryGreen),
                  labelText: widget.isAr ? "الاسم الكامل" : "Full Name",
                  filled: true,
                  fillColor: primaryGreen.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 30),

              if (_isEditing)
                _buildButton(
                  text: widget.isAr ? "حفظ التغييرات" : "Save Changes",
                  color: primaryGreen,
                  onTap: _updateProfile,
                  loading: _isLoading,
                ),

              const SizedBox(height: 12),

              _buildButton(
                text: widget.isAr ? "تسجيل الخروج" : "Logout",
                color: widget.isDark ? Colors.white.withOpacity(0.1) : primaryGreen.withOpacity(0.1),
                textColor: widget.isDark ? Colors.white : primaryGreen,
                onTap: _handleLogout,
                loading: false,
                isOutlined: true,
              ),
              
              const SizedBox(height: 10),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.isAr ? "إغلاق" : "Close", style: TextStyle(color: subTextColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required Color color, required VoidCallback onTap, required bool loading, Color? textColor, bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isOutlined ? BorderSide(color: color) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: loading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}