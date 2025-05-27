import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serviapp/modelo/servicio_model.dart';
import 'package:serviapp/styles/Services/servicios_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TodoPage extends StatefulWidget {
  final String subcategoria;

  const TodoPage({Key? key, required this.subcategoria}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class HistorialSolicitudesPage extends StatelessWidget {
  final String subcategoria;

  const HistorialSolicitudesPage({super.key, required this.subcategoria});

  void _mostrarProveedoresModal(
    BuildContext context,
    String subcategoria,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para ver proveedores.'),
        ),
      );
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
    final String userType = userDoc.data()?['rol'] ?? 'desconocido';

    if (userType != 'cliente') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (ctx, scrollController) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text('Proveedores para: $subcategoria'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .where('rol', isEqualTo: 'proveedor')
                        .where('tipoTrabajo', arrayContains: subcategoria)
                        .where('isOnline', isEqualTo: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron proveedores disponibles.'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final uidProveedor = docs[index].id;
                      final nombre = data['nombre'] ?? 'Proveedor sin nombre';
                      final celular = data['celular'] ?? 'Número no disponible';

                      return ListTile(
                        title: Text(nombre),
                        subtitle: Text('Celular: $celular'),
                        trailing: ElevatedButton(
                          child: const Text('Solicitar servicio'),
                          onPressed: () async {
                            final solicitudId = const Uuid().v4();
                            await FirebaseFirestore.instance
                                .collection('notificaciones')
                                .doc(solicitudId)
                                .set({
                                  'id': solicitudId,
                                  'clienteId': currentUser.uid,
                                  'nombreCliente':
                                      userDoc.data()?['nombre'] ?? '',
                                  'proveedorId': uidProveedor,
                                  'estado': 'pendiente',
                                  'etapa': '',
                                  'subcategoria': subcategoria,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Solicitud enviada al proveedor.',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Llamamos al modal solo después de que se haya construido el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarProveedoresModal(context, subcategoria);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de solicitudes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notificaciones')
                .where(
                  'clienteId',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                .where('estado', isEqualTo: 'aceptado')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay solicitudes aceptadas.'));
          }

          final notificaciones = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final data = notificaciones[index].data() as Map<String, dynamic>;
              final proveedorId = data['proveedorId'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(proveedorId)
                        .get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || !snap.data!.exists) {
                    return const SizedBox();
                  }
                  final proveedor = snap.data!;
                  final nombre = proveedor['nombre'] ?? 'Proveedor';
                  final telefono = proveedor['celular'] ?? '';

                  return Card(
                    color: Colors.lightGreen.shade50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Puedes contactarte con el proveedor, sus datos son:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nombres: $nombre\nCelular: $telefono',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final Uri uri = Uri(
                                      scheme: 'tel',
                                      path: telefono,
                                    );
                                    launchUrl(uri);
                                  },
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Llamar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final formatted = telefono.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  final Uri uri = Uri.parse(
                                    'https://wa.me/51$formatted',
                                  );
                                  launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                                label: const Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
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
      ),
    );
  }
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiciosStyles.backgroundColor,
      appBar: AppBar(title: Text(widget.subcategoria), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('servicios')
                .where('subcategoria', isEqualTo: widget.subcategoria)
                .where('estado', isEqualTo: "true")
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay servicios disponibles'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final servicio = Servicio.fromFirestore(doc);
              return _buildServiceCard(context, servicio);
            },
          );
        },
      ),
    );
  }

  Future<void> _crearSolicitudAceptadaDesdeServicio(String idServicio) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Obtener datos del cliente
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

    final nombreCliente = userDoc.data()?['nombre'] ?? '';
    final uidSolicitud = const Uuid().v4();

    try {
      // Obtener los datos del servicio seleccionado
      final servicioDoc =
          await FirebaseFirestore.instance
              .collection('servicios')
              .doc(idServicio)
              .get();

      if (!servicioDoc.exists) {
        print('⚠️ El servicio con ID $idServicio no existe.');
        return;
      }

      final data = servicioDoc.data()!;
      final proveedorId = data['idusuario'];
      final subcategoria = data['subcategoria'];

      print('➡️ Servicio seleccionado: $idServicio');
      print('➡️ Proveedor ID: $proveedorId');

      // Crear notificación
      await FirebaseFirestore.instance
          .collection('notificaciones')
          .doc(uidSolicitud)
          .set({
            'id': uidSolicitud,
            'clienteId': currentUser.uid,
            'nombreCliente': nombreCliente,
            'proveedorId': proveedorId,
            'estado': 'aceptado',
            'etapa': '',
            'subcategoria': subcategoria,
            'timestamp': FieldValue.serverTimestamp(),
          });

      print('✅ Solicitud creada desde publicación $idServicio');
    } catch (e) {
      print('❌ Error al crear la solicitud: $e');
    }
  }

  Widget _buildServiceCard(BuildContext context, Servicio servicio) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getProviderDataAndRating(servicio.idusuario),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final providerData = snapshot.data ?? {};
        final String nombreProveedor = providerData['nombre'] ?? 'Proveedor';
        final String ubicacionProveedor = providerData['ubicacion'] ?? 'Sin ubicación';
        final String fotoPerfilUrl = providerData['fotoPerfil'] ?? '';
        final double promedioCalificaciones = providerData['promedioCalificaciones'] ?? 0.0;
        final int totalCalificaciones = providerData['totalCalificaciones'] ?? 0;
        
        // ✅ CORREGIDO: Obtener imagen directamente del servicio, no del usuario
        final String imagenServicioUrl = servicio.imagen ?? ''; // Asumiendo que el campo se llama 'imagenUrl' en el modelo Servicio

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con foto de perfil, nombre y calificación
                Row(
                  children: [
                    // Foto de perfil
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: ClipOval(
                        child: fotoPerfilUrl.isNotEmpty
                            ? Image.network(
                                fotoPerfilUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, size: 30, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.person, size: 30, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del proveedor
                          Text(
                            nombreProveedor,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Calificación
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${promedioCalificaciones.toStringAsFixed(1)} ($totalCalificaciones)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          // Ubicación
                          Text(
                            'Ubicación: $ubicacionProveedor',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 20),
                
                // Título del servicio
                Text(
                  servicio.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Imagen del servicio (si existe)
                if (imagenServicioUrl.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imagenServicioUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Descripción del servicio
                Text(
                  servicio.descripcion,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _crearSolicitudAceptadaDesdeServicio(servicio.id);
                          final Uri uri = Uri(
                            scheme: 'tel',
                            path: servicio.telefono,
                          );
                          launchUrl(uri);
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _crearSolicitudAceptadaDesdeServicio(servicio.id);
                        final formatted = servicio.telefono.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        final Uri uri = Uri.parse('https://wa.me/51$formatted');
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      icon: const FaIcon(FontAwesomeIcons.whatsapp),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
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
  }

  // ✅ CORREGIDO: Ya no busca 'imagenServicio' en la colección 'users'
  Future<Map<String, dynamic>> _getProviderDataAndRating(String proveedorId) async {
    final Map<String, dynamic> result = {};
    
    try {
      // Obtener datos del proveedor
      final proveedorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(proveedorId)
          .get();
      
      if (proveedorDoc.exists) {
        final data = proveedorDoc.data()!;
        result['nombre'] = data['nombre'] ?? 'Proveedor';
        result['ubicacion'] = data['ubicacion'] ?? 'Sin ubicación';
        result['fotoPerfil'] = data['fotoPerfil'] ?? '';
        // ❌ REMOVIDO: result['imagenServicio'] = data['imagenServicio'] ?? '';
      }
      
      // Obtener calificaciones del proveedor
      final calificacionesSnapshot = await FirebaseFirestore.instance
          .collection('calificaciones')
          .where('proveedorId', isEqualTo: proveedorId)
          .get();
      
      if (calificacionesSnapshot.docs.isNotEmpty) {
        double sumaCalificaciones = 0.0;
        int totalCalificaciones = calificacionesSnapshot.docs.length;
        
        for (var doc in calificacionesSnapshot.docs) {
          final data = doc.data();
          sumaCalificaciones += (data['puntuacion'] ?? 0.0).toDouble();
        }
        
        result['promedioCalificaciones'] = sumaCalificaciones / totalCalificaciones;
        result['totalCalificaciones'] = totalCalificaciones;
      } else {
        result['promedioCalificaciones'] = 0.0;
        result['totalCalificaciones'] = 0;
      }
      
    } catch (e) {
      print('Error obteniendo datos del proveedor: $e');
      result['nombre'] = 'Proveedor';
      result['ubicacion'] = 'Sin ubicación';
      result['fotoPerfil'] = '';
      result['promedioCalificaciones'] = 0.0;
      result['totalCalificaciones'] = 0;
    }
    
    return result;
  }

  Widget _buildRatingSection(Servicio servicio) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              servicio.promedioCalificaciones?.toStringAsFixed(1) ?? '0.0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          '(${servicio.totalCalificaciones ?? 0})',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/51$formattedNumber?text=Hola,%20estoy%20interesado%20en%20tu%20servicio',
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }
}