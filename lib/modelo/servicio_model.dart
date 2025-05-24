import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String id;
  final String titulo;
  final String descripcion;
  final String telefono;
  final String subcategoria;
  final double sumaCalificaciones;
  final int totalCalificaciones;
  final IconData icon;
  final Color color;

  // Constructor principal
  Servicio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.telefono,
    required this.subcategoria,
    required this.sumaCalificaciones,
    required this.totalCalificaciones,
    required this.icon,
    required this.color,
  });

  // Getter para calcular el promedio dinámicamente
  double get promedioCalificaciones {
    if (totalCalificaciones <= 0) return 0.0;
    return sumaCalificaciones / totalCalificaciones;
  }

  // Factory constructor para crear instancias desde Firestore
  factory Servicio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Servicio(
      id: doc.id,
      titulo: data['titulo'] ?? 'Sin título',
      descripcion: data['descripcion'] ?? '',
      telefono: data['telefono'] ?? '',
      subcategoria: data['subcategoria'] ?? 'General',
      sumaCalificaciones: (data['sumaCalificaciones'] ?? 0.0).toDouble(),
      totalCalificaciones: data['totalCalificaciones'] ?? 0,
      icon: _parseIconData(data['icon'] ?? ''),
      color: _parseColor(data['color'] ?? ''),
    );
  }

  // Método para generar el mapa de actualización en Firestore
  Map<String, dynamic> toUpdateMap(double nuevaCalificacion) {
    return {
      'sumaCalificaciones': FieldValue.increment(nuevaCalificacion),
      'totalCalificaciones': FieldValue.increment(1),
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    };
  }

  // Método para convertir a mapa (útil para crear nuevos documentos)
  Map<String, dynamic> toFirestoreMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'telefono': telefono,
      'subcategoria': subcategoria,
      'sumaCalificaciones': sumaCalificaciones,
      'totalCalificaciones': totalCalificaciones,
      'icon': _iconToString(icon),
      'color': _colorToString(color),
    };
  }

  // Helpers para conversión de datos
  static IconData _parseIconData(String iconName) {
    final iconMap = {
      'computer': Icons.computer,
      'cleaning': Icons.cleaning_services,
      'plumbing': Icons.plumbing,
      'repair': Icons.build,
      'event': Icons.event,
      // Añade más mapeos según necesites
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.help_outline;
  }

  static Color _parseColor(String colorValue) {
    final colorMap = {
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      // Añade más colores según necesites
    };
    return colorMap[colorValue.toLowerCase()] ?? Colors.grey;
  }

  static String _iconToString(IconData icon) {
    final iconMap = {
      Icons.computer: 'computer',
      Icons.cleaning_services: 'cleaning',
      Icons.plumbing: 'plumbing',
      // Añade más mapeos inversos
    };
    return iconMap[icon] ?? 'help';
  }

  static String _colorToString(Color color) {
    final colorMap = {
      Colors.blue: 'blue',
      Colors.red: 'red',
      Colors.green: 'green',
      // Añade más mapeos inversos
    };
    return colorMap[color] ?? 'grey';
  }

  // Método para formatear el promedio para mostrar
  String get promedioFormateado => promedioCalificaciones.toStringAsFixed(1);

  // Método para mostrar información de calificaciones
  String get infoCalificaciones {
    if (totalCalificaciones == 0) return 'Sin calificaciones';
    return '$promedioFormateado ($totalCalificaciones ${totalCalificaciones == 1 ? 'reseña' : 'reseñas'})';
  }

  static Future<List<Servicio>> obtenerServiciosPorUsuario(
    String idusuario,
  ) async {
    // Simulación de acceso a BD (Firebase, SQLite, etc.)
    // Asegúrate de filtrar por idUsuario
    final snapshot =
        await FirebaseFirestore.instance
            .collection('servicios')
            .where('idUsuario', isEqualTo: idusuario)
            .get();

    return snapshot.docs.map((doc) => Servicio.fromFirestore(doc)).toList();
  }
}
