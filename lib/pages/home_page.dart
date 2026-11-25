import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/pages/publicar_page.dart';
import 'package:proyecto_dam_2026/services/fs_service.dart';
import 'package:proyecto_dam_2026/widgets/publicacion_card.dart';

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
    String nombreCompleto = FirebaseAuth.instance.currentUser?.uid ?? '';
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
        content: const Text('Esta acción eliminará. No se puede deshacer.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $miNombre'),
        backgroundColor: kPetroleo,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: Icon(verSoloMias ? Icons.filter_alt_off : Icons.filter_alt),
            label: Text(verSoloMias ? 'Ver Todo' : 'Mis Avisos'),
            onPressed: () {
              setState(() {
                verSoloMias = !verSoloMias;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fsService.publicaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay publicaciones registradas.'));
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
