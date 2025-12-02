import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_form.dart';

// Firestore Path Helper
CollectionReference<Map<String, dynamic>> getSubmissionsCollection() {
  // UPDATED: We now use a simple root-level collection named 'submissions'.
  // Firestore will AUTOMATICALLY create this collection the moment 
  // you submit the first form. You do not need to create it manually.
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

  // Submit to Firestore
  Future<void> submitForm() async {
    final collection = getSubmissionsCollection();
    
    _currentDraft.timestamp = DateTime.now();
    
    try {
      // This is the magic line that creates the collection if it doesn't exist.
      await collection.add(_currentDraft.toMap());
      
      // Reset Draft
      _currentDraft = FeedbackForm(id: '', timestamp: DateTime.now());
      
      // Reset View
      setSection(0); 
      notifyListeners();
    } catch (e) {
      debugPrint("Error submitting form: $e");
      // In a real app, you might want to show a dialog here, 
      // but rethrowing allows the UI to handle the snackbar.
      rethrow;
    }
  }

  // Login Logic (Authentication)
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
    
    // Sign back in anonymously so the app remains usable for public submissions
    await FirebaseAuth.instance.signInAnonymously(); 
    
    _isAdminLoggedIn = false;
    notifyListeners();
  }
}

// InheritedNotifier to access state in the tree
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