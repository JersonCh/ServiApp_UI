import 'package:flutter/material.dart';

class ServiciosGeneralesPage extends StatelessWidget {
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
                'Servicios Generales:',
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
                    'Albañileria',
                    'https://www.cementosinka.com.pe/wp-content/uploads/2023/09/Todo-sobre-la-alba_ileria-confinada.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Plomeria',
                    'https://todoferreteria.com.mx/wp-content/uploads/2022/12/plomero-entrada-01.png',
                  ),
                  _buildServiceCard(
                    context,
                    'Electricidad',
                    'https://sp-ao.shortpixel.ai/client/to_auto,q_glossy,ret_img,w_700,h_438/https://www.kwelectricistas.pe/wp-content/uploads/2019/04/Empresa-De-Instalaciones-Electricas-Domiciliarias-Residenciales-e-industriales-en-lima-peru.png',
                  ),
                  _buildServiceCard(
                    context,
                    'Carpinteria',
                    'https://www.mndelgolfo.com/blog/wp-content/uploads/2018/03/Todo-lo-que-necesitas-saber-para-armar-tu-taller-de-carpinteri%CC%81a1.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'Pintura y acabados',
                    'https://lirp.cdn-website.com/c9fb4062/dms3rep/multi/opt/02-640w.jpg',
                  ),
                  _buildServiceCard(
                    context,
                    'jardineria y paisajismo',
                    'https://paisajismodigital.com/blog/wp-content/uploads/2020/11/beneficios-de-la-jardineria.jpg',
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
