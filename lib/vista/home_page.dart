import 'package:flutter/material.dart';
import '../controlador/login_controller.dart';
import '../controlador/home_controller.dart';
import '../modelo/categoria_model.dart';
import '../modelo/servicio_model.dart';
import 'package:serviapp/styles/home_styles.dart'; // Estilos importados aquí
/*import 'subcategoria_page.dart';
import 'tecnologia_page.dart';
import 'vehiculos_page.dart';
import 'eventos_page.dart';
import 'belleza_page.dart';
import 'salud_page.dart';
import 'servicios_page.dart';
import 'educacion_page.dart';
import 'limpieza_page.dart';*/

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget _buildCategoriesGrid(List<Categoria> categorias) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categorías', style: kTitleStyle),
              /*TextButton(
                onPressed: () => mostrarDialogoCategorias(context),
                child: Text('Ver todas'),
              ),*/
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
                      //page = TecnologiayElectronicaPage();
                      break;
                    case 'Vehículos':
                      //page = VehiculosTransportePage();
                      break;
                    case 'Eventos':
                      //page = EventosEntretenimientoPage();
                      break;
                    case 'Estetica':
                      //page = BellezaEsteticaPage();
                      break;
                    case 'Salud y Bienestar':
                      //page = SaludBienestarPage();
                      break;
                    case 'Servicios Generales':
                      //page = ServiciosGeneralesPage();
                      break;
                    case 'Educacion':
                      //page = EducacionCapacitacionPage();
                      break;
                    case 'Limpieza':
                      //page = LimpiezaMantenimientoPage();
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
                      style: kCategoryLabelStyle,
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

  Widget _buildPopularServices(List<Servicio> servicios) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Servicios populares', style: kTitleStyle),
              TextButton(onPressed: () {}, child: Text('Ver todos')),
            ],
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final service = servicios[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: kCardDecoration,
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(service.icon, color: service.color, size: 28),
                  ),
                  title: Text(service.title, style: kServiceTitleStyle),
                  subtitle: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${service.rating} (${service.reviews} reseñas)',
                        style: kSubtitleStyle,
                      ),
                    ],
                  ),
                  /*trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                SubcategoriaPage(nombre: service.title),
                      ),
                    );
                  },*/
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = homeController.obtenerCategorias();
    final servicios = homeController.obtenerServiciosPopulares();

    final List<Widget> pages = [
      ListView(
        children: [
          _buildCategoriesGrid(categorias),
          _buildPopularServices(servicios),
        ],
      ),
      Center(child: Text('Explorar')),
      Center(child: Text('Buscar')),
      Center(child: Text('Perfil')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
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
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
