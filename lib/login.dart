import 'package:flutter/material.dart';
import 'main.dart'; // Importa el archivo de la página de inicio

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

class _LoginPageState extends State<LoginPage> {
  // Variables estáticas de correo y contraseña
  final String staticEmail = 'jf@gmail.com';
  final String staticPassword = '123';

  // Controladores para los campos de texto
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Variable para mostrar mensajes de error
  String errorMessage = '';

  // Función para validar el login y redirigir
  void validateLogin(BuildContext context) {
    setState(() {
      if (emailController.text == staticEmail &&
          passwordController.text == staticPassword) {
        // Redirige a la página de inicio después del login exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MiApp()), // Redirige correctamente
        );
      } else {
        errorMessage = 'Correo electrónico o contraseña incorrectos.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INICIAR SESIÓN'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Imagen centrada y más grande
                Image.network(
                  'https://img.freepik.com/vector-premium/icono-inicio-sesion-icono-usuario-estilo-plano-aislado-fondo-gris-simbolo-clave-diseno-su-sitio-web-imagen-arte-logotipo-aplicacion-ui-ilustracion-vectorial-eps10-imagen-jpeg_775815-637.jpg',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 30),
                // Caja de texto para correo con diseño mejorado
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'Ingresa tu correo',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: errorMessage.isNotEmpty &&
                            !errorMessage.contains('¡Inicio de sesión exitoso!')
                        ? errorMessage
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                // Caja de texto para contraseña con diseño mejorado
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: errorMessage.isNotEmpty &&
                            !errorMessage.contains('¡Inicio de sesión exitoso!')
                        ? errorMessage
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                // Botón de login con estilo
                ElevatedButton(
                  onPressed: () => validateLogin(context),
                  child: Text('Ingresar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blueAccent, // Color de fondo del botón
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 40), // Padding
                  ),
                ),
                SizedBox(height: 20),
                // Mensaje de error con estilo
                Text(errorMessage,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
