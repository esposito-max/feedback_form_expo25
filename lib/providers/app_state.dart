import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_form.dart';

// Firestore Path Helper
CollectionReference<Map<String, dynamic>> getSubmissionsCollection() {
  return FirebaseFirestore.instance.collection('submissions');
}

class AppState extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentSectionIndex = 0;
  int get currentSectionIndex => _currentSectionIndex;

  FeedbackForm _currentDraft = FeedbackForm(id: '', timestamp: DateTime.now());
  FeedbackForm get currentDraft => _currentDraft;

  bool _isAdminLoggedIn = false;
  bool get isAdminLoggedIn => _isAdminLoggedIn;

  void setSection(int index) {
    _currentSectionIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void updateDraft(void Function(FeedbackForm) updates) {
    updates(_currentDraft);
    notifyListeners();
  }

  // UPDATED: Submit only saves data, does NOT navigate away
  Future<void> submitForm() async {
    final collection = getSubmissionsCollection();
    _currentDraft.timestamp = DateTime.now();
    
    try {
      await collection.add(_currentDraft.toMap());
      // Removed setSection(0) and reset logic from here
      notifyListeners();
    } catch (e) {
      debugPrint("Error submitting form: $e");
      rethrow;
    }
  }

  // NEW: Resets the form state and goes back to Home
  void resetForm() {
    _currentDraft = FeedbackForm(id: '', timestamp: DateTime.now());
    setSection(0);
    notifyListeners();
  }

  // Login Logic
  Future<bool> loginAdmin(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      _isAdminLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Admin login failed: $e");
      return false;
    }
  }

  // Logout Logic
  Future<void> logoutAdmin() async {
    await FirebaseAuth.instance.signOut(); 
    await FirebaseAuth.instance.signInAnonymously(); 
    _isAdminLoggedIn = false;
    notifyListeners();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
  }

  static AppState read(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AppStateProvider>()!.notifier!;
  }
}