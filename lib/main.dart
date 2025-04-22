import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'estilos/styles.dart';
import 'login.dart';
import 'vehiculos_transporte/main.dart';
import 'eventos_entretenimiento/main.dart';
import 'eventos_entretenimiento/subcategoria_page.dart';
import 'belleza_estetica/main.dart';
import 'salud_bienestar/main.dart';
import 'Tecnologiaelectronica/main.dart';
import 'servicios_generales/main.dart';
import 'limpieza_mantenimiento/main.dart';
import 'educacion_capacitacion/main.dart';

class MiApp extends StatelessWidget {
  final WebSocketChannel channel;
  final Usuario usuario;

  const MiApp({required this.channel, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios',
      theme: AppStyles.appTheme(),
      home: InicioPage(channel: channel, usuario: usuario),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InicioPage extends StatefulWidget {
  final WebSocketChannel channel;
  final Usuario usuario;

  const InicioPage({required this.channel, required this.usuario});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> categorias = [
    {'icon': Icons.computer_rounded, 'label': 'Tecnologia', 'color': Color(0xFF4CAF50)},
    {'icon': Icons.directions_car_rounded, 'label': 'Vehículos', 'color': Color(0xFFFFA726)},
    {'icon': Icons.cleaning_services_rounded, 'label': 'Limpieza', 'color': Color(0xFF42A5F5)},
    {'icon': Icons.favorite_rounded, 'label': 'Salud y Bienestar', 'color': Color(0xFFEC407A)},
    {'icon': Icons.school_rounded, 'label': 'Educacion', 'color': Color(0xFF9C27B0)},
    {'icon': Icons.celebration_rounded, 'label': 'Eventos', 'color': Color(0xFFFF7043)},
    {'icon': Icons.spa_rounded, 'label': 'Estetica', 'color': Color(0xFF26A69A)},
    {'icon': Icons.handyman_rounded, 'label': 'Servicios Generales', 'color': Color(0xFF5C6BC0)},
  ];

  bool mostrado = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuración de animaciones
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = AppStyles.createFadeAnimation(_controller);
    _slideAnimation = AppStyles.createSlideAnimation(_controller);
    
    _controller.forward();
    
    // Escuchar mensajes del WebSocket
    widget.channel.stream.listen((msg) {
      if (!mostrado && msg.toString().startsWith('¡Bienvenido')) {
        mostrado = true;
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¡Bienvenido!', style: TextStyle(color: AppStyles.primaryColor)),
              content: Text(msg),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text('OK', style: TextStyle(color: AppStyles.primaryColor)),
                )
              ],
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: Header(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Sección de bienvenida del usuario
                Container(
                  decoration: AppStyles.userProfileDecoration(),
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 25),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.usuario.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.usuario.rol,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Destacados o promocionales
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorías de servicios',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Grid de categorías
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: categorias.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          return buildCategoryItem(index, context);
                        },
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Sección de servicios destacados
                      Text(
                        'Servicios destacados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final servicios = [
                              'Reparación de computadoras',
                              'Electricidad',
                              'Plomería',
                              'Mecánica automotriz',
                              'Limpieza del hogar'
                            ];
                            
                            final iconos = [
                              Icons.computer,
                              Icons.electrical_services,
                              Icons.plumbing,
                              Icons.car_repair,
                              Icons.cleaning_services
                            ];
                            
                            return Container(
                              width: 140,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppStyles.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconos[index],
                                      color: AppStyles.primaryColor,
                                      size: 32,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      servicios[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }

  Widget buildCategoryItem(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        // Animación de pulsación
        HapticFeedback.lightImpact();
        
        // Navegación según categoría
        if (categorias[index]['label'] == 'Tecnologia') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TecnologiayElectronicaPage()));
        } else if (categorias[index]['label'] == 'Vehículos') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VehiculosTransportePage()));
        } else if (categorias[index]['label'] == 'Eventos') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EventosEntretenimientoPage()));
        } else if (categorias[index]['label'] == 'Estetica') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BellezaEsteticaPage()));
        } else if (categorias[index]['label'] == 'Salud y Bienestar') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SaludBienestarPage()));
        } else if (categorias[index]['label'] == 'Servicios Generales') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiciosGeneralesPage()));
        } else if (categorias[index]['label'] == 'Educacion') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EducacionCapacitacionPage()));
        } else if (categorias[index]['label'] == 'Limpieza') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LimpiezaMantenimientoPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${categorias[index]['label']} en desarrollo'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: AppStyles.categoryItemDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categorias[index]['color'],
                    categorias[index]['color'].withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: categorias[index]['color'].withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                categorias[index]['icon'],
                color: Colors.white,
                size: 26,
              ),
            ),
            SizedBox(height: 10),
            Text(
              categorias[index]['label'],
              textAlign: TextAlign.center,
              style: AppStyles.categoryLabelStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppStyles.darkBlue,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar servicios...',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.explore, color: Colors.white),
          onPressed: () => mostrarDialogoCategorias(context),
          tooltip: 'Explorar categorías',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.bottomNavDecoration(),
      child: BottomNavigationBar(
        currentIndex: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

void mostrarDialogoCategorias(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: CategoriasDialog(),
      );
    },
  );
}

class CategoriasDialog extends StatefulWidget {
  @override
  _CategoriasDialogState createState() => _CategoriasDialogState();
}

class _CategoriasDialogState extends State<CategoriasDialog> with SingleTickerProviderStateMixin {
  String? categoriaExpandida;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  final Map<String, List<String>> categorias = {
    'Tecnología': [
      'Reparación de computadoras y laptops',
      'Mantenimiento y Reparación de celulares',
      'Instalación de cámaras de seguridad',
      'Configuración de redes',
      'Recuperación de datos',
      'Reparacion de televisores y electrodomésticos',
    ],
    'Vehículos': [
      'Mecánica automotriz',
      'Lavado y detallado de autos',
      'Cambio de llantas y baterías',
      'Servicio de grúa',
      'Transporte y mudanzas',
      'Lubricentro',
    ],
    'Limpieza': [
      'Limpieza del hogar y oficinas',
      'Lavandería y el planchado',
      'Desinfección',
      'Encerado y pulido de muebles',
    ],
    'Salud y Bienestar': [
      'Consulta médica a domicilio',
      'Enfermería y cuidados a domicilio',
      'Terapia física y rehabilitación',
      'Masajes y relajación',
      'Entrenador personal',
    ],
    'Educación': [
      'Clases Particulares',
      'Tutoriales en línea',
      'Capacitación en software',
      'Programas académicos',
      'Cursos y Certificaciones',
      'Vacaciones útiles',
    ],
    'Eventos': [
      'Fotografía y filmación',
      'Organización de eventos',
      'Catering y banquetes',
      'Música en vivo y DJ',
    ],
    'Estética': [
      'Peluquería y barbería a domicilio',
      'Manicure y pedicure',
      'Maquillaje y asesoría de imagen',
    ],
    'Servicios Generales': [
      'Albañilería',
      'Plomería',
      'Electricidad',
      'Carpintería',
      'Pintura y acabados',
      'Jardinería y paisajismo',
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: AppStyles.dialogDecoration(),
      padding: EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categorías de servicios',
                    style: AppStyles.dialogTitleStyle(),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 30, thickness: 1),
              ...categorias.entries.map((entry) {
                final titulo = entry.key;
                final subcategorias = entry.value;
                final expandido = categoriaExpandida == titulo;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          categoriaExpandida = expandido ? null : titulo;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              titulo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppStyles.darkBlue,
                              ),
                            ),
                            Icon(
                              expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppStyles.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expandido)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subcategorias.map((sub) {
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context); // Cierra el diálogo
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubcategoriaPage(nombre: sub),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 12, bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 8,
                                      width: 8,
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryColor.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        sub,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    Divider(height: 10, thickness: 0.5),
                  ],
                );
              }).toList(),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppStyles.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      color: AppStyles.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
