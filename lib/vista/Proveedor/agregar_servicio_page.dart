import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:serviapp/controlador/servicio_controller.dart';
import 'package:serviapp/styles/Proveedor/agregar_servicio_styles.dart';

class AgregarServicioPage extends StatefulWidget {
  @override
  _AgregarServicioPageState createState() => _AgregarServicioPageState();
}

class _AgregarServicioPageState extends State<AgregarServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final ServicioController _servicioController = ServicioController();
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  
  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  List<String> _subcategorias = [];
  bool _cargando = false;
  
  // Variable para almacenar la imagen seleccionada
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  
  // Lista de categorías disponibles
  final List<String> _categorias = [
    'Tecnologia',
    'Vehículos',
    'Eventos',
    'Estetica',
    'Salud y Bienestar',
    'Servicios Generales',
    'Educacion',
    'Limpieza',
  ];
  
  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
  
  void _actualizarSubcategorias(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
      _subcategorias = _servicioController.obtenerSubcategorias(categoria);
      _subcategoriaSeleccionada = null; // Resetear subcategoría al cambiar categoría
    });
  }
  
  // Método para seleccionar imagen de la galería
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Reducir calidad para optimizar el tamaño
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }
  
  // Método para tomar una foto con la cámara
  Future<void> _tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = File(imagen.path);
      });
    }
  }
  
  // Método para mostrar opciones de selección de imagen
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar una foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _tomarFoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _registrarServicio() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _subcategoriaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona categoría y subcategoría')),
        );
        return;
      }
      
      // Verificar si se ha seleccionado una imagen
      if (_imagenSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona una imagen para el servicio')),
        );
        return;
      }
      
      setState(() {
        _cargando = true;
      });
      
      try {
        bool resultado = await _servicioController.registrarServicio(
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          categoria: _categoriaSeleccionada!,
          subcategoria: _subcategoriaSeleccionada!,
          telefono: _telefonoController.text,
          ubicacion: _ubicacionController.text,
          imagenFile: _imagenSeleccionada, // Pasar la imagen seleccionada
        );
        
        setState(() {
          _cargando = false;
        });
        
        if (resultado) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Servicio registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Volver a la pantalla anterior
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar el servicio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _cargando = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Servicio'),
        centerTitle: true,
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección para la imagen del servicio
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imagen del Servicio',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          Center(
                            child: GestureDetector(
                              onTap: _mostrarOpcionesImagen,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: _imagenSeleccionada != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          _imagenSeleccionada!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 60,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Toca para agregar una imagen',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Sección de información del servicio
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Servicio',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          // Título
                          TextFormField(
                            controller: _tituloController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Título del Servicio',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un título';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Descripción',
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa una descripción';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Categoría
                          DropdownButtonFormField<String>(
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Categoría',
                              prefixIcon: Icon(Icons.category),
                            ),
                            value: _categoriaSeleccionada,
                            items: _categorias.map((String categoria) {
                              return DropdownMenuItem<String>(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _actualizarSubcategorias(newValue);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona una categoría';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Subcategoría
                          DropdownButtonFormField<String>(
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Subcategoría',
                              prefixIcon: Icon(Icons.subdirectory_arrow_right),
                            ),
                            value: _subcategoriaSeleccionada,
                            items: _subcategorias.map((String subcategoria) {
                              return DropdownMenuItem<String>(
                                value: subcategoria,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                                  child: Text(
                                    subcategoria,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: _subcategorias.isEmpty
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _subcategoriaSeleccionada = newValue;
                                    });
                                  },
                            validator: (value) {
                              if (_categoriaSeleccionada != null &&
                                  (value == null || value.isEmpty)) {
                                return 'Por favor selecciona una subcategoría';
                              }
                              return null;
                            },
                            hint: Text(_categoriaSeleccionada == null
                                ? 'Primero selecciona una categoría'
                                : 'Selecciona una subcategoría'),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Sección de información de contacto
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AgregarServicioStyles.containerDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Contacto',
                            style: AgregarServicioStyles.titleStyle,
                          ),
                          SizedBox(height: 20),
                          
                          // Teléfono
                          TextFormField(
                            controller: _telefonoController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Teléfono de contacto',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un teléfono de contacto';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Ubicación
                          TextFormField(
                            controller: _ubicacionController,
                            decoration: AgregarServicioStyles.inputDecoration.copyWith(
                              labelText: 'Ubicación (opcional)',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: AgregarServicioStyles.secondaryButtonStyle,
                            child: Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _registrarServicio,
                            style: AgregarServicioStyles.primaryButtonStyle,
                            child: Text('Registrar Servicio'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}