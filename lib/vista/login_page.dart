import 'package:flutter/material.dart';
import 'package:serviapp/vista/home_page.dart';
import 'package:serviapp/vista/usuario/new_user_page.dart';
import 'package:serviapp/controlador/login_controller.dart';
import 'package:serviapp/styles/login_styles.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = LoginController();
  bool _obscurePassword = true;

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    final user = await loginController.loginUser(email, password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/login_illustration.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Log In", style: LoginStyles.titleStyle),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: LoginStyles.inputDecoration.copyWith(
                labelText: "EMAIL ID",
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: LoginStyles.inputDecoration.copyWith(
                labelText: "PASSWORD",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // lógica para recuperar contraseña
                },
                child: const Text(
                  "Forget Password ?",
                  style: LoginStyles.linkStyle,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: login,
              style: LoginStyles.buttonStyle,
              child: const Text("Login", style: LoginStyles.buttonTextStyle),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Or"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(Icons.facebook, Colors.blue),
                _buildSocialButton(Icons.g_mobiledata, Colors.redAccent),
                _buildSocialButton(Icons.camera_alt, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Redirigir a la página de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewUserPage()),
                  );
                },
                child: const Text(
                  "Don’t have an account? Sign Up",
                  style: LoginStyles.linkStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSocialButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          // lógica de login social
        },
      ),
    );
  }
}
