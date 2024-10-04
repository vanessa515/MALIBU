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
  List<int> _selectedToppings = [];
  List<int> _cantidad = [];

  @override
  void initState() {
    super.initState();
    _fetchProductos();
    _fetchToppings();
  }

  Future<void> _fetchProductos() async {
    try {
      final response = await Supabase.instance.client.from("producto").select();

      if (response.isNotEmpty) {
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

      if (response.isNotEmpty) {
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

  String _getImageUrl(String? imageName) {
    if (imageName == null) return '';

    return Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(imageName);
  }

  Future<void> _registerProductWithToppings(int fkProducto, List<int> toppingIds, int cantidad) async {
    try {
      // Si no hay toppings seleccionados, agregar un registro para "Sin Toppings"
      if (toppingIds.isEmpty) {
        toppingIds.add(0); // Cambiar a 0 para indicar sin toppings
      }

      for (var toppingId in toppingIds) {
        for (var i = 0; i < cantidad; i++) {
          await Supabase.instance.client.from('producto_topping').insert({
            'fk_producto': fkProducto,
            'fk_topping': toppingId,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto y toppings registrados exitosamente')),
      );

      setState(() {
        _selectedToppings.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  void _showToppingsSheet(int index) {
    List<int> selectedToppingsLocal = [];
    bool sinToppingsSelected = false; // Estado para controlar la opción "Sin Toppings"

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
                    child: ListView(
                      children: [
                        CheckboxListTile(
                          title: const Text('Sin Toppings'),
                          value: sinToppingsSelected,
                          onChanged: (bool? isChecked) {
                            setStateLocal(() {
                              sinToppingsSelected = isChecked ?? false;
                              // Si se selecciona "Sin Toppings", deselecciona los demás
                              if (sinToppingsSelected) {
                                selectedToppingsLocal.clear(); // Limpiar selección de toppings
                              }
                            });
                          },
                        ),
                        ..._toppings.where((topping) => topping['pk_topping'] != 0).map((topping) {
                          return CheckboxListTile(
                            title: Text(topping['nombre']),
                            value: sinToppingsSelected ? false : selectedToppingsLocal.contains(topping['pk_topping']),
                            onChanged: sinToppingsSelected ? null : (bool? isChecked) {
                              setStateLocal(() {
                                if (isChecked == true) {
                                  selectedToppingsLocal.add(topping['pk_topping']);
                                } else {
                                  selectedToppingsLocal.remove(topping['pk_topping']);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Al registrar, verifica si se seleccionó "Sin Toppings"
                          if (sinToppingsSelected) {
                            selectedToppingsLocal.clear(); // Asegurarse de que esté vacío
                            selectedToppingsLocal.add(0); // Cambiar a 0 para indicar sin toppings
                          }
                          _registerProductWithToppings(
                            _productos[index]['pk_producto'],
                            selectedToppingsLocal, // Pasar lista de toppings seleccionados
                            _cantidad[index],
                          );
                          Navigator.of(context).pop(); // Cerrar la ventana
                        },
                        child: const Text('Registrar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cerrar la ventana sin hacer nada
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
            // Sección para mostrar los productos
            Expanded(
              child: ListView.builder(
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  double precioTotal = producto['precio'] * _cantidad[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(producto['nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Precio unitario: \$${producto['precio']}'),
                          const SizedBox(height: 8),
                          Text('Precio total: \$${precioTotal.toStringAsFixed(2)}'),
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
                            onPressed: () => _showToppingsSheet(index), // Mostrar la hoja de toppings
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
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, size: 50); // Imagen de error
                              },
                            )
                          : const Icon(Icons.image, size: 50),
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
