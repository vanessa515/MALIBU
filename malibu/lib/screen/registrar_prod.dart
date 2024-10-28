import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data'; // Para manejar bytes en web
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar si estamos en web

class RegistroProducto extends StatefulWidget {
  const RegistroProducto({super.key});

  @override
  State<RegistroProducto> createState() => _RegistroProductoState();
}

class _RegistroProductoState extends State<RegistroProducto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  bool _isSubmitting = false;
  File? _image;
  Uint8List? _webImage; 
  String? _imageName; 

  List<dynamic> _categorias = [];
  dynamic _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    try {
      final response = await Supabase.instance.client.from("categoria").select();

      if (response != null) {
        setState(() {
          _categorias = response;
        });
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          // En web usamos los bytes
          setState(() {
            _webImage = result.files.first.bytes;
            _imageName = result.files.first.name; 
          });
        } else {
      
          setState(() {
            _image = File(result.files.first.path!);
            _imageName = result.files.first.name; 
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se ha seleccionado ninguna imagen')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _registrarProducto() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        double precio = double.tryParse(_precioController.text) ?? 0.0;

        final response = await Supabase.instance.client
            .from("producto")
            .insert({
              'nombre': _nombreController.text,
              'precio': precio,
              'fk_categoria': _categoriaSeleccionada['pk_categoria'],
              'estatus': 1,
              'foto': _imageName, 
            })
            .select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto registrado exitosamente')),
          );
          _nombreController.clear();
          _precioController.clear();
          setState(() {
            _image = null;
            _webImage = null;
            _imageName = null; // Reiniciar el nombre de la imagen
            _categoriaSeleccionada = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar producto')),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'REGISTRO PRODUCTO',
        colorsito: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre de producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(
                  labelText: 'Precio del Producto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el precio del producto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Dropdown para seleccionar categoría
              DropdownButtonFormField<dynamic>(
                decoration: InputDecoration(
                  labelText: 'Seleccionar Categoría',
                  border: OutlineInputBorder(),
                ),
                value: _categoriaSeleccionada,
                items: _categorias.map((categoria) {
                  return DropdownMenuItem<dynamic>(
                    value: categoria,
                    child: Text(categoria['nombre_cat']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Mostrar imagen según la plataforma
              _image != null
                  ? Image.file(_image!, height: 150)
                  : _webImage != null
                      ? Image.memory(_webImage!, height: 150)
                      : Text('No se ha seleccionado ninguna imagen'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registrarProducto,
                      child: Text('Registrar Producto'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
