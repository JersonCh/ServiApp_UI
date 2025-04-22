import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'login.dart';
import 'busqueda_servicio_page.dart';

class SubcategoriaPage extends StatelessWidget {
  final String nombre;
  
  const SubcategoriaPage({required this.nombre});

  // Función para obtener el codrol según el nombre de la subcategoría
  int obtenerCodRol(String subcategoria) {
    Map<String, int> mapaCodRoles = {
      'Reparación de computadoras y laptops': 11,
      'Plomeria': 2,
      'Cerrajeria': 5,
      'Pintura y acabados': 6,
      // Añadir más mapeos según necesites
    };
    
    // Buscar coincidencia exacta
    if (mapaCodRoles.containsKey(subcategoria)) {
      return mapaCodRoles[subcategoria]!;
    }

    // Buscar coincidencia parcial
    for (var entry in mapaCodRoles.entries) {
      if (subcategoria.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return 0; // Código por defecto si no encuentra coincidencia
  }
  
  @override
  Widget build(BuildContext context) {
    final int codRol = obtenerCodRol(nombre);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de $nombre',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Descripción del servicio:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Este servicio te ayudará con todas tus necesidades relacionadas a $nombre.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (codRol > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusquedaServicioPage(
                          subcategoria: nombre,
                          codRol: codRol,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No se encontraron proveedores para este servicio'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Solicitar Servicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}