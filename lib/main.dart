import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.signInAnonymously();
  
  runApp(const sablesargassesApp());
}

class sablesargassesApp extends StatelessWidget {
  const sablesargassesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sable & Sargasses',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(), 
    );
  }
}
