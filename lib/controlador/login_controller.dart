import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviapp/modelo/global_user.dart'; // Importa la clase GlobalUser

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para iniciar sesión
  Future<User?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Asigna el UID del usuario logueado a la clase GlobalUser
        GlobalUser.uid = user.uid;
      }

      return user;
    } catch (e) {
      print('Error de login: $e');
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    // Opcionalmente puedes limpiar el UID al cerrar sesión
    GlobalUser.uid = null;
  }
}
