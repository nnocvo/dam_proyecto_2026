import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  Stream<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance
        .collection('categorias')
        .orderBy('nombre')
        .snapshots();
  }

  Future<void> agregarPublicacion({
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fecha,
    required Uint8List foto,
    required String autorUid,
    required String autorNombre,
  }) {
    return FirebaseFirestore.instance.collection('publicaciones').add({
      'tiulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.fromDate(fecha),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorUid': autorUid,
      'autorNombre': autorNombre,
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance.collection('publicaciones').snapshots();
  }

  Future<void> marcarDevuelto(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .update({'estado': 'Devuelto'});
  }

  Future<void> borrarPublicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .delete();
  }
}
