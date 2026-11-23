import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_dam_2026/services/auth_service.dart';
import 'package:proyecto_dam_2026/services/fs_service.dart';

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  String? tipo;
  String? categoria;
  DateTime? fecha;
  Uint8List? fotoBytes;
  bool errorFoto = false;
  bool guardando = false;
  bool eligiendoFoto = false;
  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> elegirFechaHora() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (dia == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    final elegida = DateTime(
      dia.year,
      dia.month,
      dia.day,
      hora.hour,
      hora.minute,
    );

    if (elegida.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora no puede ser posterior a la actual'),
        ),
      );
      return;
    }

    setState(() {
      fecha = elegida;
      fechaCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(fecha!);
    });
  }

  Future<void> elegirFoto(ImageSource origen) async {
    if (eligiendoFoto) return;
    setState(() => eligiendoFoto = true);
    try {
      final archivo = await ImagePicker().pickImage(
        source: origen,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (archivo == null) return;

      final bytes = await archivo.readAsBytes();

      if (bytes.length > 900 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La foto es muy pesada, intenta con otra'),
          ),
        );
        return;
      }

      setState(() {
        fotoBytes = bytes;
        errorFoto = false;
      });
    } finally {
      if (mounted) setState(() => eligiendoFoto = false);
    }
  }

  Future<void> publicar() async {
    final formularioOk = formKey.currentState!.validate();
    setState(() {
      errorFoto = fotoBytes == null;
    });
    if (!formularioOk || fotoBytes == null) return;

    final usuario = AuthService().usuarioActual!;

    setState(() => guardando = true);
    try {
      await FsService().agregarPublicacion(
        titulo: tituloCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        tipo: tipo!,
        categoria: categoria!,
        lugar: lugarCtrl.text.trim(),
        fecha: fecha!,
        foto: fotoBytes!,
        autorUid: usuario.uid,
        autorNombre: usuario.displayName ?? 'Anónimo',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('¡Publicación creada!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo publicar: $e')));
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publicar objeto')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.white,
              ),
              child: fotoBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [FaIcon(FontAwesomeIcons.camera)],
                    )
                  : Image.memory(fotoBytes!, fit: BoxFit.cover),
            ),
            if (errorFoto)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'La foto es obligatoria',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => elegirFoto(ImageSource.camera),
                    icon: const FaIcon(FontAwesomeIcons.camera, size: 16),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => elegirFoto(ImageSource.gallery),
                    icon: const FaIcon(FontAwesomeIcons.images, size: 16),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Audífonos Bluetooth negros',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa un título';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Audifono marca sony inalambricos color negro',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: lugarCtrl,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ej: Casino',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Ingresa una ubicación';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Perdido', child: Text('Perdido')),
                DropdownMenuItem(
                  value: 'Encontrado',
                  child: Text('Encontrado'),
                ),
              ],
              onChanged: (valor) {
                setState(() {
                  tipo = valor;
                });
              },
              validator: (valor) => valor == null
                  ? 'Elige si lo perdiste o lo encontraste'
                  : null,
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FsService().categorias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                final docs = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: docs.map((doc) {
                    final nombre = doc['nombre'] as String;
                    return DropdownMenuItem(value: nombre, child: Text(nombre));
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      categoria = valor;
                    });
                  },
                  validator: (valor) =>
                      valor == null ? 'Elige una categoría' : null,
                );
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: fechaCtrl,
              readOnly: true,
              onTap: elegirFechaHora,
              decoration: const InputDecoration(
                labelText: 'Fecha y hora',
                hintText: 'Toca para elegir',
                border: OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: FaIcon(FontAwesomeIcons.calendarDays, size: 20),
                ),
              ),
              validator: (valor) => fecha == null
                  ? 'Elige cuándo lo perdiste o encontraste'
                  : null,
            ),

            SizedBox(height: 24),
            FilledButton(
              onPressed: guardando ? null : publicar,
              child: Text(guardando ? 'Publicando...' : 'Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
