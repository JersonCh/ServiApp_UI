// lib/vista/Usuario/perfil_usuario.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviapp/modelo/global_user.dart';
import 'package:serviapp/styles/home_styles.dart';

class PerfilUsuarioPage extends StatelessWidget {
  const PerfilUsuarioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usuarioid = GlobalUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: kTitleStyle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarPerfil(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(usuarioid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return _buildProfileContent(context, userData);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Sección de avatar y nombre
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            userData['nombre'] ?? 'Nombre no disponible',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            userData['email'] ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          // Sección de información personal
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(Icons.credit_card, 'DNI', userData['dni']),
                  const Divider(),
                  _buildInfoRow(Icons.phone, 'Teléfono', userData['celular'] ?? 'No especificado'),
                  const Divider(),
                  _buildInfoRow(Icons.person, 'Rol', userData['rol'] ?? 'cliente'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          _buildActionButton(
            icon: Icons.lock,
            text: 'Cambiar contraseña',
            onPressed: () => _cambiarContrasena(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.logout,
            text: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

 Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        // Icono
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        
        // Etiqueta (ocupará todo el espacio disponible)
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        
        // Valor
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.white : Colors.black87,
          backgroundColor: isDestructive ? Colors.red : Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _editarPerfil(BuildContext context) {
    // Navegar a pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirigiendo a edición de perfil')),
    );
  }

  void _cambiarContrasena(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: const Text('Se enviará un enlace a tu correo para cambiar la contraseña'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _enviarEnlaceCambioContrasena(context);
            },
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarEnlaceCambioContrasena(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace enviado a tu correo electrónico')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Redirigir a login
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }
}