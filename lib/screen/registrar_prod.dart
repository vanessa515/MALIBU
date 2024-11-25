import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data'; // Para manejar bytes en web
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para verificar si estamos en web

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
  Uint8List? _webImage; // Para almacenar la imagen en web
  String? _imageName; // Para almacenar el nombre de la imagen

  List<dynamic> _categorias = [];
  dynamic _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    try {
      final response =
          await Supabase.instance.client.from("categoria").select();

      setState(() {
        _categorias = response;
      });
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

  Future<void> _registrarProducto() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        double precio = double.tryParse(_precioController.text) ?? 0.0;

        final response =
            await Supabase.instance.client.from("producto").insert({
          'nombre': _nombreController.text,
          'precio': precio,
          'fk_categoria': _categoriaSeleccionada['pk_categoria'],
          'estatus': 1,
          'foto': _imageName, // Registrar el nombre de la imagen aquí
        }).select();

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
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Registrar Producto',
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
                  color: color_effects,
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
                    'Registrar Producto',
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
                      labelText: 'Nombre del Producto',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.production_quantity_limits,
                        color: color_font,
                      ),
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
                        return 'Por favor, ingrese el precio del producto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, ingrese un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<dynamic>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Categoría',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
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
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: color_grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
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
                          onPressed: _registrarProducto,
                          child: Text(
                            'Registrar Producto',
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
