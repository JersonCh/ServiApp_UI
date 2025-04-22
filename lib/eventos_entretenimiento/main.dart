import 'package:flutter/material.dart';

class EventosEntretenimientoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔷 Encabezado
      appBar: Header(),

      // 🟪 Contenido principal
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Título de la sección
            Center(
              child: Text(
                'Eventos y Entretenimiento:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Cuadrícula de servicios
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    context,
                    'Fotografía y filmación',
                    'https://www.sonoluz.com.pe/images/servicios/filmacion-eventos.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Organización de eventos',
                    'https://www.educativo.net/xframework/files/entities/articulos/616/img.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Catering y banquetes',
                    'https://287524.fs1.hubspotusercontent-na1.net/hubfs/287524/Imported_Blog_Media/banquetes-y-catering-conceptos-gastronomicos-una-historia-4-compressor-Dec-17-2022-07-46-40-0657-PM.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Música en vivo y DJ',
                    'https://elisglobalparty.wordpress.com/wp-content/uploads/2014/07/dj.jpeg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🟦 Pie de página
      bottomNavigationBar: Footer(),
    );
  }

  // 🔹 Tarjeta de servicio
  Widget _buildServiceCard(
      BuildContext context, String title, String imageUrl) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50, // 🔹 Tamaño fijo de botón
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Seleccionado: $title')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

// 🔷 Encabezado de búsqueda
class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 0,
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// 🔻 Menú inferior
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue[800],
      selectedItemColor: const Color.fromARGB(255, 111, 134, 160),
      unselectedItemColor: const Color.fromARGB(179, 158, 94, 94),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
