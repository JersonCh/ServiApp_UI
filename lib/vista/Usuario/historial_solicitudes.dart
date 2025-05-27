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
      final doc =
          await FirebaseFirestore.instance
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
        stream:
            FirebaseFirestore.instance
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
              final fechaHora =
                  timestamp != null
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
                              // Botón de calificar simplificado
                              _buildBotonCalificar(
                                notificacionId,
                                proveedorId,
                                nombreProveedor,
                                servicio,
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
}