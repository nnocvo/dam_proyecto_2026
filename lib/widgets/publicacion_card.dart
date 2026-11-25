import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_dam_2026/constants.dart';

class PublicacionCard extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final String miUid;
  final VoidCallback alMarcarDevuelto;
  final VoidCallback alBorrar;

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
    String autor = datos['autorUid'] ?? '';

    // Revisar si la publicación es mía
    bool esMia = false;
    if (autor == miUid) {
      esMia = true;
    }

    // si fue devuelto
    bool devuelto = false;
    if (estado == 'Devuelto') {
      devuelto = true;
    }

    // Elegir colores según tipo y estado
    Color colorTipo = kEncontrado;
    if (tipo == 'Perdido') {
      colorTipo = kPerdido;
    }

    Color colorEstado = kAmbar;
    Color colorFondo = Colors.white;
    Color colorBorde = colorTipo;
    if (devuelto) {
      colorEstado = kDevuelto;
      colorFondo = Colors.grey.shade200;
      colorBorde = kDevuelto;
    }

    // Preparar el widget de la foto
    Widget widgetFoto;
    if (datos['foto'] != null && datos['foto'] is Blob) {
      Blob fotoBlob = datos['foto'];
      widgetFoto = Image.memory(fotoBlob.bytes, fit: BoxFit.cover);
    } else {
      widgetFoto = Container(
        color: const Color.fromRGBO(252, 227, 186, 1),
        child: FaIcon(FontAwesomeIcons.image, color: kPetroleo),
      );
    }

    return Card(
      color: colorFondo,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorBorde, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Miniatura de la foto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 75, height: 75, child: widgetFoto),
              ),
              const SizedBox(width: 12),

              // Título, categoría, tipo y estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPetroleoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categoría: $categoria',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        etiqueta(tipo, colorTipo),
                        etiqueta(estado, colorEstado),
                      ],
                    ),
                  ],
                ),
              ),

              // Puntos 6 y 7: Botones solo para el autor
              if (esMia)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!devuelto)
                      IconButton(
                        tooltip: 'Marcar como devuelto',
                        icon: Icon(
                          MdiIcons.checkCircle,
                          color: kDevuelto,
                          size: 22,
                        ),
                        onPressed: alMarcarDevuelto,
                      ),
                    IconButton(
                      tooltip: 'Borrar publicación',
                      icon: Icon(MdiIcons.trashCan, color: kPerdido, size: 22),
                      onPressed: alBorrar,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
