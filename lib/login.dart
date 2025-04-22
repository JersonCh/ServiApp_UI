import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'estilos/styles.dart';
import 'main.dart'; // contiene MiApp

void main() {
  runApp(MyApp());
}

class Usuario {
  final int codusu;
  final String email;
  final String password;
  final String rol;
  final int codrol;
  final String numero;

  Usuario({
    required this.codusu,
    required this.email,
    required this.password,
    required this.rol,
    required this.codrol,
    required this.numero,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: AppStyles.appTheme(),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final List<Usuario> usuarios = [
    Usuario(codusu: 1, email: 'jf@gmail.com', password: '123', rol: 'Reparacion de computadoras', codrol: 11, numero: '920256485'),
    Usuario(codusu: 2, email: 'jc@gmail.com', password: '123', rol: 'Reparacion de computadoras', codrol: 11, numero: '910292249'),
    Usuario(codusu: 3, email: 'ac@gmail.com', password: '123', rol: 'Plomeria', codrol: 2, numero: '930124578'),
    Usuario(codusu: 4, email: 'el@gmail.com', password: '123', rol: 'Cerrajeria', codrol: 5, numero: '945652147'),
    Usuario(codusu: 5, email: 'ea@gmail.com', password: '123', rol: 'Pintura y acabados', codrol: 6, numero: '955452435'),
  ];

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  String errorMessage = '';
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = AppStyles.createFadeAnimation(_controller);
    _slideAnimation = AppStyles.createSlideAnimation(_controller);
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void validateLogin(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Por favor completa todos los campos';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Simular un pequeño retraso para mejorar la UX
    Future.delayed(Duration(milliseconds: 1500), () {
      final usuarioEncontrado = usuarios.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => Usuario(codusu: 0, email: '', password: '', rol: '', codrol: 0, numero: ''),
      );

      setState(() {
        isLoading = false;
        if (usuarioEncontrado.codusu != 0) {
          errorMessage = '';

          final channel = IOWebSocketChannel.connect('ws://192.168.18.79:3000');
          final datosUsuario = jsonEncode({
            'codusu': usuarioEncontrado.codusu,
            'email': usuarioEncontrado.email,
            'rol': usuarioEncontrado.rol,
            'codrol': usuarioEncontrado.codrol,
            'numero': usuarioEncontrado.numero,
          });

          channel.sink.add('login:$datosUsuario');

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => MiApp(
                channel: channel,
                usuario: usuarioEncontrado,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.easeOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 600),
            ),
          );
        } else {
          errorMessage = 'Correo electrónico o contraseña incorrectos.';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                // Fondo con formas decorativas
                Positioned(
                  top: -50,
                  right: -20,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: AppStyles.circleDecoration(AppStyles.accentColor, 0.2),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -30,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: AppStyles.circleDecoration(AppStyles.primaryColor, 0.15),
                  ),
                ),
                
                // Contenido principal
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Logo y título
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: AppStyles.logoDecoration(),
                            child: Icon(
                              Icons.handyman_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text('Bienvenido', style: AppStyles.titleStyle),
                        SizedBox(height: 8),
                        Text(
                          'Encuentra los mejores servicios para tu hogar',
                          textAlign: TextAlign.center,
                          style: AppStyles.subtitleStyle,
                        ),
                        SizedBox(height: 40),
                        
                        // Campos de entrada
                        Container(
                          decoration: AppStyles.formContainerDecoration(),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(fontSize: 15),
                                decoration: AppStyles.inputDecoration(
                                  'Correo Electrónico',
                                  'ejemplo@correo.com',
                                  Icons.email_outlined,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                obscureText: !passwordVisible,
                                style: TextStyle(fontSize: 15),
                                decoration: AppStyles.inputDecoration(
                                  'Contraseña',
                                  'Ingresa tu contraseña',
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: AppStyles.errorContainerDecoration(),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            errorMessage,
                                            style: AppStyles.errorTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Botón de inicio de sesión
                        ElevatedButton(
                          onPressed: isLoading ? null : () => validateLogin(context),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'INICIAR SESIÓN',
                                      style: AppStyles.buttonTextStyle,
                                    ),
                            ),
                          ),
                          style: AppStyles.primaryButtonStyle(),
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Texto de cuenta nueva
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿No tienes una cuenta? ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Regístrate',
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
