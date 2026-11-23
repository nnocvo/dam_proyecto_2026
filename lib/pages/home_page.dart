import 'package:flutter/material.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Future<void> confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (salir == true) {
      await AuthService().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final nombre = usuario?.displayName ?? 'Usuario';
    final primerNombre = nombre.split(' ').first;
    return Scaffold(
      drawer: Drawer(
        backgroundColor: kCrema,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nombre),
              accountEmail: Text(usuario?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(usuario!.photoURL!),
              ),
              decoration: BoxDecoration(color: kPetroleo),
            ),

            Spacer(),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.rightFromBracket),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                confirmarSalida(context);
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      appBar: AppBar(title: Text('Bienvenido, $primerNombre!!')),
      body: Center(child: Text('aqui irá la lista')),
    );
  }
}
