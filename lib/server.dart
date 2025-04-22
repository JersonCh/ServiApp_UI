import 'dart:io';
import 'dart:convert';

class Cliente {
  final WebSocket socket;
  Map<String, dynamic>? datosUsuario;

  Cliente(this.socket);
}

final List<Cliente> clients = [];

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);
  print('Servidor WebSocket activo en ws://0.0.0.0:3000');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      final cliente = Cliente(socket);
      clients.add(cliente);
      print('Cliente conectado. Total: ${clients.length}');

      socket.listen((msg) {
        if (msg.startsWith('login:')) {
          final jsonData = msg.substring(6);
          try {
            final datos = jsonDecode(jsonData);
            cliente.datosUsuario = datos;

            final nombre = datos['email'] ?? 'Usuario';
            socket.add('¡Bienvenido $nombre! Tu rol es: ${datos['rol']}');
            print('Usuario conectado: $datos');
          } catch (e) {
            socket.add('Error al procesar los datos de login.');
            print('Error al parsear JSON: $e');
          }
        } else {
          final usuario = cliente.datosUsuario?['email'] ?? 'Usuario';
          broadcastMessage('$usuario: $msg');
        }
      }, onDone: () {
        clients.remove(cliente);
        print('Cliente desconectado. Total: ${clients.length}');
      });
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
    }
  }
}

void broadcastMessage(String message) {
  for (var client in clients) {
    client.socket.add(message);
  }
}
