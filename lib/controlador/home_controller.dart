import 'package:flutter/material.dart';
import '../modelo/categoria_model.dart';
import '../modelo/servicio_model.dart';

class HomeController {
  List<Categoria> obtenerCategorias() {
    return [
      Categoria(
        label: 'Tecnologia',
        icon: Icons.devices,
        color: Colors.blue,
        gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
      ),
      Categoria(
        label: 'Vehículos',
        icon: Icons.directions_car,
        color: Colors.red,
        gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      ),
      Categoria(
        label: 'Eventos',
        icon: Icons.event,
        color: Colors.purple,
        gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
      ),
      Categoria(
        label: 'Estetica',
        icon: Icons.spa,
        color: Colors.pink,
        gradient: LinearGradient(colors: [Colors.pink, Colors.pinkAccent]),
      ),
      Categoria(
        label: 'Salud y Bienestar',
        icon: Icons.favorite,
        color: Colors.green,
        gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
      ),
      Categoria(
        label: 'Servicios Generales',
        icon: Icons.build,
        color: Colors.indigo,
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
      ),
      Categoria(
        label: 'Educacion',
        icon: Icons.school,
        color: Colors.amber,
        gradient: LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
      ),
      Categoria(
        label: 'Limpieza',
        icon: Icons.cleaning_services,
        color: Colors.teal,
        gradient: LinearGradient(colors: [Colors.teal, Colors.greenAccent]),
      ),
    ];
  }

  List<Servicio> obtenerServiciosPopulares() {
    return [
      Servicio(
        title: 'Reparación de computadoras',
        rating: 4.8,
        reviews: 120,
        icon: Icons.computer_rounded,
        color: Colors.blue[700]!,
      ),
      Servicio(
        title: 'Limpieza del hogar',
        rating: 4.7,
        reviews: 85,
        icon: Icons.cleaning_services_rounded,
        color: Colors.teal[700]!,
      ),
      Servicio(
        title: 'Plomería de emergencia',
        rating: 4.9,
        reviews: 210,
        icon: Icons.plumbing_rounded,
        color: Colors.indigo[700]!,
      ),
    ];
  }
}
