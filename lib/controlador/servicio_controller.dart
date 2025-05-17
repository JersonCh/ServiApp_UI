import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/modelo/servicio_model.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ServicioController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Método para registrar un nuevo servicio (mantenido igual)
  Future<bool> registrarServicio({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String subcategoria,
    required String telefono,
    required String ubicacion,
    File? imagenFile,
  }) async {
    try {
      final String? idUsuario = GlobalUser.uid;
      
      if (idUsuario == null) {
        print('Error: No hay un usuario logueado');
        return false;
      }

      Map<String, dynamic> servicioData = {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'subcategoria': subcategoria,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'idusuario': idUsuario,
        'estado': 'true',
        'date': FieldValue.serverTimestamp(),
        'sumaCalificaciones': 0,  // Nuevo campo inicializado en 0
        'totalCalificaciones': 0, // Nuevo campo inicializado en 0
      };

      if (imagenFile != null) {
        servicioData['imagen'] = await _subirImagen(imagenFile, idUsuario);
      }

      await _firestore.collection('servicios').add(servicioData);
      return true;
    } catch (e) {
      print('Error al registrar servicio: $e');
      return false;
    }
  }

  // Método para subir imágenes (mantenido igual)
  Future<String> _subirImagen(File imageFile, String userId) async {
    try {
      final String nombreArchivo = _uuid.v4();
      final Reference storageRef = _storage
          .ref()
          .child('servicios')
          .child(userId)
          .child('$nombreArchivo.jpg');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      throw Exception('No se pudo subir la imagen');
    }
  }

  // Método para obtener subcategorías (mantenido igual)
  List<String> obtenerSubcategorias(String categoria) {
    switch (categoria) {
      case 'Tecnologia':
        return [
          'Reparación de computadoras y laptops',
          'Soporte técnico',
          'Instalación de software',
          'Redes y conectividad',
          'Reparación de celulares',
          'Diseño web',
        ];
      case 'Vehículos':
        return [
          'Mecánica general',
          'Electricidad automotriz',
          'Planchado y pintura',
          'Cambio de aceite',
          'Lavado de autos',
          'Servicio de grúa',
        ];
      case 'Eventos':
        return [
          'Organización de eventos',
          'Catering',
          'Fotografía y video',
          'Animación',
          'Decoración',
          'DJ y sonido',
        ];
      case 'Estetica':
        return [
          'Corte de cabello',
          'Manicure y pedicure',
          'Maquillaje',
          'Tratamientos faciales',
          'Depilación',
          'Masajes',
        ];
      case 'Salud y Bienestar':
        return [
          'Enfermería a domicilio',
          'Fisioterapia',
          'Nutrición',
          'Psicología',
          'Entrenamiento personal',
          'Yoga y meditación',
        ];
      case 'Servicios Generales':
        return [
          'Electricidad',
          'Gasfitería',
          'Carpintería',
          'Albañilería',
          'Pintura',
          'Cerrajería',
        ];
      case 'Educacion':
        return [
          'Clases particulares',
          'Idiomas',
          'Música',
          'Arte',
          'Apoyo escolar',
          'Preparación universitaria',
        ];
      case 'Limpieza':
        return [
          'Limpieza de hogares',
          'Limpieza de oficinas',
          'Lavado de muebles',
          'Lavandería',
          'Fumigación',
          'Jardinería',
        ];
      default:
        return [];
    }
  }

  // ========== NUEVOS MÉTODOS PARA CALIFICACIONES ==========

  // Obtener servicios por subcategoría (nuevo)
  Stream<List<Servicio>> obtenerServiciosPorSubcategoria(String subcategoria) {
    return _firestore
        .collection('servicios')
        .where('subcategoria', isEqualTo: subcategoria)
        .where('estado', isEqualTo: "true")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Servicio.fromFirestore(doc))
            .toList());
  }

  // Calificar un servicio (nuevo)
  Future<void> calificarServicio({
    required String servicioId,
    required int puntuacion,
    required String usuarioId,
    required String nombreUsuario,
    String? comentario,
  }) async {
    final batch = _firestore.batch();
    final puntuacionValida = puntuacion.clamp(1, 5); // Asegurar 1-5

    // 1. Agregar calificación individual
    final calificacionRef = _firestore
        .collection('servicios')
        .doc(servicioId)
        .collection('calificaciones')
        .doc();
    
    batch.set(calificacionRef, {
      'puntuacion': puntuacionValida,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'comentario': comentario,
      'fecha': FieldValue.serverTimestamp(),
    });

    // 2. Actualizar contadores en el servicio
    final servicioRef = _firestore.collection('servicios').doc(servicioId);
    batch.update(servicioRef, {
      'totalCalificaciones': FieldValue.increment(1),
      'sumaCalificaciones': FieldValue.increment(puntuacionValida),
    });

    // 3. Registrar en el usuario para evitar duplicados
    final usuarioRef = _firestore.collection('usuarios').doc(usuarioId);
    batch.update(usuarioRef, {
      'serviciosCalificados': FieldValue.arrayUnion([servicioId])
    });

    await batch.commit();
  }

  // Obtener calificaciones de un servicio (nuevo)
  Stream<List<Map<String, dynamic>>> obtenerCalificaciones(String servicioId) {
    return _firestore
        .collection('servicios')
        .doc(servicioId)
        .collection('calificaciones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'puntuacion': data['puntuacion'],
                'comentario': data['comentario'],
                'nombreUsuario': data['nombreUsuario'],
                'fecha': (data['fecha'] as Timestamp).toDate(),
              };
            })
            .toList());
  }

  // Verificar si usuario ya calificó (nuevo)
  Future<bool> usuarioYaCalifico(String servicioId, String usuarioId) async {
    final doc = await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .get();
    
    final serviciosCalificados = List<String>.from(doc.data()?['serviciosCalificados'] ?? []);
    return serviciosCalificados.contains(servicioId);
  }
}