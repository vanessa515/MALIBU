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
  List<Map<String, dynamic>> _categorias = []; // Lista para almacenar las categorías
  int? _selectedCategoriaId;
  List<dynamic> _toppings = [];
  List<dynamic> _toppings2 = [];
  List<int> _selectedToppings = [];
  List<int> _selectedToppings2 = [];
  List<int> _cantidad = [];

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
    _fetchProductos();
    _fetchToppings();
    _fetchToppings2();
  }

  // Método para obtener categorías de la tabla 'categoria'
  Future<void> _fetchCategorias() async {
    try {
      final response = await Supabase.instance.client.from("categoria").select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _categorias = List<Map<String, dynamic>>.from(response);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron categorías')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Método para obtener productos, con filtrado por categoría
  Future<void> _fetchProductos([int? categoriaId]) async {
    try {
      var query = Supabase.instance.client.from("producto").select();

      if (categoriaId != null) {
        query = query.eq('fk_categoria', categoriaId);
      }

      final response = await query;

      if (response != null && response.isNotEmpty) {
        final productosFiltrados = response.where((producto) {
          return producto['nombre'] != null && producto['precio'] != null && producto['foto'] != null;
        }).toList();

        setState(() {
          _productos = productosFiltrados;
          _cantidad = List.generate(productosFiltrados.length, (_) => 1);
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
////////////////////////////////
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
    double totalVenta = 0.0;
    int? pkVenta;

    // Calcular el precio del producto
    var producto = _productos.firstWhere((p) => p['pk_producto'] == fkProducto);
    double precioProducto = producto['precio'];

    // Calcular el precio de los toppings
    double precioToppings = _calculateToppingPrice(toppingIds) + _calculateToppingPrice(toppingIds2);

    // Registro de toppings y venta
    for (var toppingId in toppingIds) {
      for (var toppingId2 in toppingIds2) {
        // Registrar producto con toppings en la tabla 'producto_topping'
        final insertedData = await Supabase.instance.client.from('producto_topping').insert({
          'fk_producto': fkProducto,
          'fk_topping': toppingId,
          'fk_topping2': toppingId2, // Agregar el fk_topping2 aquí
        }).select('pk_producto_topping').single();

        if (insertedData != null && insertedData['pk_producto_topping'] != null) {
          productoToppingIds.add(insertedData['pk_producto_topping']);
        }

        // Registrar la venta si aún no ha sido registrada
        if (pkVenta == null && insertedData != null) {
          // Registrar la venta con la cantidad total
          pkVenta = await _registerSale(cantidad, insertedData['pk_producto_topping']);
        }
      }
    }

    // Calcular el total de la venta (producto + toppings)
    totalVenta = (precioProducto + precioToppings) * cantidad;

    if (pkVenta != null) {
      // Registrar el detalle de la venta con el total calculado
      await _registerSaleDetail(pkVenta, totalVenta);
    } else {
      throw Exception('No se pudo registrar la venta');
    }

    // Resetear estado en la UI
    setState(() {
      _cantidad[_productos.indexWhere((producto) => producto['pk_producto'] == fkProducto)] = 0;
      _selectedToppings.clear();
      _selectedToppings2.clear(); // Limpiar selección de toppings2
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto y toppings registrados exitosamente')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar: $e')),
    );
  }
}

// Función para registrar la venta y retornar 'pk_venta'
Future<int?> _registerSale(int cantidad, int fkProductoTopping) async {
  try {
    // Insertamos una sola venta con la cantidad total
    final insertedData = await Supabase.instance.client
        .from('venta')
        .insert({
          'cantidad': cantidad, // Cantidad total
          'fk_producto_topping': fkProductoTopping,
        })
        .select('pk_venta')
        .single();

    final pkVenta = insertedData?['pk_venta'];

    if (pkVenta == null) {
      throw Exception('Error al obtener el ID de la venta');
    }

    return pkVenta; // Retornamos el 'pk_venta'
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar la venta: $e')),
    );
    return null; // Retornamos null en caso de error
  }
}

///////////////////////////
// Función para registrar el detalle de la venta
Future<void> _registerSaleDetail(int pkVenta, double totalVenta) async {
  try {
    await Supabase.instance.client.from('detalle_venta').insert({
      'fecha': DateTime.now().toIso8601String(),
      'total_venta': totalVenta,
      'fk_venta': pkVenta,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar el detalle de la venta: $e')),
    );
  }
}



/////////////////////////
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
                            const Text('Toppings extra"', style: TextStyle(fontSize: 16)),
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
          // Verifica que se carguen las categorías antes de mostrar el DropdownButton
          if (_categorias.isNotEmpty) 
            DropdownButton<int>(
              hint: const Text('Selecciona una categoría'),
              value: _selectedCategoriaId,
              items: [
                DropdownMenuItem<int>(
                  value: null, // Valor especial para "Todos"
                  child: const Text('Todos'),
                ),
                ..._categorias.map<DropdownMenuItem<int>>((categoria) {
                  return DropdownMenuItem<int>(
                    value: categoria['pk_categoria'], // Clave primaria de la categoría
                    child: Text(categoria['nombre_cat']), // Nombre de la categoría
                  );
                }).toList(),
              ],
              onChanged: (int? value) {
                setState(() {
                  _selectedCategoriaId = value;
                  _fetchProductos(value); // Filtrar productos por categoría o mostrar todos
                });
              },
            ),

          if (_categorias.isEmpty) // Mostrar un mensaje si no hay categorías
            const Text('No hay categorías disponibles'),
          
          Expanded(
            child: ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                double precioTotal = producto['precio'] * _cantidad[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(producto['nombre'] ?? 'Producto sin nombre'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Precio unitario: \$${producto['precio']?.toStringAsFixed(2) ?? '0.00'}'),
                        Text('Precio total: \$${precioTotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            ElevatedButton(
                              onPressed: () => _showToppingsSheet(index),
                              child: const Text('Seleccionar Toppings'),
                            ),
                          ],
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

class TicketVentaScreen extends StatefulWidget {
  @override
  _TicketVentaScreenState createState() => _TicketVentaScreenState();
}

class _TicketVentaScreenState extends State<TicketVentaScreen> {
  List<dynamic> _ticketData = [];

  @override
  void initState() {
    super.initState();
    _fetchTicketData(); // obtener los datos de los tickets
  }

  Future<void> _fetchTicketData() async {
    try {
      final response = await Supabase.instance.client.rpc('obtener_tickets');
      print('Full Response: $response');

      if (response is List) {
        print('Response is a list with ${response.length} items.');
        setState(() {
          _ticketData = response;
        });
      } else {
        print('Los datos no son una lista. Tipo recibido: ${response.runtimeType}');
      }
    } catch (e) {
      print('Caught error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _imprimirTicket() {
    // Si los videos de youtube no se equivocan aqui va la logica de impresion
    print('Botón de imprimir ticket presionado');
  }

  @override
  Widget build(BuildContext context) {
    print('Longitud de _ticketData: ${_ticketData.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets'),
        backgroundColor: Colors.teal,
      ),
      body: _ticketData.isEmpty
          ? Center(child: Text('No hay datos de ventas.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _ticketData.length,
                    itemBuilder: (context, index) {
                      final producto = _ticketData[index];

                      // Impresión 
                      print('Producto $index: $producto');

                     
                      final nombreProducto = producto['producto_nombre'] ?? 'Nombre no disponible';
                      final precioProducto = producto['producto_precio'] ?? 0;
                      final cantidad = producto['cantidad_producto'] ?? 0;
                      final totalVenta = producto['total_venta'] ?? 0;
                      final fecha = producto['fecha'] ?? 'Fecha no disponible';

                      final toppingNombre = producto['topping_nombre'] ?? 'Sin topping';
                      final toppingPrecio = producto['topping_precio'] ?? 0;
                      final topping2Nombre = producto['topping2_nombre'] ?? 'Sin topping';
                      final topping2Precio = producto['topping2_precio'] ?? 0;

                      return Card(
                        child: ListTile(
                          title: Text('$nombreProducto'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio Producto: \$${precioProducto.toStringAsFixed(2)}'),
                              Text('Topping 1: $toppingNombre (\$${toppingPrecio.toStringAsFixed(2)})'),
                              Text('Topping 2: $topping2Nombre (\$${topping2Precio.toStringAsFixed(2)})'),
                               Text('Cantidad: $cantidad'),
                              Text('Fecha: $fecha'),
                              Text('Total Venta: \$${totalVenta.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _imprimirTicket,
                  child: Text('Imprimir Ticket'),
                ),
              ],
            ),
    );
  }
}