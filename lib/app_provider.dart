import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CVModel {
  String id;
  String userId;
  String fullName;
  String jobTitle;
  String email;
  String phone;
  String bio;
  String university;
  String degree;
  String gradYear;
  String? profileImagePath;
  String? templateId;
  List<String> skills;
  List<Map<String, String>> experiences;

  CVModel({
    required this.id,
    this.userId = "",
    this.fullName = "",
    this.jobTitle = "",
    this.email = "",
    this.phone = "",
    this.bio = "",
    this.university = "",
    this.degree = "",
    this.gradYear = "",
    this.profileImagePath,
    this.templateId,
    this.skills = const [],
    this.experiences = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'jobTitle': jobTitle,
        'email': email,
        'phone': phone,
        'bio': bio,
        'university': university,
        'degree': degree,
        'gradYear': gradYear,
        'profileImagePath': profileImagePath,
        'templateId': templateId,
        'skills': skills,
        'experiences': experiences,
      };

  factory CVModel.fromJson(Map<String, dynamic> json) => CVModel(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: json['userId'] ?? "",
        fullName: json['fullName'] ?? "",
        jobTitle: json['jobTitle'] ?? "",
        email: json['email'] ?? "",
        phone: json['phone'] ?? "",
        bio: json['bio'] ?? "",
        university: json['university'] ?? "",
        degree: json['degree'] ?? "",
        gradYear: json['gradYear'] ?? "",
        profileImagePath: json['profileImagePath'],
        templateId: json['templateId'],
        skills: List<String>.from(json['skills'] ?? []),
        experiences: (json['experiences'] as List?)
                ?.map((e) => Map<String, String>.from(e))
                .toList() ??
            [],
      );
}

class AppProvider with ChangeNotifier {
  bool isDarkMode = true;
  bool isArabic = false;
  List<CVModel> _allCVs = [];
  String? _activeCvId;
  String _signUpName = "";

  List<CVModel> get allCVs {
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return _allCVs.where((cv) => cv.userId == currentUid).toList();
  }

  CVModel? get currentCV {
    if (_activeCvId == null) return null;
    for (final cv in _allCVs) {
      if (cv.id == _activeCvId) return cv;
    }
    return null;
  }

  String? get activeCvId => _activeCvId;

  bool get isCurrentCvContentReady {
    if (currentCV == null) return false;
    final t = currentCV!.templateId;
    return t != null && t.isNotEmpty;
  }

  void ensureDraftForBuilder() {
    if (currentCV == null) {
      createNewCV();
    }
  }

  void startNewCvDraft() {
    clearActiveCv();
    createNewCV();
  }

  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    final fromAuth = user?.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }
    if (_signUpName.isNotEmpty) {
      return _signUpName;
    }
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      final at = email.indexOf('@');
      if (at > 0) {
        return email.substring(0, at);
      }
    }
    return isArabic ? "مستخدم جديد" : "New User";
  }

  String? get profileImagePath => currentCV?.profileImagePath;

  String get fullName => currentCV?.fullName ?? "";
  String get jobTitle => currentCV?.jobTitle ?? "";
  String get email => currentCV?.email ?? "";
  String get phone => currentCV?.phone ?? "";
  String get bio => currentCV?.bio ?? "";
  String get university => currentCV?.university ?? "";
  String get degree => currentCV?.degree ?? "";
  String get gradYear => currentCV?.gradYear ?? "";
  List<String> get skills => currentCV?.skills ?? [];
  List<Map<String, String>> get experiences => currentCV?.experiences ?? [];

  AppProvider() {
    _loadData();
  }

  void fetchFirebaseUserData() {
    notifyListeners();
  }

  Future<T> withActiveCvForRender<T>(String? cvId, Future<T> Function() work) async {
    final String? before = _activeCvId;
    _activeCvId = cvId;
    try {
      return await work();
    } finally {
      _activeCvId = before;
    }
  }

  void clearActiveCv() {
    _activeCvId = null;
    notifyListeners();
  }

  void setActiveCvId(String? id) {
    _activeCvId = id;
    notifyListeners();
  }

  void saveAndResetForNextCV() {
    if (_activeCvId != null) {
      _saveToPrefs();
      _activeCvId = null;
      notifyListeners();
    }
  }

  void createNewCV() {
    if (currentCV != null) return;
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    CVModel newCV = CVModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUid,
    );
    _allCVs.add(newCV);
    _activeCvId = newCV.id;
    _saveToPrefs();
    notifyListeners();
  }

  void updatePersonalInfo(String name, String job, String mail, String ph) {
    if (!isCurrentCvContentReady) return;
    if (currentCV != null) {
      currentCV!.fullName = name;
      currentCV!.jobTitle = job;
      currentCV!.email = mail;
      currentCV!.phone = ph;
      _saveAndNotify();
    }
  }

  void addExperience(String company, String position, String duration) {
    if (!isCurrentCvContentReady) return;
    if (currentCV != null) {
      currentCV!.experiences = List.from(currentCV!.experiences)..add({
        'company': company,
        'position': position,
        'duration': duration,
      });
      _saveAndNotify();
    }
  }

  void deleteExperience(int index) {
    if (currentCV != null && index < currentCV!.experiences.length) {
      currentCV!.experiences.removeAt(index);
      _saveAndNotify();
    }
  }

  void addSkill(String skill) {
    if (!isCurrentCvContentReady) return;
    if (currentCV != null) {
      currentCV!.skills = List.from(currentCV!.skills)..add(skill);
      _saveAndNotify();
    }
  }

  void deleteSkill(int index) {
    if (currentCV != null && index < currentCV!.skills.length) {
      currentCV!.skills.removeAt(index);
      _saveAndNotify();
    }
  }

  void applyTemplateToCurrentCv(String templateId) {
    if (currentCV == null) return;
    currentCV!.templateId = templateId;
    _saveToPrefs();
    notifyListeners();
  }

  void updateBio(String newBio) {
    if (!isCurrentCvContentReady) return;
    currentCV?.bio = newBio;
    _saveAndNotify();
  }

  void updateEducation(String uni, String deg, String year) {
    if (!isCurrentCvContentReady) return;
    if (currentCV != null) {
      currentCV!.university = uni;
      currentCV!.degree = deg;
      currentCV!.gradYear = year;
      _saveAndNotify();
    }
  }

  void deleteCV(int index) {
    if (index < 0 || index >= allCVs.length) return;
    String idToDelete = allCVs[index].id;
    if (idToDelete == _activeCvId) {
      _activeCvId = null;
    }
    _allCVs.removeWhere((cv) => cv.id == idToDelete);
    _saveAndNotify();
  }

  void setSignUpName(String name) {
    _signUpName = name;
    notifyListeners();
  }

  void clearSignUpSessionLabel() {
    _signUpName = "";
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void toggleLanguage() {
    isArabic = !isArabic;
    notifyListeners();
  }

  Future<void> pickProfileImage() async {
    if (!isCurrentCvContentReady) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && currentCV != null) {
      currentCV!.profileImagePath = pickedFile.path;
      _saveAndNotify();
    }
  }

  void _saveAndNotify() {
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('all_cvs_v2', json.encode(_allCVs.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('all_cvs_v2');
    if (data != null) {
      _allCVs = (json.decode(data) as List).map((e) => CVModel.fromJson(e)).toList();
      _activeCvId = null;
      notifyListeners();
    }
  }
}
