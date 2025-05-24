import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esto
import 'package:flutter/material.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/vista/Usuario/perfil_usuario.dart';
import '../controlador/login_controller.dart';
import '../controlador/home_controller.dart';
import '../modelo/categoria_model.dart';
import 'Services/tecnologia_page.dart';
import 'Services/eventos_page.dart';
import 'Services/belleza_page.dart';
import 'Services/educacion_page.dart';
import 'Services/limpieza_page.dart';
import 'Services/vehiculos_page.dart';
import 'Services/salud_page.dart';
import 'Services/servicios_generales_page.dart';
import 'package:serviapp/styles/home_proveedor_styles.dart';
import 'package:serviapp/vista/Proveedor/agregar_servicio_page.dart';
import 'package:serviapp/vista/Proveedor/solicitudes_prov_page.dart';
import 'dart:async';

class HomeProveedorPage extends StatefulWidget {
  @override
  State<HomeProveedorPage> createState() => _HomeProveedorPageState();
}

class _HomeProveedorPageState extends State<HomeProveedorPage> {
  final LoginController loginController = LoginController();
  final HomeController homeController = HomeController();
  StreamSubscription? _solicitudesSubscription;

  int _selectedIndex = 0;

  // Aquí asigna tu proveedorId actual, puede venir de tu login o controlador
  final String? proveedorIdActual = GlobalUser.uid;
  bool _dialogShowing = false;
  String? _currentSolicitudId;

  void logout(BuildContext context) async {
    await loginController.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCategoriasServicios(List<Categoria> categorias) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarServicioPage(),
                  ),
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Agregar servicio',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis servicios ofrecidos',
                style: HomeProveedorStyles.titleStyle,
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return GestureDetector(
                onTap: () {
                  Widget? page;
                  switch (categoria.label) {
                    case 'Tecnologia':
                      page = TecnologiayElectronicaPage();
                      break;
                    case 'Vehículos':
                      page = VehiculosTransportePage();
                      break;
                    case 'Eventos':
                      page = EventosEntretenimientoPage();
                      break;
                    case 'Estetica':
                      page = BellezaEsteticaPage();
                      break;
                    case 'Salud y Bienestar':
                      page = SaludBienestarPage();
                      break;
                    case 'Servicios Generales':
                      page = ServiciosGeneralesPage();
                      break;
                    case 'Educacion':
                      page = EducacionCapacitacionPage();
                      break;
                    case 'Limpieza':
                      page = LimpiezaMantenimientoPage();
                      break;
                  }
                  if (page != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => page!),
                    );
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: categoria.gradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: categoria.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            categoria.icon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      categoria.label,
                      textAlign: TextAlign.center,
                      style: HomeProveedorStyles.categoryLabelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUltimosServicios() {
    print("Proveedor ID: $proveedorIdActual");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mis últimos servicios', style: HomeProveedorStyles.titleStyle),
          SizedBox(height: 12),
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: HomeProveedorStyles.cardDecoration,
            child: Text(
              'No hay servicios disponibles',
              style: HomeProveedorStyles.subtitleStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> mostrarVentanaSolicitudes(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nueva solicitud'),
            content: Text('Tienes una nueva solicitud pendiente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  Widget _buildSolicitudesList() {
    if (proveedorIdActual == null) {
      return Center(child: Text('No se encontró proveedor actual.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notificaciones')
              .where('proveedorId', isEqualTo: proveedorIdActual)
              .where('estado', isEqualTo: 'pendiente') // solo pendientes
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
          return Center(child: Text('No tienes solicitudes pendientes.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final idSolicitud = docs[index].id;
            final subcategoria = data['subcategoria'] ?? 'Sin categoría';
            final clienteId = data['clienteId'] ?? 'Desconocido';
            final nombreCliente = data['nombreCliente'] ?? 'Desconocido';
            // Puedes consultar más datos del cliente si quieres, con clienteId

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Solicitud para: $subcategoria',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cliente: $nombreCliente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.check_circle, size: 18),
                          label: Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('notificaciones')
                                .doc(idSolicitud)
                                .update({'estado': 'aceptado'});
                          },
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.cancel, size: 18),
                          label: Text('Rechazar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('notificaciones')
                                .doc(idSolicitud)
                                .update({'estado': 'rechazado'});
                          },
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
  }

  void _mostrarBottomSheetSolicitudes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solicitudes pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 400,
                child: _buildSolicitudesList(), // usa tu StreamBuilder aquí
              ),
            ],
          ),
        );
      },
    );
  }

  Set<String> _solicitudesMostradas = {};

  @override
  void initState() {
    super.initState();

    if (proveedorIdActual != null) {
      _solicitudesSubscription = FirebaseFirestore.instance
          .collection('notificaciones')
          .where('proveedorId', isEqualTo: proveedorIdActual)
          .where('estado', isEqualTo: 'pendiente')
          .snapshots()
          .listen((snapshot) {
            for (var doc in snapshot.docs) {
              if (!_solicitudesMostradas.contains(doc.id)) {
                _solicitudesMostradas.add(doc.id);
                if (!_dialogShowing) {
                  _dialogShowing = true;
                  Future.delayed(Duration.zero, () async {
                    mostrarVentanaSolicitudes(context); // Aquí espero el cierre
                    _dialogShowing = false;
                  });
                }
              }
            }
          });
    }
  }

  @override
  void dispose() {
    _solicitudesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = homeController.obtenerCategorias();
    final List<Widget> pages = [
      ListView(
        children: [
          _buildCategoriasServicios(categorias),
          _buildUltimosServicios(),
        ],
      ),
      Center(child: Text('Mis Servicios')),
      SolicitudesPage(),
      PerfilUsuarioPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Portal Proveedor'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_selectedIndex],

          // Si quieres mostrar algo encima en cualquier página, por ejemplo una notificación o banner,
          // puedes usar StreamBuilder o cualquier widget aquí.

          // Ejemplo: mostrar un banner o indicador si hay solicitudes pendientes
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('notificaciones')
                    .where('proveedorId', isEqualTo: proveedorIdActual)
                    .where('estado', isEqualTo: 'pendiente')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SizedBox.shrink();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SizedBox.shrink();
              }
              // Aquí puedes mostrar un pequeño banner o icono de notificación
              return Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () => _mostrarBottomSheetSolicitudes(context),
                  child: Icon(Icons.notifications_active),
                  backgroundColor: Colors.redAccent,
                  tooltip: 'Solicitudes pendientes',
                ),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Mis Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
