import 'dart:io';
import 'dart:convert';
import 'dart:async';

class Cliente {
  final WebSocket socket;
  Map<String, dynamic>? datosUsuario;
  bool disponible = true;

  Cliente(this.socket);
}

class SolicitudServicio {
  final Cliente solicitante;
  final int codRol;
  final String subcategoria;
  Timer? tiempoEspera;
  bool atendida = false;
  
  SolicitudServicio({
    required this.solicitante, 
    required this.codRol,
    required this.subcategoria,
  });
}

final List<Cliente> clients = [];
final List<SolicitudServicio> solicitudesPendientes = [];

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
        try {
          // Para mensajes normales
          if (msg is String) {
            if (msg.startsWith('login:')) {
              handleLogin(cliente, msg);
            } else if (msg.contains('accion')) {
              // Para solicitudes JSON
              final Map<String, dynamic> data = jsonDecode(msg);
              if (data['accion'] == 'buscar_proveedores') {
                handleBusquedaProveedores(cliente, data);
              } else if (data['accion'] == 'respuesta_solicitud') {
                handleRespuestaSolicitud(cliente, data);
              } else {
                // Mensaje normal
                final usuario = cliente.datosUsuario?['email'] ?? 'Usuario';
                print('Mensaje de $usuario: $msg');
                broadcastMessage('$usuario: $msg');
              }
            } else {
              // Mensaje normal
              final usuario = cliente.datosUsuario?['email'] ?? 'Usuario';
              print('Mensaje de $usuario: $msg');
              broadcastMessage('$usuario: $msg');
            }
          }
        } catch (e) {
          print('Error procesando mensaje: $e');
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

void handleLogin(Cliente cliente, String msg) {
  final jsonData = msg.substring(6);
  try {
    final datos = jsonDecode(jsonData);
    cliente.datosUsuario = datos;

    final nombre = datos['email'] ?? 'Usuario';
    cliente.socket.add('¡Bienvenido $nombre! Tu rol es: ${datos['rol']}');
    print('Usuario conectado: $datos');
  } catch (e) {
    cliente.socket.add('Error al procesar los datos de login.');
    print('Error al parsear JSON: $e');
  }
}

void handleBusquedaProveedores(Cliente solicitante, Map<String, dynamic> data) {
  final int codRol = data['codrol'];
  final String subcategoria = data['subcategoria'];
  
  print('Búsqueda de servicio: $subcategoria (codrol: $codRol)');
  
  // Crear nueva solicitud
  final solicitud = SolicitudServicio(
    solicitante: solicitante, 
    codRol: codRol,
    subcategoria: subcategoria,
  );
  
  solicitudesPendientes.add(solicitud);
  
  // Encontrar proveedores disponibles
  final proveedoresDisponibles = clients.where((cliente) => 
    cliente.datosUsuario != null && 
    cliente.datosUsuario!['codrol'] == codRol &&
    cliente.disponible == true
  ).toList();
  
  print('Proveedores disponibles encontrados: ${proveedoresDisponibles.length}');
  
  if (proveedoresDisponibles.isEmpty) {
    // No hay proveedores disponibles
    final respuesta = jsonEncode({
      'tipo': 'no_proveedores',
      'mensaje': 'No se encontraron proveedores disponibles para $subcategoria'
    });
    solicitante.socket.add(respuesta);
    solicitudesPendientes.remove(solicitud);
    return;
  }
  
  // Enviar solicitud a todos los proveedores disponibles
  for (var proveedor in proveedoresDisponibles) {
    final solicitudJson = jsonEncode({
      'tipo': 'solicitud_servicio',
      'subcategoria': subcategoria,
      'tiempo_restante': 15,
    });
    proveedor.socket.add(solicitudJson);
  }
  
  // Configurar temporizador para 15 segundos
  solicitud.tiempoEspera = Timer(Duration(seconds: 15), () {
    if (!solicitud.atendida) {
      final respuesta = jsonEncode({
        'tipo': 'tiempo_agotado',
        'mensaje': 'Tiempo de espera agotado, no hubo respuesta de los proveedores'
      });
      solicitante.socket.add(respuesta);
      solicitudesPendientes.remove(solicitud);
    }
  });
}

void handleRespuestaSolicitud(Cliente proveedor, Map<String, dynamic> data) {
  final bool aceptada = data['aceptar'] == true;
  final int codRol = proveedor.datosUsuario!['codrol'];
  
  // Buscar solicitud pendiente para este codRol
  final solicitudIndex = solicitudesPendientes.indexWhere((s) => 
    s.codRol == codRol && !s.atendida
  );
  
  if (solicitudIndex >= 0) {
    final solicitud = solicitudesPendientes[solicitudIndex];
    
    if (aceptada) {
      // Marcar como atendida para que no la tomen otros proveedores
      solicitud.atendida = true;
      
      // Cancelar el temporizador
      solicitud.tiempoEspera?.cancel();
      
      // Notificar al solicitante
      final respuesta = jsonEncode({
        'tipo': 'proveedor_encontrado',
        'proveedor': proveedor.datosUsuario,
      });
      solicitud.solicitante.socket.add(respuesta);
      
      // Marcar al proveedor como no disponible
      proveedor.disponible = false;
      
      // Notificar al proveedor que se conectó correctamente
      final confirmacion = jsonEncode({
        'tipo': 'solicitud_aceptada',
        'mensaje': 'Te has conectado con el cliente',
      });
      proveedor.socket.add(confirmacion);
      
      // Eliminar la solicitud de pendientes
      solicitudesPendientes.removeAt(solicitudIndex);
    }
  } else {
    // Solicitud ya no está disponible
    final mensaje = jsonEncode({
      'tipo': 'solicitud_no_disponible',
      'mensaje': 'Esta solicitud ya no está disponible',
    });
    proveedor.socket.add(mensaje);
  }
}

void broadcastMessage(String message) {
  for (var client in clients) {
    client.socket.add(message);
  }
}