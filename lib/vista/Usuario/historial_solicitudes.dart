import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class SolicitudesPage extends StatelessWidget {
  final String? clienteIdActual = GlobalUser.uid;

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
                builder: (context, snapshot) {
                  final nombreProveedor =
                      snapshot.data ?? 'Proveedor desconocido';

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        servicio,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text('Proveedor: $nombreProveedor'),
                          SizedBox(height: 2),
                          Text(
                            'Fecha y hora: $fechaHora',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
}
