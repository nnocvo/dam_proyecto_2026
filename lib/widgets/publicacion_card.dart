import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_dam_2026/constants.dart';

class PublicacionCard extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final String miUid;
  final void Function() alMarcarDevuelto;
  final void Function() alBorrar;

  const PublicacionCard({
    super.key,
    required this.item,
    required this.miUid,
    required this.alMarcarDevuelto,
    required this.alBorrar,
  });

  @override
  Widget build(BuildContext context) {
    final datos = item.data() as Map<String, dynamic>;

    String titulo = datos['titulo'] ?? 'Sin título';
    String tipo = datos['tipo'] ?? 'Perdido';
    String categoria = datos['categoria'] ?? 'Otros';
    String estado = datos['estado'] ?? 'Vigente';
    String autorUid = datos['autorUid'] ?? '';

    bool esMia = (autorUid == miUid);
    bool devuelto = (estado == 'Devuelto');

    Color colorFondo = devuelto ? Colors.grey.shade300 : Colors.white;

    Widget widgetFoto;
    if (datos['foto'] != null && datos['foto'] is Blob) {
      Blob fotoBlob = datos['foto'];
      widgetFoto = Image.memory(
        fotoBlob.bytes,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    } else {
      widgetFoto = const SizedBox(
        width: 60,
        height: 60,
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return Card(
      color: colorFondo,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widgetFoto,
        ),

        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Categoría: $categoria\nTipo: $tipo | Estado: $estado'),

        trailing: esMia
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!devuelto)
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: alMarcarDevuelto,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: alBorrar,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
