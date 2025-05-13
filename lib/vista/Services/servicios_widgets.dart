import 'package:flutter/material.dart';
import 'package:serviapp/styles/Services/servicios_styles.dart';

/// Modelo de datos para servicios
class ServiceModel {
  final String title;
  final String imageUrl;

  ServiceModel({required this.title, required this.imageUrl});
}

/// Widget de encabezado para la página de servicios
class ServiciosHeader extends StatelessWidget implements PreferredSizeWidget {
  const ServiciosHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ServiciosStyles.primaryColor,
      elevation: 0,
      // Barra de búsqueda (comentada en el código original)
      // title: TextField(
      //   decoration: InputDecoration(
      //     hintText: 'Buscar aquí',
      //     hintStyle: TextStyle(color: const Color.fromARGB(179, 250, 250, 250)),
      //     prefixIcon: Icon(Icons.search, color: Colors.white),
      //     border: InputBorder.none,
      //   ),
      //   style: TextStyle(color: Colors.white),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Widget de pie de página para la navegación
class ServiciosFooter extends StatelessWidget {
  const ServiciosFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: ServiciosStyles.primaryColor,
      selectedItemColor: ServiciosStyles.selectedItemColor,
      unselectedItemColor: ServiciosStyles.unselectedItemColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}

/// Widget para mostrar servicios en cuadrícula
class ServiceGrid extends StatelessWidget {
  final List<ServiceModel> services;

  const ServiceGrid({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: ServiciosStyles.itemSpacing,
      mainAxisSpacing: ServiciosStyles.itemSpacing,
      children: services
          .map((service) => ServiceCard(
                title: service.title,
                imageUrl: service.imageUrl,
              ))
          .toList(),
    );
  }
}

/// Widget para mostrar tarjeta de servicio individual
class ServiceCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen del servicio
        ClipRRect(
          borderRadius: ServiciosStyles.cardBorderRadius,
          child: Image.network(
            imageUrl,
            height: ServiciosStyles.serviceImageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: ServiciosStyles.smallSpacing),
        
        // Botón del servicio
        SizedBox(
          height: ServiciosStyles.buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Seleccionado: $title')),
              );
            },
            style: ServiciosStyles.primaryButtonStyle,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ServiciosStyles.buttonTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}