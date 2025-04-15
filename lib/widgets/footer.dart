import 'package:flutter/material.dart';
import 'package:serviapp/main.dart'; // Asegúrate de que este sea tu nombre real de proyecto

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue[800],
      selectedItemColor: const Color.fromARGB(255, 111, 134, 160),
      unselectedItemColor: const Color.fromARGB(179, 158, 94, 94),
      onTap: (index) {
        if (index == 0) {
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
