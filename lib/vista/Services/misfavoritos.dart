import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class MisFavoritosPage extends StatefulWidget {
  @override
  _MisFavoritosPageState createState() => _MisFavoritosPageState();
}

class _MisFavoritosPageState extends State<MisFavoritosPage> {
  final String? clienteIdActual = GlobalUser.uid;

  Future<Map<String, dynamic>?> obtenerServicio(String servicioId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('servicios')
          .doc(servicioId)
          .get();

      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener servicio: $e');
      return null;
    }
  }

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

  Future<void> eliminarFavorito(String favoritoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(favoritoId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eliminado de favoritos'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error al eliminar favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (clienteIdActual == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Mis Favoritos')),
        body: Center(child: Text('Cliente no identificado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mis Favoritos')),
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favoritos')
          .where('clienteId', isEqualTo: clienteIdActual)
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes servicios favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

              // Ordenar los documentos por fecha en el cliente
              final sortedDocs = docs.toList();
              sortedDocs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aFecha = aData['fechaAgregado'] ?? 0;
                final bFecha = bData['fechaAgregado'] ?? 0;
                return bFecha.compareTo(aFecha); // Descendente (más reciente primero)
              });

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  final favoritoData = sortedDocs[index].data() as Map<String, dynamic>;
                  final favoritoId = sortedDocs[index].id;
                  final servicioId = favoritoData['servicioId'] ?? '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: obtenerServicio(servicioId),
                builder: (context, servicioSnapshot) {
                  if (servicioSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final servicioData = servicioSnapshot.data;
                  if (servicioData == null) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('Servicio no encontrado'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarFavorito(favoritoId),
                        ),
                      ),
                    );
                  }

                  final titulo = servicioData['titulo'] ?? 'Sin título';
                  final subcategoria = servicioData['subcategoria'] ?? 'Sin categoría';
                  final ubicacion = servicioData['ubicacion'] ?? 'Sin ubicación';
                  final proveedorId = servicioData['idusuario'] ?? '';
                  final descripcion = servicioData['descripcion'] ?? '';
                  final imagen = servicioData['imagen'] ?? '';

                  return FutureBuilder<String?>(
                    future: obtenerNombreProveedor(proveedorId),
                    builder: (context, proveedorSnapshot) {
                      final nombreProveedor = proveedorSnapshot.data ?? 'Proveedor desconocido';

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagen del servicio
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imagen.isNotEmpty
                                    ? Image.network(
                                        imagen,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image_not_supported),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image),
                                      ),
                              ),
                              SizedBox(width: 12),
                              // Información del servicio
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titulo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      subcategoria,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Proveedor: $nombreProveedor',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, 
                                             size: 14, color: Colors.grey),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            ubicacion,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (descripcion.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        descripcion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Botón eliminar
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.star, color: Colors.amber),
                                    onPressed: () => eliminarFavorito(favoritoId),
                                  ),
                                  Text(
                                    'Quitar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                    ),
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
          );
        },
      ),
    );
  }
}