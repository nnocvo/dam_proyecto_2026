import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_dam_2026/constants.dart';
import 'package:proyecto_dam_2026/pages/publicar_page.dart';
import 'package:proyecto_dam_2026/services/auth_service.dart';
import 'package:proyecto_dam_2026/services/fs_service.dart';
import 'package:proyecto_dam_2026/widgets/publicacion_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool soloMias = false;

  Future<void> confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: kPetroleo),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (salir == true) {
      await AuthService().logout();
    }
  }

  Future<void> confirmarDevuelto(
    BuildContext context,
    String id,
    String titulo,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Marcar como devuelto'),
          content: Text('¿Confirmas que "$titulo" ya fue devuelto a su dueño?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: kDevuelto),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      await FsService().marcarDevuelto(id);
    }
  }

  Future<void> confirmarBorrar(
    BuildContext context,
    String id,
    String titulo,
  ) async {
    final borrar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Borrar publicación'),
          content: Text('¿Seguro que deseas eliminar "$titulo"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: kPerdido),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );

    if (borrar == true) {
      await FsService().borrarPublicacion(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    String nombre = usuario?.displayName ?? 'Usuario';
    String correo = usuario?.email ?? '';
    String miUid = usuario?.uid ?? '';
    String primerNombre = nombre.split(' ').first;

    // Avatar del Drawer
    ImageProvider? imagenAvatar;
    Widget? iconoAvatar = Icon(MdiIcons.account, color: kPetroleo);
    if (usuario?.photoURL != null) {
      imagenAvatar = NetworkImage(usuario!.photoURL!);
      iconoAvatar = null;
    }

    Color colorTextoTodas = kPetroleo;
    Color colorTextoMias = kPetroleo;
    if (soloMias) {
      colorTextoMias = Colors.white;
    } else {
      colorTextoTodas = Colors.white;
    }

    return Scaffold(
      backgroundColor: kCrema,
      drawer: Drawer(
        backgroundColor: kCrema,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nombre),
              accountEmail: Text(correo),
              currentAccountPicture: CircleAvatar(
                backgroundColor: kAmbarClaro,
                backgroundImage: imagenAvatar,
                child: iconoAvatar,
              ),
              decoration: const BoxDecoration(color: kPetroleo),
            ),
            ListTile(
              leading: Icon(MdiIcons.formatListBulleted, color: kPetroleo),
              title: const Text('Todas las publicaciones'),
              selected: !soloMias,
              onTap: () {
                setState(() {
                  soloMias = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.accountCheck, color: kPetroleo),
              title: const Text('Mis publicaciones'),
              selected: soloMias,
              onTap: () {
                setState(() {
                  soloMias = true;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicarPage()),
          );
        },
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Publicar'),
        backgroundColor: kAmbar,
        foregroundColor: kPetroleo,
      ),
      appBar: AppBar(
        backgroundColor: kPetroleo,
        foregroundColor: Colors.white,
        title: Text('Hola, $primerNombre'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Todas')),
                    selected: !soloMias,
                    selectedColor: kPetroleo,
                    labelStyle: TextStyle(
                      color: colorTextoTodas,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (seleccionado) {
                      setState(() {
                        soloMias = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Mis publicaciones')),
                    selected: soloMias,
                    selectedColor: kPetroleo,
                    labelStyle: TextStyle(
                      color: colorTextoMias,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (seleccionado) {
                      setState(() {
                        soloMias = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FsService().publicaciones(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPetroleo),
                  );
                }

                List<QueryDocumentSnapshot> lista = snapshot.data!.docs;

                // Si el filtro está activo, dejamos solo las del usuario
                if (soloMias) {
                  List<QueryDocumentSnapshot> filtradas = [];
                  for (var item in lista) {
                    final datos = item.data() as Map<String, dynamic>;
                    if (datos['autorUid'] == miUid) {
                      filtradas.add(item);
                    }
                  }
                  lista = filtradas;
                }

                if (lista.isEmpty) {
                  String mensaje = 'No hay objetos publicados';
                  if (soloMias) {
                    mensaje = 'Aún no tienes publicaciones';
                  }
                  return Center(
                    child: Text(
                      mensaje,
                      style: const TextStyle(color: kPetroleo, fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final datos = item.data() as Map<String, dynamic>;
                    String titulo = datos['titulo'] ?? 'Sin título';

                    return PublicacionCard(
                      item: item,
                      miUid: miUid,
                      alMarcarDevuelto: () {
                        confirmarDevuelto(context, item.id, titulo);
                      },
                      alBorrar: () {
                        confirmarBorrar(context, item.id, titulo);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
