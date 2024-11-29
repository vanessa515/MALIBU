import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';

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
    pkProductoin = Get.arguments['pk_productoin']; // Obtener la pk_productoin desde argumentos
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
          .select('nom_productoin, descripcion, cantidad, minimo, fk_unidad, fk_medida')
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
        await Supabase.instance.client
            .from('productoin')
            .update({
              'nom_productoin': _nombreController.text,
              'descripcion': _descripcionController.text,
              'fk_unidad': _selectedUnidad,
              'cantidad': int.parse(_cantidadController.text),
              'fk_medida': _selectedMedida,
              'minimo': int.parse(_minimoController.text),
              'estatus': 1,
            })
            .eq('pk_productoin', pkProductoin);

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
      appBar: CustomAppbar(
        titulo: 'EDITAR PRODUCTO',
        colorsito: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  controller: _descripcionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
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
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _editarProducto,
                        child: Text('Actualizar Producto'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
