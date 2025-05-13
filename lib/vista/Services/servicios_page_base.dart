import 'package:flutter/material.dart';
import 'package:serviapp/styles/Services/servicios_styles.dart';
import 'package:serviapp/vista/Services/servicios_widgets.dart';

/// Clase base para páginas de servicios con estructura común
class ServiciosPageBase extends StatelessWidget {
  final String titulo;
  final List<ServiceModel> servicios;

  const ServiciosPageBase({
    Key? key,
    required this.titulo,
    required this.servicios,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiciosStyles.backgroundColor,
      
      // Encabezado
      appBar: const ServiciosHeader(),

      // Contenido principal
      body: Padding(
        padding: EdgeInsets.all(ServiciosStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Center(
              child: Text(
                titulo,
                style: ServiciosStyles.sectionTitleStyle,
              ),
            ),
            SizedBox(height: ServiciosStyles.mediumSpacing),

            // Cuadrícula de servicios
            Expanded(
              child: ServiceGrid(services: servicios),
            ),
          ],
        ),
      ),

      // Pie de página
      bottomNavigationBar: const ServiciosFooter(),
    );
  }
}