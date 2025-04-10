import 'package:flutter/material.dart';

class VehiculosTransportePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔷 APP BAR
      appBar: Header(),

      // 🟪 Contenido principal
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Título
            Center(
              child: Text(
                'Mecánica automotriz:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                    context,
                    'Mecánica automotriz',
                    'https://www.senati.edu.pe/sites/default/files/2017/carrera/09/mecanica-automotriz-senati1800-x-1190_0.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Lavado y detallado de autos',
                    'https://detailerlab.com/wp-content/uploads/2020/02/detailing-vs-autolavado.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Cambio de llantas y baterías',
                    'https://paautos.gt/inicio/wp-content/uploads/2022/09/Aparicion-de-grietas-a-los-laterales-de-la-llanta.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Servicio de grúa',
                    'https://gruasatelital.com/wp-content/uploads/2022/02/servicio1.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Transporte y mudanzas',
                    'https://gilmovers.com.pe/wp-content/uploads/transporte-y-mudanza-internacional.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Lubricentro',
                    'https://i0.wp.com/www.autodata.pe/wp-content/uploads/2016/02/cambio-de-aceite-AUTODATA-S.A.C..jpg?w=1260&ssl=1',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🟦 MENÚ DE NAVEGACIÓN INFERIOR
      bottomNavigationBar: Footer(),
    );
  }

  // 📦 Tarjeta de servicio con botón de igual altura
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
          height: 50, // 🔹 Tamaño uniforme de botón
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

// 🔷 APP BAR
class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 0,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar aquí',
          hintStyle: TextStyle(color: const Color.fromARGB(179, 250, 250, 250)),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// 🔻 PIE DE PÁGINA
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
