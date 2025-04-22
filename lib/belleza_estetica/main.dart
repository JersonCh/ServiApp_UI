import 'package:flutter/material.dart';

class BellezaEsteticaPage extends StatelessWidget {
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
                'Belleza y Estética:',
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
                    'Peluquería y barbería a domicilio',
                    'https://i.ibb.co/Q36CYSHt/6.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Manicure y pedicure',
                    'https://i.ibb.co/jZhfZ3FN/7.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Maquillaje y asesoría de imagen',
                    'https://i.ibb.co/MKLykQ4/8.jpg',
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