// lib/vista/Services/todo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:serviapp/modelo/servicio_model.dart';
import 'package:serviapp/styles/Services/servicios_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TodoPage extends StatelessWidget {
  final String subcategoria;

  const TodoPage({Key? key, required this.subcategoria}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiciosStyles.backgroundColor,
      appBar: AppBar(
        title: Text(subcategoria),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servicios')
            .where('subcategoria', isEqualTo: subcategoria)
            .where('estado', isEqualTo: "true")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final servicio = Servicio.fromFirestore(doc);
              return _buildServiceCard(context, servicio);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Servicio servicio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        servicio.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(servicio.descripcion),
                    ],
                  ),
                ),
                // Sección de calificaciones
                _buildRatingSection(servicio),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _makePhoneCall(servicio.telefono),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            servicio.telefono,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openWhatsApp(servicio.telefono),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(Servicio servicio) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              servicio.promedioCalificaciones?.toStringAsFixed(1) ?? '0.0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          '(${servicio.totalCalificaciones ?? 0})',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/51$formattedNumber?text=Hola,%20estoy%20interesado%20en%20tu%20servicio'
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }
}