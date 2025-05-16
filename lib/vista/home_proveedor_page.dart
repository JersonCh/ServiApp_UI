import 'package:flutter/material.dart';
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

class HomeProveedorPage extends StatefulWidget {
  @override
  State<HomeProveedorPage> createState() => _HomeProveedorPageState();
}

class _HomeProveedorPageState extends State<HomeProveedorPage> {
  final LoginController loginController = LoginController();
  final HomeController homeController = HomeController();
  int _selectedIndex = 0;

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
                  MaterialPageRoute(builder: (context) => AgregarServicioPage()),
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Agregar servicio', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mis servicios ofrecidos', style: HomeProveedorStyles.titleStyle),
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
      Center(child: Text('Solicitudes')),
      Center(child: Text('Perfil')),
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
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Mis Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Solicitudes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}