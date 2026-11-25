import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/pages/publicar_page.dart';
import 'package:proyecto_dam_2026/services/auth_service.dart';
import 'package:proyecto_dam_2026/services/fs_service.dart';
import 'package:proyecto_dam_2026/widgets/publicacion_card.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FsService fsService = FsService();

  bool verSoloMias = false;

  String get miUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String get miNombre {
    String nombreCompleto =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario';
    return nombreCompleto.split(' ')[0];
  }

  void confirmarDevolucion(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Marcar como devuelto?'),
        content: const Text(
          'El objeto pasará a estado Devuelto. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDevuelto,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              fsService.marcarDevuelto(id);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void confirmarBorrado(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar publicación?'),
        content: const Text(
          'Esta acción destruirá el documento y su imagen adjunta. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPerdido,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              fsService.borrarPublicacion(id);
              Navigator.pop(context);
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  void confirmarSalida(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Saldrás de tu cuenta actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPetroleo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nombre = usuario?.displayName ?? 'Usuario';
    final correo = usuario?.email ?? 'Sin correo';
    final fotoUrl = usuario?.photoURL;

    ImageProvider? imagenAvatar;
    Widget? iconoAvatar;

    if (fotoUrl != null) {
      imagenAvatar = NetworkImage(fotoUrl);
    } else {
      iconoAvatar = const Icon(Icons.person, size: 40, color: kPetroleo);
    }

    return Scaffold(
      backgroundColor:
          Colors.white, // O kCrema, si lo tienes definido en constants
      drawer: Drawer(
        backgroundColor: Colors.white, // O kCrema
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nombre),
              accountEmail: Text(correo),
              currentAccountPicture: CircleAvatar(
                backgroundColor: kAmbar, // O kAmbarClaro
                backgroundImage: imagenAvatar,
                child: iconoAvatar,
              ),
              decoration: const BoxDecoration(color: kPetroleo),
            ),
            ListTile(
              leading: Icon(MdiIcons.formatListBulleted, color: kPetroleo),
              title: const Text('Todas las publicaciones'),
              selected: !verSoloMias,
              onTap: () {
                setState(() {
                  verSoloMias = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.accountCheck, color: kPetroleo),
              title: const Text('Mis publicaciones'),
              selected: verSoloMias,
              onTap: () {
                setState(() {
                  verSoloMias = true;
                });
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: Icon(MdiIcons.logout, color: kPetroleo),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                confirmarSalida(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),

      appBar: AppBar(
        title: Text('Hola, $miNombre'),
        backgroundColor: kPetroleo,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: fsService.publicaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay publicaciones registradas.'),
            );
          }

          var documentos = snapshot.data!.docs;

          if (verSoloMias) {
            documentos = documentos.where((doc) {
              final datos = doc.data() as Map<String, dynamic>;
              return datos['autorUid'] == miUid;
            }).toList();
          }

          if (documentos.isEmpty) {
            return const Center(
              child: Text('No has publicado ningún objeto aún.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final item = documentos[index];
              return PublicacionCard(
                item: item,
                miUid: miUid,
                alMarcarDevuelto: () => confirmarDevolucion(item.id),
                alBorrar: () => confirmarBorrado(item.id),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kAmbar,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicarPage()),
          );
        },
      ),
    );
  }
}
