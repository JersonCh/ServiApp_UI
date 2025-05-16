import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/global_user.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para iniciar sesión
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Obtener información del usuario desde Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          // Asigna el UID del usuario logueado a la clase GlobalUser
          GlobalUser.uid = user.uid;
          
          // También guardar el rol del usuario
          GlobalUser.rol = userData['rol'] ?? 'cliente';
          
          // Devolver un mapa con usuario y rol
          return {
            'user': user,
            'rol': GlobalUser.rol,
          };
        }
        
        // Si no existe documento, asume rol cliente por defecto
        GlobalUser.uid = user.uid;
        GlobalUser.rol = 'cliente';
        
        return {
          'user': user,
          'rol': 'cliente',
        };
      }

      return null;
    } catch (e) {
      print('Error de login: $e');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    // Limpiar datos al cerrar sesión
    GlobalUser.uid = null;
    GlobalUser.rol = null;
  }
}