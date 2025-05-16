
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ServicioController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar un nuevo servicio
Future<bool> registrarServicio({
  required String titulo,
  required String descripcion,
  required String categoria,
  required String subcategoria,
  required String telefono,
  required String ubicacion,
  File? imagenFile, // Parámetro opcional para la imagen
}) async {
  try {
    // Obtener el UID del usuario actual desde GlobalUser
    final String? idUsuario = GlobalUser.uid;
    
    if (idUsuario == null) {
      print('Error: No hay un usuario logueado');
      return false;
    }

    // Crear un mapa con los datos del servicio
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
    };

    // Si hay una imagen, subirla a Firebase Storage y obtener la URL
    if (imagenFile != null) {
      String imageUrl = await _subirImagen(imagenFile, idUsuario);
      servicioData['imagen'] = imageUrl;
    }

    // Crear un nuevo documento en la colección 'servicios'
    await _firestore.collection('servicios').add(servicioData);
    return true;
  } catch (e) {
    print('Error al registrar servicio: $e');
    return false;
  }
}
  // Método para obtener la lista de subcategorías según la categoría seleccionada
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
}

Future<String> _subirImagen(File imageFile, String userId) async {
  try {
    // Crear una referencia única para la imagen usando UUID
    final String nombreArchivo = Uuid().v4();
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('servicios')
        .child(userId)
        .child('$nombreArchivo.jpg');

    // Subir la imagen
    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask;
    
    // Obtener la URL de descarga
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Error al subir imagen: $e');
    throw Exception('No se pudo subir la imagen');
  }
}