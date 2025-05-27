import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'calificacion_modal.dart'; // Asegúrate de importar el modal

class SolicitudesPage extends StatefulWidget {
  @override
  _SolicitudesPageState createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  final String? clienteIdActual = GlobalUser.uid;
  Map<String, bool> estadosCalificacion = {};

  Future<String?> obtenerNombreProveedor(String proveedorId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['nombre'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el nombre del proveedor: $e');
      return null;
    }
  }

  // Método para obtener el servicioId real basado en la notificación
  Future<String?> obtenerServicioIdDeNotificacion(String notificacionId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(notificacionId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Primero intentar con servicioId directo
        if (data.containsKey('servicioId') && data['servicioId'] != null) {
          print('Encontrado servicioId directo: ${data['servicioId']}');
          return data['servicioId'] as String;
        }
        
        // Si no existe servicioId, buscar por proveedorId y subcategoria
        final proveedorId = data['proveedorId'] as String?;
        final subcategoria = data['subcategoria'] as String?;
        
        print('Buscando servicio - ProveedorId: $proveedorId, Subcategoria: "$subcategoria"');
        
        if (proveedorId != null && subcategoria != null) {
          return await buscarServicioPorProveedorYCategoria(proveedorId, subcategoria);
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener servicioId de notificación: $e');
      return null;
    }
  }

  // Método para buscar servicio por proveedor y categoría
  Future<String?> buscarServicioPorProveedorYCategoria(String proveedorId, String subcategoria) async {
    try {
      // Primero intentar búsqueda exacta
      var query = await FirebaseFirestore.instance
          .collection('servicios')
          .where('idusuario', isEqualTo: proveedorId)
          .where('subcategoria', isEqualTo: subcategoria)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print('Servicio encontrado con búsqueda exacta: ${query.docs.first.id}');
        return query.docs.first.id;
      }
      
      // Si no se encuentra, intentar búsqueda solo por proveedor
      print('No se encontró con búsqueda exacta, buscando solo por proveedor...');
      query = await FirebaseFirestore.instance
          .collection('servicios')
          .where('idusuario', isEqualTo: proveedorId)
          .get();
      
      print('Servicios encontrados para el proveedor: ${query.docs.length}');
      
      // Buscar coincidencia aproximada (sin case sensitive)
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final servicioSubcategoria = (data['subcategoria'] ?? '').toString();
        print('Comparando: "$subcategoria" vs "$servicioSubcategoria"');
        
        if (servicioSubcategoria.toLowerCase().trim() == subcategoria.toLowerCase().trim()) {
          print('Servicio encontrado con búsqueda aproximada: ${doc.id}');
          return doc.id;
        }
      }
      
      // Si aún no se encuentra, tomar el primer servicio del proveedor
      if (query.docs.isNotEmpty) {
        print('Usando primer servicio del proveedor: ${query.docs.first.id}');
        return query.docs.first.id;
      }
      
      print('No se encontró ningún servicio para el proveedor');
      return null;
    } catch (e) {
      print('Error al buscar servicio por proveedor y categoría: $e');
      return null;
    }
  }

  Future<bool> yaCalificado(String notificacionId, String clienteId) async {
    // Primero verificar el estado local
    if (estadosCalificacion.containsKey(notificacionId)) {
      return estadosCalificacion[notificacionId]!;
    }
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('calificaciones')
          .where('notificacionId', isEqualTo: notificacionId)
          .where('clienteId', isEqualTo: clienteId)
          .get();
      
      bool yaEstaCalificado = query.docs.isNotEmpty;
      // Guardar en estado local
      setState(() {
        estadosCalificacion[notificacionId] = yaEstaCalificado;
      });
      return yaEstaCalificado;
    } catch (e) {
      print('Error al verificar calificación: $e');
      return false;
    }
  }

  void mostrarModalCalificacion(
    BuildContext context,
    String notificacionId,
    String proveedorId,
    String clienteId,
    String nombreProveedor,
    String tipoServicio,
  ) {
    // Verificar una vez más antes de mostrar el modal
    yaCalificado(notificacionId, clienteId).then((yaEstaCalificado) {
      if (yaEstaCalificado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este servicio ya ha sido calificado'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CalificacionModal(
          notificacionId: notificacionId,
          proveedorId: proveedorId,
          clienteId: clienteId,
          nombreProveedor: nombreProveedor,
          tipoServicio: tipoServicio,
        ),
      ).then((resultado) {
        // Si se envió la calificación, actualizar el estado local inmediatamente
        if (resultado == true) {
          setState(() {
            estadosCalificacion[notificacionId] = true;
          });
          
          // Mostrar mensaje de confirmación
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Calificación enviada exitosamente!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (clienteIdActual == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Historial de Solicitudes')),
        body: Center(child: Text('Cliente no identificado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Historial de Solicitudes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('clienteId', isEqualTo: clienteIdActual)
            .where('estado', isEqualTo: 'aceptado')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No tienes solicitudes aceptadas.'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final notificacionId = docs[index].id;
              final servicio = data['subcategoria'] ?? 'Sin categoría';
              final proveedorId = data['proveedorId'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final fechaHora = timestamp != null
                  ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} '
                      '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                  : 'Sin fecha';

              return FutureBuilder<String?>(
                future: obtenerNombreProveedor(proveedorId),
                builder: (context, proveedorSnapshot) {
                  final nombreProveedor =
                      proveedorSnapshot.data ?? 'Proveedor desconocido';
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      servicio,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Proveedor: $nombreProveedor'),
                                    SizedBox(height: 2),
                                    Text(
                                      'Fecha y hora: $fechaHora',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  _buildBotonCalificar(
                                    notificacionId,
                                    proveedorId,
                                    nombreProveedor,
                                    servicio,
                                  ),
                                  SizedBox(height: 8),
                                  _buildBotonFavoritos(notificacionId),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBotonCalificar(
    String notificacionId,
    String proveedorId,
    String nombreProveedor,
    String servicio,
  ) {
    // Verificar primero el estado local
    if (estadosCalificacion[notificacionId] == true) {
      return _buildBotonCalificado();
    }
    // Si no está en el estado local, verificar en la base de datos
    return FutureBuilder<bool>(
      future: yaCalificado(notificacionId, clienteIdActual!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final yaEstaCalificado = snapshot.data ?? false;
        if (yaEstaCalificado) {
          return _buildBotonCalificado();
        } else {
          return ElevatedButton(
            onPressed: () => mostrarModalCalificacion(
              context,
              notificacionId,
              proveedorId,
              clienteIdActual!,
              nombreProveedor,
              servicio,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Calificar',
              style: TextStyle(fontSize: 12),
            ),
          );
        }
      },
    );
  }

  Widget _buildBotonCalificado() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[700],
          ),
          SizedBox(width: 4),
          Text(
            'Calificado',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> esFavorito(String notificacionId) async {
    try {
      // Obtener el servicioId real de la notificación
      final servicioId = await obtenerServicioIdDeNotificacion(notificacionId);
      if (servicioId == null) return false;

      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  Future<void> toggleFavorito(String notificacionId) async {
    try {
      // Obtener el servicioId real de la notificación
      final servicioId = await obtenerServicioIdDeNotificacion(notificacionId);
      if (servicioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: No se pudo encontrar el servicio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      if (query.docs.isNotEmpty) {
        // Quitar de favoritos
        await query.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Agregar a favoritos
        await FirebaseFirestore.instance.collection('favoritos').add({
          'servicioId': servicioId, // Ahora usamos el servicioId real
          'clienteId': clienteIdActual!,
          'fechaAgregado': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agregado a favoritos'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() {}); // Refrescar UI
    } catch (e) {
      print('Error al toggle favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBotonFavoritos(String notificacionId) {
    return FutureBuilder<String?>(
      future: obtenerServicioIdDeNotificacion(notificacionId),
      builder: (context, servicioSnapshot) {
        if (servicioSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 32,
            height: 32,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        
        final servicioId = servicioSnapshot.data;
        if (servicioId == null) {
          return Container(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.error, size: 14, color: Colors.grey),
          );
        }

        // Usar StreamBuilder para escuchar cambios en tiempo real
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favoritos')
              .where('servicioId', isEqualTo: servicioId)
              .where('clienteId', isEqualTo: clienteIdActual!)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 32,
                height: 32,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final esFav = snapshot.data?.docs.isNotEmpty ?? false;

            return GestureDetector(
              onTap: () => toggleFavoritoConServicioId(servicioId),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: esFav ? Colors.red[100] : Colors.amber[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: esFav ? Colors.red[700] : Colors.amber[700],
                    ),
                    SizedBox(width: 4),
                    Text(
                      esFav ? 'Quitar' : 'Favorito',
                      style: TextStyle(
                        color: esFav ? Colors.red[700] : Colors.amber[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método simplificado para toggle favoritos usando servicioId directamente
  Future<void> toggleFavoritoConServicioId(String servicioId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('servicioId', isEqualTo: servicioId)
          .where('clienteId', isEqualTo: clienteIdActual!)
          .get();
      
      if (query.docs.isNotEmpty) {
        // Quitar de favoritos
        await query.docs.first.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Agregar a favoritos
        await FirebaseFirestore.instance.collection('favoritos').add({
          'servicioId': servicioId,
          'clienteId': clienteIdActual!,
          'fechaAgregado': DateTime.now().millisecondsSinceEpoch,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agregado a favoritos'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error al toggle favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}