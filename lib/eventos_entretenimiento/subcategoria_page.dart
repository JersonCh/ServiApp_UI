import 'package:flutter/material.dart';

class SubcategoriaPage extends StatelessWidget {
  final String nombre;

  const SubcategoriaPage({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: Text(
          'Estás en la subcategoría: $nombre',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
