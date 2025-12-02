import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'providers/app_state.dart';
import 'ui/screens/user_wizard.dart';
import 'ui/screens/admin_panel.dart';

class ExpoColors {
  static const Color azulMarinho = Color(0xFF001343);
  static const Color azulCeleste = Color(0xFF00CCFF);
  static const Color verdeLimao  = Color(0xFF99CC33);
  static const Color surfaceDark = Color(0xFF0A2458); 
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase(); 
  
  runApp(
    AppStateProvider(
      notifier: AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpoTEA Form',
      debugShowCheckedModeBanner: false,
      // Global LTR setting (Best practice, keeps individual files clean)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ExpoColors.azulMarinho,
        primaryColor: ExpoColors.azulCeleste,
        colorScheme: const ColorScheme.dark(
          primary: ExpoColors.azulCeleste,
          secondary: ExpoColors.verdeLimao,
          surface: ExpoColors.surfaceDark,
          background: ExpoColors.azulMarinho,
        ),
        fontFamily: 'Roboto', 
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.2), 
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white30),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ExpoColors.azulCeleste, width: 2),
          ),
          prefixIconColor: ExpoColors.azulCeleste,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ExpoColors.azulCeleste,
            foregroundColor: ExpoColors.azulMarinho,
            elevation: 8,
            shadowColor: ExpoColors.azulCeleste.withOpacity(0.4),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white30),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: ExpoColors.azulCeleste,
          thumbColor: ExpoColors.azulCeleste,
          inactiveTrackColor: Colors.white.withOpacity(0.1),
          trackHeight: 4,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _handleLogoTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    } else {
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(milliseconds: 500), () {
        _tapCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    
    // DETECT KEYBOARD: If bottom insets > 0, keyboard is open.
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001343), 
              Color(0xFF00081C), 
            ],
          ),
        ),
        child: Column(
          children: [
            // --- LOGO SHRINK LOGIC ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isKeyboardOpen ? 0 : 200, // Hides logo when typing
              child: SingleChildScrollView( 
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 200,
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: GestureDetector(
                        onTap: _handleLogoTap,
                        behavior: HitTestBehavior.opaque, 
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Image.asset(
                            'assets/Expo_2025.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, _, __) => const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 Icon(Icons.hexagon_outlined, color: ExpoColors.azulCeleste),
                                 SizedBox(width: 8),
                                 Text("EXPO TEA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // --- FORM CONTENT ---
            Expanded(
              child: PageView(
                controller: appState.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  HomePage(),
                  FeedbackExpoPage(),
                  FeedbackRepresentantePage(),
                  FeedbackMontagemPage(),
                  FeedbackGeralPage(),
                  OutroPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}