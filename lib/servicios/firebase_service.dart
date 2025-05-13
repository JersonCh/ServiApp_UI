import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/modelo/global_user.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el usuario actual
  Future<User?> getUser() async {
    return _auth.currentUser;
  }

  // Crear un nuevo usuario en Firebase Authentication y Firestore
  Future<void> createUser(Usuario usuario) async {
    try {
      // Crear usuario en Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: usuario.email,
            password: usuario.password,
          );

      // Obtener el UID del usuario creado
      final User? user = userCredential.user;

      // Si el usuario fue creado correctamente, guardar los datos en Firestore
      if (user != null) {
        // Asignar el UID a GlobalUser
        GlobalUser.uid = user.uid;

        // Guardar datos del usuario, incluyendo el rol, en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': usuario.email,
          'rol': usuario.rol, // Aquí asignamos el rol 'cliente'
        });
      }
    } catch (e) {
      print('Error al crear el usuario: $e');
      throw Exception('Error al crear el usuario');
    }
  }

  // Actualizar la información del usuario en Firestore
  Future<void> updateUser(Usuario usuario) async {
    await _firestore
        .collection('users')
        .doc(usuario.id)
        .update(usuario.toMap());
  }

  // Iniciar sesión con Firebase Authentication
  Future<User?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        // Asignar el UID a GlobalUser
        GlobalUser.uid = user.uid;
      }

      return user;
    } catch (e) {
      print('Error al logear: $e');
      return null;
    }
  }

  // Cerrar sesión de Firebase
  Future<void> logout() async {
    await _auth.signOut();
    // Limpiar el UID al cerrar sesión
    GlobalUser.uid = null;
  }
}
