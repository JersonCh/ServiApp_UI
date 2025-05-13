class Usuario {
  final String id;
  final String email;
  final String password;
  final String rol;

  Usuario({
    required this.id,
    required this.email,
    required this.password,
    required this.rol,
  });

  // Función para convertir el usuario en un Map, útil para Firebase.
  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'password': password, 'rol': rol};
  }

  // Función para crear un usuario desde un Map (útil para recuperar datos de Firebase).
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      rol: map['rol'],
    );
  }
}
