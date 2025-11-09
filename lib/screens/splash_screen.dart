import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // fallback si image absente
          image: DecorationImage(
            image: const AssetImage('assets/beach.jpg'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) =>
                debugPrint("Image failed"),
          ),
        ),
        child: const Center(
          child: Text(
            'Kantan Gwadloup!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                    blurRadius: 4, color: Colors.black54, offset: Offset(2, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
