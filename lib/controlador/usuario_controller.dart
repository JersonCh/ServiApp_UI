import 'package:serviapp/modelo/usuario_model.dart';
import 'package:serviapp/servicios/firebase_service.dart';

class UsuarioController {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> createUser(Usuario usuario) async {
    await _firebaseService.createUser(usuario);
  }

  Future<void> updateUser(Usuario usuario) async {
    await _firebaseService.updateUser(usuario);
  }
}
