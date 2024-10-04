import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart' show kIsWeb; 

class RegistroTopping extends StatefulWidget {
  const RegistroTopping({super.key});

  @override
  State<RegistroTopping> createState() => _RegistroToppingState();
}

class _RegistroToppingState extends State<RegistroTopping> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  bool _isSubmitting = false;
  File? _image;
  Uint8List? _webImage; // Para almacenar la imagen en web
  String? _imageName; // Para almacenar el nombre de la imagen

 
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
            _imageName = result.files.first.name; // Guardar el nombre de la imagen
          });
        } else {
          // En móviles/escritorio usamos la ruta del archivo
          setState(() {
            _image = File(result.files.first.path!);
            _imageName = result.files.first.name; // Guardar el nombre de la imagen
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

  Future<void> _registrarTopping() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        double precio = double.tryParse(_precioController.text) ?? 0.0;

        final response = await Supabase.instance.client
            .from("topping")
            .insert({
              'nombre': _nombreController.text,
              'precio': precio,
              'foto': _imageName, // Registrar el nombre de la imagen aquí
              'estatus': 1,
            })
            .select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Topping registrado exitosamente')),
          );
          _nombreController.clear();
          _precioController.clear();
          setState(() {
            _image = null;
            _webImage = null;
            _imageName = null; // Reiniciar el nombre de la imagen
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
        titulo: 'REGISTRO TOPPING',
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
                  labelText: 'Nombre del Topping',
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
                  labelText: 'Precio del Topping',
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
                      onPressed: _registrarTopping,
                      child: Text('Registrar Topping'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
