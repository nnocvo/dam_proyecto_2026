import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perdidos & Encontrados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPetroleo,
          primary: kPetroleo,
          secondary: kAmbar,
        ),
        scaffoldBackgroundColor: kCrema,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPetroleo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
