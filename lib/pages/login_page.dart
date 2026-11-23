import 'package:flutter/material.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool cargando = false;

  Future<void> ingresar() async {
    setState(() {
      cargando = true;
    });
    try {
      await AuthService().loginGoogle();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPetroleo,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32, 4, 32, 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.magnifyingGlassLocation,
                size: 90,
                color: kAmbar,
              ),
              SizedBox(height: 24),
              Text(
                'Perdidos & Encontrados',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Publica lo que perdiste o encontraste en la sede',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, color: Colors.white70),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: cargando ? null : ingresar,
                  icon: const FaIcon(FontAwesomeIcons.google),
                  label: Text(
                    cargando ? 'Ingresando...' : 'Ingresar con Google',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPetroleo,
                    disabledBackgroundColor: kAmbarClaro,
                    disabledForegroundColor: kPetroleo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
