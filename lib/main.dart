import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'vehiculos_transporte/main.dart';
import 'eventos_entretenimiento/main.dart';
import 'subcategoria_page.dart';
import 'belleza_estetica/main.dart';
import 'salud_bienestar/main.dart';
import 'Tecnologiaelectronica/main.dart';
import 'servicios_generales/main.dart';
import 'limpieza_mantenimiento/main.dart';
import 'educacion_capacitacion/main.dart';
import 'dart:convert';
import 'dart:async';

class MiApp extends StatelessWidget {
  final WebSocketChannel channel;
  final Usuario usuario;

  const MiApp({required this.channel, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.w600),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[800],
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
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
    {
      'icon': Icons.laptop_mac,
      'label': 'Tecnologia',
      'color': Color(0xFF2979FF),
      'gradient': LinearGradient(
        colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.directions_car_rounded,
      'label': 'Vehículos',
      'color': Color(0xFF00ACC1),
      'gradient': LinearGradient(
        colors: [Color(0xFF00ACC1), Color(0xFF006064)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.cleaning_services_rounded,
      'label': 'Limpieza',
      'color': Color(0xFF26A69A),
      'gradient': LinearGradient(
        colors: [Color(0xFF26A69A), Color(0xFF00695C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Salud y Bienestar',
      'color': Color(0xFFEC407A),
      'gradient': LinearGradient(
        colors: [Color(0xFFEC407A), Color(0xFFC2185B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Educacion',
      'color': Color(0xFF8E24AA),
      'gradient': LinearGradient(
        colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.celebration_rounded,
      'label': 'Eventos',
      'color': Color(0xFFFF7043),
      'gradient': LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.spa_rounded,
      'label': 'Estetica',
      'color': Color(0xFFAB47BC),
      'gradient': LinearGradient(
        colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'icon': Icons.handyman_rounded,
      'label': 'Servicios Generales',
      'color': Color(0xFF546E7A),
      'gradient': LinearGradient(
        colors: [Color(0xFF546E7A), Color(0xFF263238)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  bool mostrado = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController(initialPage: 0);
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _animationController.forward();
    
    widget.channel.stream.listen((msg) {
      if (!mostrado && msg.toString().startsWith('¡Bienvenido')) {
        mostrado = true;
        Future.delayed(Duration.zero, () {
          _mostrarMensajeBienvenida(msg.toString());
        });
      } else {
        // Intenta decodificar como JSON para ver si es una solicitud de servicio
        try {
          final data = jsonDecode(msg);
          if (data['tipo'] == 'solicitud_servicio') {
            _mostrarNotificacionSolicitud(data);
          }
        } catch (e) {
          // No es JSON, ignorar
        }
      }
    });
  }
  
  void _mostrarMensajeBienvenida(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Comenzar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarNotificacionSolicitud(Map<String, dynamic> data) {
    if (!mounted) return;

    final subcategoria = data['subcategoria'];
    int tiempoRestante = data['tiempo_restante'] ?? 15;
    
    bool dialogOpen = true;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Iniciar el timer solo una vez
            if (countdownTimer == null) {
              countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                if (!dialogOpen || !mounted) {
                  timer.cancel();
                  return;
                }

                if (tiempoRestante > 0) {
                  // Actualizamos el estado del diálogo
                  setDialogState(() {
                    tiempoRestante--;
                  });
                } else {
                  timer.cancel();
                  if (dialogOpen && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                    dialogOpen = false;
                  }
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notification_important_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            '¡Nueva solicitud!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Un cliente necesita servicio de:',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 12),
                          Text(
                            subcategoria,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tiempoRestante <= 5 ? Colors.red.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 22,
                                  color: tiempoRestante <= 5 ? Colors.red : Colors.blue[800],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tiempo: $tiempoRestante segundos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: tiempoRestante <= 5 ? Colors.red : Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                countdownTimer?.cancel();
                                if (dialogOpen && Navigator.of(context, rootNavigator: true).canPop()) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  dialogOpen = false;
                                }
                                widget.channel.sink.add(jsonEncode({
                                  'accion': 'respuesta_solicitud',
                                  'aceptar': false
                                }));
                              },
                              child: Text(
                                'Rechazar',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                countdownTimer?.cancel();
                                if (dialogOpen && Navigator.of(context, rootNavigator: true).canPop()) {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  dialogOpen = false;
                                }
                                widget.channel.sink.add(jsonEncode({
                                  'accion': 'respuesta_solicitud',
                                  'aceptar': true
                                }));
                              },
                              child: Text('Aceptar'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
      dialogOpen = false;
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: Header(),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomePage(),
          _buildPerfilPage(),
          _buildBuscarPage(),
          _buildConfiguracionPage(),
        ],
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildHomePage() {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeHeader(),
            _buildSearchBar(),
            _buildCategoriesGrid(),
            _buildPopularServices(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[900]!],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.usuario.email,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '¿Qué servicio necesitas hoy?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar servicio...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => mostrarDialogoCategorias(context),
                child: Text('Ver todas'),
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (categorias[index]['label'] == 'Tecnologia') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TecnologiayElectronicaPage()),
                    );
                  } else if (categorias[index]['label'] == 'Vehículos') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VehiculosTransportePage()),
                    );
                  } else if (categorias[index]['label'] == 'Eventos') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventosEntretenimientoPage()),
                    );
                  } else if (categorias[index]['label'] == 'Estetica') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BellezaEsteticaPage()),
                    );
                  } else if (categorias[index]['label'] == 'Salud y Bienestar') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SaludBienestarPage()),
                    );
                  } else if (categorias[index]['label'] == 'Servicios Generales') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ServiciosGeneralesPage()),
                    );
                  } else if (categorias[index]['label'] == 'Educacion') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EducacionCapacitacionPage()),
                    );
                  } else if (categorias[index]['label'] == 'Limpieza') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LimpiezaMantenimientoPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${categorias[index]['label']} en desarrollo'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.blue[800],
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: categorias[index]['gradient'],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: categorias[index]['color'].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            categorias[index]['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      categorias[index]['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServices() {
    final List<Map<String, dynamic>> popularServices = [
      {
        'title': 'Reparación de computadoras',
        'rating': 4.8,
        'reviews': 120,
        'icon': Icons.computer_rounded,
        'color': Colors.blue[700]!,
      },
      {
        'title': 'Limpieza del hogar',
        'rating': 4.7,
        'reviews': 85,
        'icon': Icons.cleaning_services_rounded,
        'color': Colors.teal[700]!,
      },
      {
        'title': 'Plomería de emergencia',
        'rating': 4.9,
        'reviews': 210,
        'icon': Icons.plumbing_rounded,
        'color': Colors.indigo[700]!,
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Servicios populares',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Ver todos'),
              ),
            ],
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: popularServices.length,
            itemBuilder: (context, index) {
              final service = popularServices[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: service['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service['icon'],
                      color: service['color'],
                      size: 28,
                    ),
                  ),
                  title: Text(
                    service['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${service['rating']} (${service['reviews']} reseñas)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubcategoriaPage(nombre: service['title']),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Páginas adicionales
  Widget _buildPerfilPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 80, color: Colors.blue[800]),
          SizedBox(height: 16),
          Text(
            'Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Esta sección está en desarrollo'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: Text('Editar perfil'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscarPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.blue[800]),
          SizedBox(height: 16),
          Text(
            'Buscar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Esta sección está en desarrollo'),
        ],
      ),
    );
  }

  Widget _buildConfiguracionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_rounded, size: 80, color: Colors.blue[800]),
          SizedBox(height: 16),
          Text(
            'Configuración',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Esta sección está en desarrollo'),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar aquí',
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => mostrarDialogoCategorias(context),
          icon: Icon(Icons.explore, color: Colors.white),
          label: Text(
            'Categorías',
            style: TextStyle(color: Colors.white),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class Footer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Footer({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: onTap,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded),
              ),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search_rounded),
              ),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings_rounded),
              ),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

void mostrarDialogoCategorias(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  late AnimationController _animationController;

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
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade800, Colors.blue.shade900],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.category_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Categorías de servicios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categorias.entries.map((entry) {
                  final titulo = entry.key;
                  final subcategorias = entry.value;
                  final expandido = categoriaExpandida == titulo;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: expandido ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(titulo).withOpacity(0.2),
                            child: Icon(
                              _getCategoryIcon(titulo),
                              color: _getCategoryColor(titulo),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: expandido ? Colors.blue.shade800 : Colors.black87,
                            ),
                          ),
                          trailing: AnimatedRotation(
                            turns: expandido ? 0.25 : 0,
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: expandido ? Colors.blue.shade800 : Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (expandido) {
                                categoriaExpandida = null;
                                _animationController.reverse();
                              } else {
                                categoriaExpandida = titulo;
                                _animationController.forward();
                              }
                            });
                          },
                        ),
                        AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: expandido ? null : 0,
                            padding: EdgeInsets.only(left: 16, right: 16, bottom: expandido ? 12 : 0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: subcategorias.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(context); // Cierra el diálogo
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubcategoriaPage(nombre: subcategorias[index]),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: _getCategoryColor(titulo),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            subcategorias[index],
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
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Tecnología':
        return Icons.computer_rounded;
      case 'Vehículos':
        return Icons.directions_car_rounded;
      case 'Limpieza':
        return Icons.cleaning_services_rounded;
      case 'Salud y Bienestar':
        return Icons.favorite_rounded;
      case 'Educación':
        return Icons.school_rounded;
      case 'Eventos':
        return Icons.celebration_rounded;
      case 'Estética':
        return Icons.spa_rounded;
      case 'Servicios Generales':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Tecnología':
        return Color(0xFF2979FF);
      case 'Vehículos':
        return Color(0xFF00ACC1);
      case 'Limpieza':
        return Color(0xFF26A69A);
      case 'Salud y Bienestar':
        return Color(0xFFEC407A);
      case 'Educación':
        return Color(0xFF8E24AA);
      case 'Eventos':
        return Color(0xFFFF7043);
      case 'Estética':
        return Color(0xFFAB47BC);
      case 'Servicios Generales':
        return Color(0xFF546E7A);
      default:
        return Colors.blue;
    }
  }
}