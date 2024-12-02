import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';

//Variables de colores
final Color color_bg = Color.fromARGB(255, 230, 190, 152);
final Color color_bg2 = Color.fromARGB(255, 254, 235, 216);
final Color color_font = Color.fromARGB(255, 69, 65, 129);
final Color color_white = Color.fromARGB(255, 255, 255, 255);
final Color color_white2 = Color.fromARGB(255, 250, 250, 250);
final Color color_cancelar = Color.fromARGB(255, 244, 63, 63);
final Color color_black = Color.fromARGB(255, 0, 0, 0);
final Color color_effects = Colors.black.withOpacity(0.3);
final Color color_green = Colors.green;

class EditarProductoIn extends StatefulWidget {
  const EditarProductoIn({Key? key}) : super(key: key);

  @override
  State<EditarProductoIn> createState() => _EditarProductoInState();
}

class _EditarProductoInState extends State<EditarProductoIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _minimoController = TextEditingController();
  bool _isSubmitting = false;
  bool cargando = false;
  List<Map<String, dynamic>> unidadesActivas = [];
  List<Map<String, dynamic>> medidasActivas = [];
  int? _selectedUnidad;
  int? _selectedMedida;
  late int pkProductoin;

  @override
  void initState() {
    super.initState();
    pkProductoin = Get.arguments[
        'pk_productoin']; // Obtener la pk_productoin desde argumentos
    traerUnidades();
    traerMedidas();
    _cargarProducto(); // Cargar los datos actuales del producto
  }

  Future<void> traerUnidades() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('unidad')
          .select()
          .eq('estatus', 1)
          .order('pk_unidad', ascending: true);

      unidadesActivas = List<Map<String, dynamic>>.from(response).map((unidad) {
        return {
          'pk_unidad': unidad['pk_unidad'],
          'nom_unidad': unidad['nom_unidad'],
        };
      }).toList();
    } catch (e) {
      print('Error al obtener unidades: $e');
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> traerMedidas() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('medida')
          .select()
          .eq('estatus', 1)
          .order('pk_medida', ascending: true);

      medidasActivas = List<Map<String, dynamic>>.from(response).map((medida) {
        return {
          'pk_medida': medida['pk_medida'],
          'nom_medida': medida['nom_medida'],
        };
      }).toList();
    } catch (e) {
      print('Error al obtener medidas: $e');
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> _cargarProducto() async {
    try {
      final response = await Supabase.instance.client
          .from('productoin')
          .select(
              'nom_productoin, descripcion, cantidad, minimo, fk_unidad, fk_medida')
          .eq('pk_productoin', pkProductoin)
          .single();

      setState(() {
        _nombreController.text = response['nom_productoin'] ?? '';
        _descripcionController.text = response['descripcion'] ?? '';
        _cantidadController.text = response['cantidad'].toString();
        _minimoController.text = response['minimo'].toString();
        _selectedUnidad = response['fk_unidad'];
        _selectedMedida = response['fk_medida'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el producto: $e')),
      );
    }
  }

  Future<void> _editarProducto() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await Supabase.instance.client.from('productoin').update({
          'nom_productoin': _nombreController.text,
          'descripcion': _descripcionController.text,
          'fk_unidad': _selectedUnidad,
          'cantidad': int.parse(_cantidadController.text),
          'fk_medida': _selectedMedida,
          'minimo': int.parse(_minimoController.text),
          'estatus': 1,
        }).eq('pk_productoin', pkProductoin);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado exitosamente')),
        );

        Get.offNamed('/inventario', arguments: {'updated': true});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el producto: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    _minimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,

/* ----------------------------------------------- AppBar ----------------------------------------------- */
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Editar Producto en Inventario',
          colorsito: color_bg,
        ),
      ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: 600), // Ancho máximo para responsividad
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color_white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del Producto
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Producto',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
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

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Unidad
                    DropdownButtonFormField<int>(
                      value: _selectedUnidad,
                      onChanged: (value) {
                        setState(() {
                          _selectedUnidad = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Unidad',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      items: unidadesActivas.map((unidad) {
                        return DropdownMenuItem<int>(
                          value: unidad['pk_unidad'],
                          child: Text(unidad['nom_unidad']),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, seleccione una unidad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Cantidad
                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese la cantidad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Medida
                    DropdownButtonFormField<int>(
                      value: _selectedMedida,
                      onChanged: (value) {
                        setState(() {
                          _selectedMedida = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Medida',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      items: medidasActivas.map((medida) {
                        return DropdownMenuItem<int>(
                          value: medida['pk_medida'],
                          child: Text(medida['nom_medida']),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, seleccione una medida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mínimo
                    TextFormField(
                      controller: _minimoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Mínimo',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el valor mínimo';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Botón de Actualizar
                    Center(
                      child: _isSubmitting
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _editarProducto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color_font,
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 32.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Actualizar Producto',
                                style: TextStyle(
                                  color: color_white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
