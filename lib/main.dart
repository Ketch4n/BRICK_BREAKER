import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/widgets/game_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCyabvUZ3v7l58LRaY4tLEYgmOisJ6CiN4",
          authDomain: "brickbreaker-3303e.firebaseapp.com",
          projectId: "brickbreaker-3303e",
          storageBucket: "brickbreaker-3303e.appspot.com",
          messagingSenderId: "908664539996",
          appId: "1:908664539996:web:ace2a70a37e88ed30b0f99",
          measurementId: "G-EX1HLB7BYN"));
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GameApp(),
    // Add other MaterialApp properties as needed
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
