import 'package:flutter/material.dart';

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
    {'icon': Icons.memory, 'label': 'Tecnología'},
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

      // 🔷 APP BAR (zona superior con barra de búsqueda)
      appBar: AppBar(
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
      ),

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
                    backgroundImage: AssetImage('assets/perfil.png'), // 📷 Tu imagen de perfil
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('Gran B', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                      // 🔁 Aquí va la navegación al presionar un servicio
                      print('${categorias[index]['label']} presionado');
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => OtraPantalla()));
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

      // 🟦 MENÚ DE NAVEGACIÓN INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[800],
        selectedItemColor: const Color.fromARGB(255, 111, 134, 160),
        unselectedItemColor: const Color.fromARGB(179, 158, 94, 94),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'), // 🏠 Inicio
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'), // 🧭 Explorar
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'), // 🔍 Buscar
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'), // 👤 Perfil
        ],
      ),
    );
  }
}
// Fin del código