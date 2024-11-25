import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

//Variables de colores
final Color color_bg = Color.fromARGB(255, 230, 190, 152);
final Color color_bg2 = Color.fromARGB(255, 254, 235, 216);
final Color color_font = Color.fromARGB(255, 69, 65, 129);
final Color color_white = Color.fromARGB(255, 255, 255, 255);
final Color color_white2 = Color.fromARGB(255, 250, 250, 250);
final Color color_cancelar = Color.fromARGB(255, 244, 63, 63);
final Color color_grey = Colors.grey;
final Color color_black = Color.fromARGB(255, 0, 0, 0);
final Color color_effects = Colors.black.withOpacity(0.3);

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
            _imageName =
                result.files.first.name; // Guardar el nombre de la imagen
          });
        } else {
          // En móviles/escritorio usamos la ruta del archivo
          setState(() {
            _image = File(result.files.first.path!);
            _imageName =
                result.files.first.name; // Guardar el nombre de la imagen
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

        // Insertar en la tabla "topping"
        final responseTopping =
            await Supabase.instance.client.from("topping").insert({
          'nombre': _nombreController.text,
          'precio': precio,
          'foto': _imageName, // Registrar el nombre de la imagen aquí
          'estatus': 1,
        }).select();

        // Insertar en la tabla "topping2" si el registro en "topping" fue exitoso
        if (responseTopping.isNotEmpty) {
          final responseTopping2 =
              await Supabase.instance.client.from("topping2").insert({
            'nombre': _nombreController.text,
            'precio': precio,
            'foto': _imageName, // Registrar el mismo nombre de la imagen
            'estatus': 1,
          }).select();

          if (responseTopping2.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Topping registrado en ambas tablas exitosamente')),
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
              SnackBar(content: Text('Error al registrar en la segunda tabla')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar en la primera tabla')),
          );
        }

        setState(() {
          _isSubmitting = false;
        });
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
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Registro de Toppings',
          colorsito: color_bg,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: color_white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color_grey,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Registrar Topping',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color_font,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Topping',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.production_quantity_limits_outlined,
                        color: color_font,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un nombre de topping';
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
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.monetization_on_outlined,
                        color: color_font,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el precio del topping';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, ingrese un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: color_grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: _image != null
                        ? Image.file(_image!, height: 150)
                        : _webImage != null
                            ? Image.memory(_webImage!, height: 150)
                            : Text(
                                'No se ha seleccionado ninguna imagen',
                                style: TextStyle(color: color_grey),
                              ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Seleccionar Imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color_font,
                      foregroundColor: color_white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isSubmitting
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _registrarTopping,
                          child: Text(
                            'Registrar Topping',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color_font,
                            foregroundColor: color_white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
