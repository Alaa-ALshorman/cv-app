import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class CVModel {
  String id;
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
    'id': id, 'fullName': fullName, 'jobTitle': jobTitle, 'email': email,
    'phone': phone, 'bio': bio, 'university': university, 'degree': degree,
    'gradYear': gradYear, 'profileImagePath': profileImagePath,
    'templateId': templateId, 'skills': skills, 'experiences': experiences,
  };

  factory CVModel.fromJson(Map<String, dynamic> json) => CVModel(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
    experiences: (json['experiences'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
  );
}

class AppProvider with ChangeNotifier {
  bool isDarkMode = true;
  bool isArabic = true;
  List<CVModel> allCVs = [];
  int currentCVIndex = -1;

  
  CVModel? get currentCV => currentCVIndex != -1 && currentCVIndex < allCVs.length ? allCVs[currentCVIndex] : null;

  
  String get userName => fullName.isNotEmpty ? fullName : (isArabic ? "مستخدم جديد" : "New User");
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

  AppProvider() { _loadData(); }

  
  void fetchFirebaseUserData() {
   
    notifyListeners();
  }

  void saveSelectedTemplate(String tId) {
    
    if (currentCV != null) {
      currentCV!.templateId = tId;
      _saveAndNotify();
    }
  }

  
  void updatePersonalInfo(String name, String job, String mail, String ph) {
    if (currentCV == null) createNewCV();
    currentCV!.fullName = name;
    currentCV!.jobTitle = job;
    currentCV!.email = mail;
    currentCV!.phone = ph;
    _saveAndNotify();
  }

  void updateBio(String newBio) {
    if (currentCV != null) {
      currentCV!.bio = newBio;
      _saveAndNotify();
    }
  }

  void updateEducation(String uni, String deg, String year) {
    if (currentCV != null) {
      currentCV!.university = uni;
      currentCV!.degree = deg;
      currentCV!.gradYear = year;
      _saveAndNotify();
    }
  }

 
  void addExperience(String comp, String pos, String dur) {
    if (currentCV != null) {
      currentCV!.experiences.add({'company': comp, 'position': pos, 'duration': dur});
      _saveAndNotify();
    }
  }

  void deleteExperience(int index) {
    if (currentCV != null) {
      currentCV!.experiences.removeAt(index);
      _saveAndNotify();
    }
  }


  void addSkill(String skill) {
    if (currentCV != null) {
      currentCV!.skills.add(skill);
      _saveAndNotify();
    }
  }

  void deleteSkill(int index) {
    if (currentCV != null) {
      currentCV!.skills.removeAt(index);
      _saveAndNotify();
    }
  }

  void createNewCV() {
    allCVs.add(CVModel(id: DateTime.now().millisecondsSinceEpoch.toString()));
    currentCVIndex = allCVs.length - 1;
    _saveAndNotify();
  }

  void deleteCV(int index) {
    if (index >= 0 && index < allCVs.length) {
      allCVs.removeAt(index);
      if (currentCVIndex >= allCVs.length) currentCVIndex = allCVs.length - 1;
      _saveAndNotify();
    }
  }

 
  set currentCVIndexSet(int index) {
    currentCVIndex = index;
    notifyListeners();
  }

  
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && currentCV != null) {
      currentCV!.profileImagePath = pickedFile.path;
      _saveAndNotify();
    }
  }

  void toggleTheme() { isDarkMode = !isDarkMode; notifyListeners(); }
  void toggleLanguage() { isArabic = !isArabic; notifyListeners(); }

  void _saveAndNotify() { _saveToPrefs(); notifyListeners(); }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('all_cvs_v2', json.encode(allCVs.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('all_cvs_v2');
    if (data != null) {
      allCVs = (json.decode(data) as List).map((e) => CVModel.fromJson(e)).toList();
      if (allCVs.isNotEmpty && currentCVIndex == -1) currentCVIndex = 0;
      notifyListeners();
    }
  }
}