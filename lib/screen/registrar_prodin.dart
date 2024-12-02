import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class RegistroProductoIn extends StatefulWidget {
  const RegistroProductoIn({super.key});

  @override
  State<RegistroProductoIn> createState() => _RegistroProductoInState();
}

class _RegistroProductoInState extends State<RegistroProductoIn> {
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

  @override
  void initState() {
    super.initState();
    traerUnidades();
    traerMedidas();
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

  Future<void> _registrarProducto() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response =
            await Supabase.instance.client.from("productoin").insert({
          'nom_productoin': _nombreController.text,
          'descripcion': _descripcionController.text,
          'stock': 0,
          'fk_unidad': _selectedUnidad,
          'cantidad': int.parse(_cantidadController.text),
          'fk_medida': _selectedMedida,
          'minimo': int.parse(_minimoController.text),
          'estatus': 1,
        }).select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto registrado exitosamente')),
          );
          _nombreController.clear();
          _descripcionController.clear();
          _cantidadController.clear();
          _minimoController.clear();
          setState(() {
            _selectedUnidad = null;
            _selectedMedida = null;
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
          titulo: 'Registro de Producto',
          colorsito: color_bg,
        ),
      ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
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
                    controller: _descripcionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.description,
                        color: color_font,
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
                  DropdownButtonFormField<int>(
                    value: _selectedUnidad,
                    onChanged: (value) {
                      setState(() {
                        _selectedUnidad = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
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
                  TextFormField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.format_list_numbered,
                        color: color_font,
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
                  DropdownButtonFormField<int>(
                    value: _selectedMedida,
                    onChanged: (value) {
                      setState(() {
                        _selectedMedida = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Medida',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
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
                  TextFormField(
                    controller: _minimoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Mínimo',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: color_font),
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money_outlined,
                        color: color_font,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el valor mínimo';
                      }
                      return null;
                    },
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

// Función reutilizable para crear DropdownButtonFormField
/* Widget _buildDropdownField({
  required int? value,
  required String label,
  required List<Map<String, dynamic>> items,
  required IconData icon,
  required void Function(int?) onChanged,
  required String? Function(int?) validator,
}) {
  return DropdownButtonFormField<int>(
    value: value,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      prefixIcon: Icon(icon),
    ),
    items: items.map((item) {
      return DropdownMenuItem<int>(
        value: item['pk_unidad'] ?? item['pk_medida'],
        child: Text(item['nom_unidad'] ?? item['nom_medida']),
      );
    }).toList(),
    validator: validator,
  );
} */
