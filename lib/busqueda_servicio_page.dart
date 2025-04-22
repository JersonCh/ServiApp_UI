import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BusquedaServicioPage extends StatefulWidget {
  final String subcategoria;
  final int codRol;

  const BusquedaServicioPage({
    required this.subcategoria,
    required this.codRol,
  });

  @override
  _BusquedaServicioPageState createState() => _BusquedaServicioPageState();
}

class _BusquedaServicioPageState extends State<BusquedaServicioPage> {
  bool buscando = true;
  String mensaje = 'Buscando proveedores de servicio...';
  WebSocketChannel? channel;
  bool proveedorEncontrado = false;
  Map<String, dynamic>? proveedorAceptado;

  @override
  void initState() {
    super.initState();
    _conectarAlServidor();
  }

  void _conectarAlServidor() {
    try {
      // Conectar al servidor WebSocket
      channel = IOWebSocketChannel.connect('ws://192.168.18.79:3000');
      
      // Enviar solicitud de búsqueda al servidor
      final solicitud = jsonEncode({
        'accion': 'buscar_proveedores',
        'codrol': widget.codRol,
        'subcategoria': widget.subcategoria,
      });
      
      channel!.sink.add(solicitud);
      
      // Escuchar respuestas del servidor
      channel!.stream.listen((mensaje) {
        final data = jsonDecode(mensaje);
        
        if (data['tipo'] == 'proveedor_encontrado') {
          setState(() {
            buscando = false;
            mensaje = 'Proveedor encontrado';
            proveedorEncontrado = true;
            proveedorAceptado = data['proveedor'];
          });
        } else if (data['tipo'] == 'no_proveedores') {
          setState(() {
            buscando = false;
            mensaje = 'No se encontraron proveedores disponibles';
          });
          
          // Mostrar alerta y volver después de 3 segundos
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (data['tipo'] == 'tiempo_agotado') {
          setState(() {
            buscando = false;
            mensaje = 'Tiempo de espera agotado';
          });
          
          // Mostrar alerta y volver después de 3 segundos
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }, onError: (error) {
        setState(() {
          buscando = false;
          mensaje = 'Error de conexión';
        });
      }, onDone: () {
        if (mounted && !proveedorEncontrado) {
          setState(() {
            buscando = false;
            mensaje = 'Conexión cerrada';
          });
        }
      });
      
    } catch (e) {
      setState(() {
        buscando = false;
        mensaje = 'Error al conectar: $e';
      });
    }
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscando Servicio'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (buscando) ...[
              CircularProgressIndicator(
                color: Colors.blue[800],
              ),
              SizedBox(height: 20),
              Text(
                mensaje,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Buscando proveedores para: ${widget.subcategoria}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ] else if (proveedorEncontrado) ...[
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                '¡Proveedor encontrado!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${proveedorAceptado!['email']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text('${proveedorAceptado!['rol']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey),
                          SizedBox(width: 5),
                          Text('${proveedorAceptado!['numero']}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Implementar llamada
                            },
                            icon: Icon(Icons.call),
                            label: Text('Llamar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Implementar mensaje
                            },
                            icon: Icon(Icons.message),
                            label: Text('Mensaje'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                mensaje,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}