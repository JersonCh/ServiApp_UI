import 'package:flutter/material.dart';
import 'vehiculos_transporte/main.dart';
import 'eventos_entretenimiento/main.dart';
import 'belleza_estetica/main.dart';
import 'salud_bienestar/main.dart';
import 'Tecnologiaelectronica/main.dart';
import 'servicios_generales/main.dart';
import 'limpieza_mantenimiento/main.dart';

void main() {
  runApp(MiApp());
}

class MiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InicioPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InicioPage extends StatelessWidget {
  // 🔹 Lista de categorías de servicios con íconos y etiquetas
  final List<Map<String, dynamic>> categorias = [
    {'icon': Icons.memory, 'label': 'Tecnologia'},
    {'icon': Icons.directions_car, 'label': 'Vehículos'},
    {'icon': Icons.cleaning_services, 'label': 'Limpieza'},
    {'icon': Icons.health_and_safety, 'label': 'Salud y Bienestar'},
    {'icon': Icons.school, 'label': 'Educación'},
    {'icon': Icons.event, 'label': 'Eventos'},
    {'icon': Icons.spa, 'label': 'Estética'},
    {'icon': Icons.handyman, 'label': 'Servicios Generales'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔷 APP BAR (extraído)
      appBar: Header(),

      // 🔶 CUERPO PRINCIPAL DE LA PANTALLA
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🟪 Bienvenida y foto de perfil
            Container(
              color: Colors.blue[800],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/perfil.png'), // 📷 Tu imagen de perfil
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Gran B',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // 🟩 GRID DE SERVICIOS (íconos celestes con texto debajo)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: categorias.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 ítems por fila
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  // 🔘 CADA BOTÓN DE SERVICIO
                  return InkWell(
                    onTap: () {
                      if (categorias[index]['label'] == 'Tecnologia') {
                        // Redirige a la pantalla  Tecnologiaelectronica/main.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TecnologiayElectronicaPage()),
                        );
                      } else if (categorias[index]['label'] == 'Vehículos') {
                        // Redirige a la pantalla Vehiculos_Transporte/main.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VehiculosTransportePage()),
                        );
                      } else if (categorias[index]['label'] == 'Eventos') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventosEntretenimientoPage()),
                        );
                      } else if (categorias[index]['label'] == 'Estética') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BellezaEsteticaPage()),
                        );
                      } else if (categorias[index]['label'] ==
                          'Salud y Bienestar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SaludBienestarPage()),
                        );
                      } else if (categorias[index]['label'] ==
                          'Servicios Generales') {
                        // Redirige a la pantalla Servicios_Generales/main.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ServiciosGeneralesPage()),
                        );
                      } else if (categorias[index]['label'] == 'Limpieza') {
                        // Redirige a la pantalla Limpieza_Mantenimiento/main.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LimpiezaMantenimientoPage()),
                        );
                      } else {
                        print('${categorias[index]['label']} presionado');
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[800],
                          radius: 30,
                          child: Icon(
                            categorias[index]['icon'],
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          categorias[index]['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 🟦 MENÚ DE NAVEGACIÓN INFERIOR (extraído)
      bottomNavigationBar: Footer(),
    );
  }
}

// Encabezado extraído
class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 0,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar aquí', // 🔍 Búsqueda
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight); // Altura del AppBar
}

// Pie de página extraído
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue[800],
      selectedItemColor: const Color.fromARGB(255, 111, 134, 160),
      unselectedItemColor: const Color.fromARGB(179, 158, 94, 94),
      onTap: (index) {
        if (index == 0) {
          // Ir siempre a InicioPage y eliminar rutas anteriores
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => InicioPage()),
            (route) => false,
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
