import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'main.dart'; // contiene MiApp

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade200, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isLoggingIn = false;
  String errorMessage = '';
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOutQuad),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void validateLogin(BuildContext context) async {
    setState(() {
      isLoggingIn = true;
      errorMessage = '';
    });

    String email = emailController.text.trim();
    String password = passwordController.text;

    // Simulamos una pequeña espera para mostrar el efecto de carga
    await Future.delayed(Duration(milliseconds: 1500));

    final usuarioEncontrado = usuarios.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => Usuario(codusu: 0, email: '', password: '', rol: '', codrol: 0, numero: ''),
    );

    setState(() {
      isLoggingIn = false;
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
              var curve = Curves.easeInOutQuart;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      } else {
        errorMessage = 'Correo electrónico o contraseña incorrectos.';
        _animateError();
      }
    });
  }

  void _animateError() {
    ShakeAnimation(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade600,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                              tag: 'logo',
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade50,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            AnimatedTextKit(
                              isRepeatingAnimation: false,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'INICIAR SESIÓN',
                                  textStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                    letterSpacing: 1.5,
                                  ),
                                  speed: Duration(milliseconds: 150),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                hintText: 'Ingresa tu correo',
                                prefixIcon: Icon(Icons.email, color: Colors.blue.shade600),
                                labelStyle: TextStyle(color: Colors.blue.shade600),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: !_passwordVisible,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: 'Ingresa tu contraseña',
                                prefixIcon: Icon(Icons.lock, color: Colors.blue.shade600),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.blue.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                                labelStyle: TextStyle(color: Colors.blue.shade600),
                              ),
                            ),
                            SizedBox(height: 12),
                            if (errorMessage.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: TextStyle(color: Colors.red, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoggingIn ? null : () => validateLogin(context),
                                child: isLoggingIn
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text('INGRESAR'),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'v1.0.0',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShakeAnimation {
  ShakeAnimation(BuildContext context) {
    _animateShake(context);
  }

  void _animateShake(BuildContext context) {
    const double shakeOffset = 5.0;
    
    Future.delayed(Duration.zero, () {
      HapticFeedback.mediumImpact();
    });

    final OverlayState overlayState = Overlay.of(context);
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Offset? position = box?.localToGlobal(Offset.zero);

    if (box == null || position == null) return;

    // Crear un controlador de animación
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: Navigator.of(context),
    );

    // Definir la animación de sacudida
    Animation<Offset> animation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(shakeOffset, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Offset(shakeOffset, 0), end: Offset(-shakeOffset, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: Offset(-shakeOffset, 0), end: Offset(shakeOffset * 0.5, 0)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: Offset(shakeOffset * 0.5, 0), end: Offset(-shakeOffset * 0.5, 0)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Offset(-shakeOffset * 0.5, 0), end: Offset.zero), weight: 1),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));

    controller.forward();
  }
}