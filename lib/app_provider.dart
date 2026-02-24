import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:firebase_storage/firebase_storage.dart'; //
import 'dart:convert';
import 'dart:io';

class AppProvider with ChangeNotifier {
  // --- متغيرات Firebase (المصدر الأساسي للاسم والصورة حالياً) ---
  String _userName = "User";
  String? _userPhotoUrl;
  bool _isUploading = false;

  // --- ميزاتك القديمة (مخزنة محلياً) ---
  bool _isDarkMode = true;
  bool _isArabic = true;
  String _fullName = "";
  String _jobTitle = "";
  String _email = "";
  String _phone = "";
  String? _profileImagePath; 
  String _university = "";
  String _degree = "";
  String _gradYear = "";
  List<Map<String, String>> _experiences = [];
  String _bio = ""; 
  List<String> _skills = []; 

  // --- Getters ---
  String get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get isUploading => _isUploading;
  
  bool get isDarkMode => _isDarkMode;
  bool get isArabic => _isArabic;
  String get fullName => _fullName;
  String get jobTitle => _jobTitle;
  String get email => _email;
  String get phone => _phone;
  String? get profileImagePath => _profileImagePath;
  String get university => _university;
  String get degree => _degree;
  String get gradYear => _gradYear;
  List<Map<String, String>> get experiences => _experiences;
  String get bio => _bio;
  List<String> get skills => _skills;

  AppProvider() { 
    _loadData(); 
    fetchFirebaseUserData(); // جلب البيانات عند تشغيل التطبيق
  }

  // --- 1. دالة جلب البيانات من Firebase وتحديث الواجهة ---
  void fetchFirebaseUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userName = user.displayName ?? "User"; // تحديث المتغير المحلي
      _userPhotoUrl = user.photoURL;
      notifyListeners(); // إشعار الهوم بالتغيير
    }
  }

  // --- 2. دالة حفظ البيانات الشخصية (تحدث Firebase + المحلي) ---
  Future<void> savePersonalInfo(String n, String j, String e, String p) async {
    _fullName = n; 
    _jobTitle = j; 
    _email = e; 
    _phone = p;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // تحديث الاسم في سحابة Firebase
      await user.updateDisplayName(n);
      await user.reload();
      
      // مزامنة الاسم المحلي فوراً ليظهر في الهوم
      _userName = FirebaseAuth.instance.currentUser?.displayName ?? n;
    }

    await _saveToPrefs(); 
    notifyListeners(); // هذا هو السطر اللي بيغير "User" لاسمك الحقيقي فوراً
  }

  // --- 3. دالة رفع الصورة لـ Firebase Storage ---
  Future<void> uploadUserImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      
      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      _userPhotoUrl = downloadUrl;
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // --- بقية الدوال الأصلية الخاصة بك ---
  void toggleTheme() { _isDarkMode = !_isDarkMode; _saveToPrefs(); notifyListeners(); }
  void toggleLanguage() { _isArabic = !_isArabic; _saveToPrefs(); notifyListeners(); }
  void saveBio(String text) { _bio = text; _saveToPrefs(); notifyListeners(); }
  
  void addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      _skills.add(skill); _saveToPrefs(); notifyListeners();
    }
  }
  
  void removeSkill(int index) { _skills.removeAt(index); _saveToPrefs(); notifyListeners(); }
  
  void deleteExperience(int index) {
    if (index >= 0 && index < _experiences.length) {
      _experiences.removeAt(index); _saveToPrefs(); notifyListeners();
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) { 
      _profileImagePath = image.path; 
      await uploadUserImage(File(image.path)); 
      await _saveToPrefs(); 
      notifyListeners(); 
    }
  }

  Future<void> saveEducation(String uni, String deg, String year) async {
    _university = uni; _degree = deg; _gradYear = year;
    await _saveToPrefs(); notifyListeners();
  }

  void addExperience(String comp, String pos, String dur) {
    _experiences.add({'company': comp, 'position': pos, 'duration': dur});
    _saveToPrefs(); notifyListeners();
  }

  // --- الحفظ والتحميل من الذاكرة المحلية (SharedPreferences) ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDarkMode);
    await prefs.setBool('isAr', _isArabic);
    await prefs.setString('full_name', _fullName);
    await prefs.setString('bio', _bio);
    await prefs.setStringList('skills_list', _skills);
    await prefs.setString('profile_image', _profileImagePath ?? "");
    await prefs.setString('exp_list', json.encode(_experiences));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDark') ?? true;
    _isArabic = prefs.getBool('isAr') ?? true;
    _fullName = prefs.getString('full_name') ?? "";
    _bio = prefs.getString('bio') ?? "";
    _skills = prefs.getStringList('skills_list') ?? [];
    _profileImagePath = prefs.getString('profile_image');
    if (_profileImagePath == "") _profileImagePath = null;
    String? data = prefs.getString('exp_list');
    if (data != null && data.isNotEmpty) {
      _experiences = List<Map<String, String>>.from(json.decode(data));
    }
    notifyListeners();
  }
}