import 'package:flutter/material.dart';
import 'package:serviapp/vista/Usuario/perfil_usuario.dart';
import '../controlador/login_controller.dart';
import '../controlador/home_controller.dart';
import '../modelo/categoria_model.dart';
import '../modelo/servicio_model.dart';
import 'package:serviapp/styles/home_styles.dart';
import 'Services/tecnologia_page.dart';
import 'Services/eventos_page.dart';
import 'Services/belleza_page.dart';
import 'Services/educacion_page.dart';
import 'Services/limpieza_page.dart';
import 'Services/vehiculos_page.dart';
import 'Services/salud_page.dart';
import 'Services/servicios_generales_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoginController _loginController = LoginController();
  final HomeController _homeController = HomeController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    Center(child: Text('Explorar')),
    Center(child: Text('Buscar')),
    PerfilUsuarioPage(),
  ];

  void _logout(BuildContext context) async {
    await _loginController.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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

class _HomeContent extends StatelessWidget {
  final HomeController _homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    final categorias = _homeController.obtenerCategorias();
    final servicios = _homeController.obtenerServiciosPopulares();

    return ListView(
      children: [
        _buildCategoriesGrid(categorias, context),
        _buildPopularServices(servicios),
      ],
    );
  }

  Widget _buildCategoriesGrid(List<Categoria> categorias, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categorías', style: kTitleStyle),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return _CategoryItem(categoria: categoria);
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
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final service = servicios[index];
              return _ServiceItem(service: service);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Categoria categoria;

  const _CategoryItem({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCategory(context),
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
                    offset: const Offset(0, 3),
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
          const SizedBox(height: 8),
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
  }

  void _navigateToCategory(BuildContext context) {
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }
}

class _ServiceItem extends StatelessWidget {
  final Servicio service;

  const _ServiceItem({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: kCardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: service.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(service.icon, color: service.color, size: 28),
        ),
        title: Text(service.titulo, style: kServiceTitleStyle),
        subtitle: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${service.promedioCalificaciones.toStringAsFixed(1)} (${service.totalCalificaciones} reseñas)',
              style: kSubtitleStyle,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a detalle del servicio
        },
      ),
    );
  }
}