import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _ListaProductosState();
}

class _ListaProductosState extends State<Home> {
  List<dynamic> _productos = [];
  List<dynamic> _toppings = [];
  List<dynamic> _toppings2 = []; // Agregamos la segunda lista de toppings
  List<int> _selectedToppings = [];
  List<int> _selectedToppings2 = []; // Agregamos la lista para toppings2
  List<int> _cantidad = [];

  @override
  void initState() {
    super.initState();
    _fetchProductos();
    _fetchToppings();
    _fetchToppings2(); // Cargar la segunda tabla de toppings
  }

  Future<void> _fetchProductos() async {
    try {
      final response = await Supabase.instance.client.from("producto").select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _productos = response;
          _cantidad = List.generate(response.length, (_) => 1);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron productos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _fetchToppings() async {
    try {
      final response = await Supabase.instance.client.from("topping").select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _toppings = response;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron toppings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _fetchToppings2() async { // Método para cargar toppings2
    try {
      final response = await Supabase.instance.client.from("topping2").select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _toppings2 = response;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron toppings2')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getImageUrl(String? imageName) {
    if (imageName == null) return '';

    return Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(imageName);
  }

  double _calculateToppingPrice(List<int> selectedToppingIds) {
    double toppingTotal = 0.0;
    for (var toppingId in selectedToppingIds) {
      var topping = _toppings.firstWhere((t) => t['pk_topping'] == toppingId);
      toppingTotal += topping['precio'] ?? 0.0;
    }
    return toppingTotal;
  }

Future<void> _registerProductWithToppings(
  int fkProducto, 
  List<int> toppingIds, 
  List<int> toppingIds2, 
  int cantidad
) async {
  try {
    if (toppingIds.isEmpty && toppingIds2.isEmpty) {
      toppingIds.add(0); // Si no hay toppings, se asigna "sin topping"
    }

    List<int> productoToppingIds = [];
    
    // Registro de ambos toppings
    for (var i = 0; i < cantidad; i++) {
      for (var toppingId in toppingIds) {
        for (var toppingId2 in toppingIds2) {
          final response = await Supabase.instance.client.from('producto_topping').insert({
            'fk_producto': fkProducto,
            'fk_topping': toppingId,
            'fk_topping2': toppingId2, // Agregar el fk_topping2 aquí
          }).select('pk_producto_topping').single();

          if (response != null && response['pk_producto_topping'] != null) {
            productoToppingIds.add(response['pk_producto_topping']);
          }

          // Aquí registramos cada venta individualmente
          await _registerSale(1, response['pk_producto_topping']); // Registramos 1 unidad por cada producto
        }
      }
    }
  setState(() {
      _cantidad[_productos.indexWhere((producto) => producto['pk_producto'] == fkProducto)] = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto y toppings registrados exitosamente')),
    );

    setState(() {
      _selectedToppings.clear();
      _selectedToppings2.clear(); // Limpiar selección de toppings2
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar: $e')),
    );
  }
}

Future<void> _registerSale(int cantidad, int productoToppingId) async {
  try {
    await Supabase.instance.client.from('venta').insert({
      'cantidad': cantidad,
      'fk_producto_topping': productoToppingId,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar la venta: $e')),
    );
  }
}

void _showToppingsSheet(int index) {
  List<int> selectedToppingsLocal = [];
  List<int> selectedToppingsLocal2 = []; // Para los toppings de topping2
  bool sinToppingsSelected = false;
  bool sinToppings2Selected = false; // Para topping2
  int? selectedTopping; // Variable para rastrear el topping seleccionado

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateLocal) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecciona los Toppings', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Toppings de la tabla "topping"
                      Expanded(
                        child: ListView(
                          children: [
                            const Text('Toppings de la tabla "topping"', style: TextStyle(fontSize: 16)),
                            CheckboxListTile(
                              title: const Text('Sin Toppings'),
                              value: sinToppingsSelected,
                              onChanged: (bool? isChecked) {
                                setStateLocal(() {
                                  sinToppingsSelected = isChecked ?? false;
                                  if (sinToppingsSelected) {
                                    selectedToppingsLocal.clear();
                                  }
                                  selectedTopping = null; // Restablece el topping seleccionado
                                });
                              },
                            ),
                            ..._toppings.where((topping) => topping['pk_topping'] != 0).map((topping) {
                              return CheckboxListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(topping['nombre']),
                                    Text('\$${topping['precio'].toStringAsFixed(2)}'),
                                  ],
                                ),
                                value: selectedTopping == topping['pk_topping'],
                                onChanged: sinToppingsSelected || selectedTopping != null ? null : (bool? isChecked) {
                                  setStateLocal(() {
                                    selectedTopping = isChecked == true ? topping['pk_topping'] : null;
                                    selectedToppingsLocal.clear();
                                    if (isChecked == true) {
                                      selectedToppingsLocal.add(topping['pk_topping']);
                                    }
                                  });
                                },
                                secondary: topping['imagen'] != null
                                    ? Image.network(
                                        _getImageUrl(topping['imagen']),
                                        width: 50,
                                        height: 50,
                                      )
                                    : null,
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      // Separador entre los toppings
                      const VerticalDivider(thickness: 1, width: 20),

                      // Toppings de la tabla "topping2"
                      Expanded(
                        child: ListView(
                          children: [
                            const Text('Toppings de la tabla "topping2"', style: TextStyle(fontSize: 16)),
                            CheckboxListTile(
                              title: const Text('Sin Toppings'),
                              value: sinToppings2Selected,
                              onChanged: (bool? isChecked) {
                                setStateLocal(() {
                                  sinToppings2Selected = isChecked ?? false;
                                  if (sinToppings2Selected) {
                                    selectedToppingsLocal2.clear();
                                  }
                                });
                              },
                            ),
                            ..._toppings2.where((topping2) => topping2['pk_topping2'] != 0).map((topping2) {
                              return CheckboxListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(topping2['nombre']),
                                    Text('\$${topping2['precio'].toStringAsFixed(2)}'),
                                  ],
                                ),
                                value: sinToppings2Selected ? false : selectedToppingsLocal2.contains(topping2['pk_topping2']),
                                onChanged: sinToppings2Selected ? null : (bool? isChecked) {
                                  setStateLocal(() {
                                    if (isChecked == true) {
                                      selectedToppingsLocal2.add(topping2['pk_topping2']);
                                    } else {
                                      selectedToppingsLocal2.remove(topping2['pk_topping2']);
                                    }
                                  });
                                },
                                secondary: topping2['imagen'] != null
                                    ? Image.network(
                                        _getImageUrl(topping2['imagen']),
                                        width: 50,
                                        height: 50,
                                      )
                                    : null,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (sinToppingsSelected) {
                          selectedToppingsLocal.clear();
                          selectedToppingsLocal.add(0);
                        }
                        if (sinToppings2Selected) {
                          selectedToppingsLocal2.clear();
                          selectedToppingsLocal2.add(0);
                        }
                        _registerProductWithToppings(
                          _productos[index]['pk_producto'],
                          selectedToppingsLocal,
                          selectedToppingsLocal2,
                          _cantidad[index],
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Registrar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'Home',
        colorsito: Colors.teal,
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
         
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  double precioTotal = producto['precio'] * _cantidad[index];
                  double toppingTotal = _calculateToppingPrice(_selectedToppings);
                  double total = precioTotal + toppingTotal;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(producto['nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Precio unitario: \$${producto['precio']}'),
                          Text('Precio total: \$${total.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_cantidad[index] > 1) {
                                      _cantidad[index]--;
                                    }
                                  });
                                },
                              ),
                              Text(_cantidad[index].toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _cantidad[index]++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showToppingsSheet(index),
                            child: const Text('Seleccionar Toppings'),
                          ),
                        ],
                      ),
                      leading: producto['foto'] != null
                          ? Image.network(
                              _getImageUrl(producto['foto']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
