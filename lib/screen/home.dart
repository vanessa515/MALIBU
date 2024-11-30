import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:malibu/screen/registrar_prod.dart';
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

//Variables de imagenes
String logo_img = "../assets/logos/logo.png";
String logo_rmvbg = "../assets/logos/logo_bgremove.png";
String bg_1 = "../assets/logos/img_bg_3840x2160.jpg";
String bg_2 = "../assets/logos/patron_cuadro-hd.jpeg";
String bg_3 = "../assets/logos/cut_bg.jpg";

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _ListaProductosState();
}

class _ListaProductosState extends State<Home> {
  List<dynamic> _productos = [];
  List<Map<String, dynamic>> _categorias =
      []; // Lista para almacenar las categorías
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
      final response =
          await Supabase.instance.client.from("categoria").select();

      if (response.isNotEmpty) {
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

      if (response.isNotEmpty) {
        final productosFiltrados = response.where((producto) {
          return producto['nombre'] != null &&
              producto['precio'] != null &&
              producto['foto'] != null;
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

  Future<void> _fetchToppings2() async {
    // Método para cargar toppings2
    try {
      final response = await Supabase.instance.client.from("topping2").select();

      if (response.isNotEmpty) {
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

////////////////////////////////// Dentro de tu función _registerProductWithToppings
  Future<void> _registerProductWithToppings(int fkProducto,
      List<int> toppingIds, List<int> toppingIds2, int cantidad) async {
    try {
      if (toppingIds.isEmpty && toppingIds2.isEmpty) {
        toppingIds.add(0); // Si no hay toppings, se asigna "sin topping"
      }

      List<int> productoToppingIds = [];
      double totalVenta = 0.0;
      int? pkVenta;

      // Calcular el precio del producto
      var producto =
          _productos.firstWhere((p) => p['pk_producto'] == fkProducto);
      double precioProducto = producto['precio'];

      // Calcular solo el precio de los toppings de toppingIds2
      double precioToppings =
          _calculateToppingPrice(toppingIds2); // solo se usa toppingIds2 aquí

      // Registro de toppings y venta
      for (var toppingId in toppingIds) {
        for (var toppingId2 in toppingIds2) {
          final insertedData = await Supabase.instance.client
              .from('producto_topping')
              .insert({
                'fk_producto': fkProducto,
                'fk_topping': toppingId,
                'fk_topping2': toppingId2, // Agregar el fk_topping2 aquí
              })
              .select('pk_producto_topping')
              .single();

          if (insertedData['pk_producto_topping'] != null) {
            productoToppingIds.add(insertedData['pk_producto_topping']);
          }

          // Registrar la venta si aún no ha sido registrada
          if (pkVenta == null) {
            pkVenta = await _registerSale(
                cantidad, insertedData['pk_producto_topping']);
          }
        }
      }

      totalVenta = (precioProducto + precioToppings) * cantidad;

      if (pkVenta != null) {
        await _registerSaleDetail(pkVenta, totalVenta);
      } else {
        throw Exception('No se pudo registrar la venta');
      }

      // Resetear estado en la UI
      setState(() {
        _cantidad[_productos.indexWhere(
            (producto) => producto['pk_producto'] == fkProducto)] = 0;
        _selectedToppings.clear();
        _selectedToppings2.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Producto y toppings registrados exitosamente')),
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

      final pkVenta = insertedData['pk_venta'];

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

///////////////////////////// Función para registrar el detalle de la venta
  Future<void> _registerSaleDetail(int pkVenta, double totalVenta) async {
    try {
      await Supabase.instance.client.from('detalle_venta').insert({
        'fecha': DateTime.now().toIso8601String(),
        'total_venta': totalVenta,
        'fk_venta': pkVenta,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al registrar el detalle de la venta: $e')),
      );
    }
  }

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Modal para la seleccion de los toppings

  // logica del modal
  void _showToppingsSheet(int index) {
    List<int> selectedToppingsLocal = [];
    List<int> selectedToppingsLocal2 = []; // Para los toppings de topping2
    bool sinToppingsSelected = false;
    bool sinToppings2Selected = false; // Para topping2
    int? selectedTopping; // Variable para rastrear el topping seleccionado

    // %%%%%%%%%%%%% Diseño de la Vista del Modal de seleccion de los toppings
    showModalBottomSheet(
      context: context,
      backgroundColor: color_white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateLocal) {
            double screenWidth = MediaQuery.of(context).size.width;

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selecciona los Toppings',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: color_font,
                    ),
                  ),

                  //Espaciado 1
                  SizedBox(height: 16),

                  //CheckboxListTile para seleccionar los toppings
                  Expanded(
                    child: screenWidth < 600
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Toppings de la tabla "topping"
                              Expanded(
                                child: ListView(
                                  children: [
                                    Text(
                                      'Toppings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: color_font,
                                      ),
                                    ),
                                    CheckboxListTile(
                                      title: Text(
                                        'Sin Toppings',
                                        style: TextStyle(
                                          color: color_font,
                                          fontSize: 16,
                                        ),
                                      ),
                                      value: sinToppingsSelected,
                                      onChanged: (bool? isChecked) {
                                        setStateLocal(() {
                                          sinToppingsSelected =
                                              isChecked ?? false;
                                          if (sinToppingsSelected) {
                                            selectedToppingsLocal.clear();
                                          }
                                          selectedTopping =
                                              null; // Restablece el topping seleccionado
                                        });
                                      },
                                    ),
                                    ..._toppings
                                        .where((topping) =>
                                            topping['pk_topping'] != 0)
                                        .map((topping) {
                                      return CheckboxListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              topping['nombre'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                          ],
                                        ),
                                        value: selectedTopping ==
                                            topping['pk_topping'],
                                        onChanged: sinToppingsSelected ||
                                                selectedTopping != null
                                            ? null
                                            : (bool? isChecked) {
                                                setStateLocal(() {
                                                  selectedTopping = isChecked ==
                                                          true
                                                      ? topping['pk_topping']
                                                      : null;
                                                  selectedToppingsLocal.clear();
                                                  if (isChecked == true) {
                                                    selectedToppingsLocal.add(
                                                        topping['pk_topping']);
                                                  }
                                                });
                                              },
                                        hoverColor: color_font,
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
                              VerticalDivider(
                                thickness: 1,
                                width: 20,
                                color: color_white,
                              ),

                              // Toppings de la tabla "topping2"
                              Expanded(
                                child: ListView(
                                  children: [
                                    Text(
                                      'Toppings extra"',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: color_font,
                                      ),
                                    ),
                                    CheckboxListTile(
                                      title: Text(
                                        'Sin Toppings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: color_font,
                                        ),
                                      ),
                                      value: sinToppings2Selected,
                                      onChanged: (bool? isChecked) {
                                        setStateLocal(() {
                                          sinToppings2Selected =
                                              isChecked ?? false;
                                          if (sinToppings2Selected) {
                                            selectedToppingsLocal2.clear();
                                          }
                                        });
                                      },
                                    ),
                                    ..._toppings2
                                        .where((topping2) =>
                                            topping2['pk_topping2'] != 0)
                                        .map((topping2) {
                                      return CheckboxListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              topping2['nombre'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                            Text(
                                              '\$${topping2['precio'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                          ],
                                        ),
                                        value: sinToppings2Selected
                                            ? false
                                            : selectedToppingsLocal2.contains(
                                                topping2['pk_topping2']),
                                        onChanged: sinToppings2Selected
                                            ? null
                                            : (bool? isChecked) {
                                                setStateLocal(() {
                                                  if (isChecked == true) {
                                                    selectedToppingsLocal2.add(
                                                        topping2[
                                                            'pk_topping2']);
                                                  } else {
                                                    selectedToppingsLocal2
                                                        .remove(topping2[
                                                            'pk_topping2']);
                                                  }
                                                });
                                              },
                                        hoverColor: color_font,
                                        secondary: topping2['imagen'] != null
                                            ? Image.network(
                                                _getImageUrl(
                                                    topping2['imagen']),
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
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Toppings de la tabla "topping"
                              Expanded(
                                child: ListView(
                                  children: [
                                    Text(
                                      'Toppings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: color_font,
                                      ),
                                    ),
                                    CheckboxListTile(
                                      title: Text(
                                        'Sin Toppings',
                                        style: TextStyle(
                                          color: color_font,
                                          fontSize: 16,
                                        ),
                                      ),
                                      value: sinToppingsSelected,
                                      onChanged: (bool? isChecked) {
                                        setStateLocal(() {
                                          sinToppingsSelected =
                                              isChecked ?? false;
                                          if (sinToppingsSelected) {
                                            selectedToppingsLocal.clear();
                                          }
                                          selectedTopping =
                                              null; // Restablece el topping seleccionado
                                        });
                                      },
                                    ),
                                    ..._toppings
                                        .where((topping) =>
                                            topping['pk_topping'] != 0)
                                        .map((topping) {
                                      return CheckboxListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              topping['nombre'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                          ],
                                        ),
                                        value: selectedTopping ==
                                            topping['pk_topping'],
                                        onChanged: sinToppingsSelected ||
                                                selectedTopping != null
                                            ? null
                                            : (bool? isChecked) {
                                                setStateLocal(() {
                                                  selectedTopping = isChecked ==
                                                          true
                                                      ? topping['pk_topping']
                                                      : null;
                                                  selectedToppingsLocal.clear();
                                                  if (isChecked == true) {
                                                    selectedToppingsLocal.add(
                                                        topping['pk_topping']);
                                                  }
                                                });
                                              },
                                        hoverColor: color_font,
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
                              VerticalDivider(
                                thickness: 1,
                                width: 20,
                                color: color_white,
                              ),

                              // Toppings de la tabla "topping2"
                              Expanded(
                                child: ListView(
                                  children: [
                                    Text(
                                      'Toppings extra"',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: color_font,
                                      ),
                                    ),
                                    CheckboxListTile(
                                      title: Text(
                                        'Sin Toppings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: color_font,
                                        ),
                                      ),
                                      value: sinToppings2Selected,
                                      onChanged: (bool? isChecked) {
                                        setStateLocal(() {
                                          sinToppings2Selected =
                                              isChecked ?? false;
                                          if (sinToppings2Selected) {
                                            selectedToppingsLocal2.clear();
                                          }
                                        });
                                      },
                                    ),
                                    ..._toppings2
                                        .where((topping2) =>
                                            topping2['pk_topping2'] != 0)
                                        .map((topping2) {
                                      return CheckboxListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              topping2['nombre'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                            Text(
                                              '\$${topping2['precio'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: color_font,
                                              ),
                                            ),
                                          ],
                                        ),
                                        value: sinToppings2Selected
                                            ? false
                                            : selectedToppingsLocal2.contains(
                                                topping2['pk_topping2']),
                                        onChanged: sinToppings2Selected
                                            ? null
                                            : (bool? isChecked) {
                                                setStateLocal(() {
                                                  if (isChecked == true) {
                                                    selectedToppingsLocal2.add(
                                                        topping2[
                                                            'pk_topping2']);
                                                  } else {
                                                    selectedToppingsLocal2
                                                        .remove(topping2[
                                                            'pk_topping2']);
                                                  }
                                                });
                                              },
                                        hoverColor: color_font,
                                        secondary: topping2['imagen'] != null
                                            ? Image.network(
                                                _getImageUrl(
                                                    topping2['imagen']),
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

                        // Diseño del boton Registrar
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            color_font,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            color_white,
                          ),
                          overlayColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.pressed)
                                ? color_white
                                : null,
                          ), // Efecto al presionar
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),

                        child: Text(
                          'Registrar',
                          style: TextStyle(
                            color: color_white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Boton de cancelar
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            color_font,
                          ), // Fondo del botón
                          foregroundColor: WidgetStatePropertyAll(
                            color_white,
                          ), // Color del texto
                          overlayColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.pressed)
                                ? color_white
                                : null,
                          ), // Efecto al presionar
                          padding: WidgetStatePropertyAll(
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: color_white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Diseño de la vista home

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: color_bg2,
      
      // Cabecera de la appBar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Ventas',
          colorsito: color_bg,
        ),
      ),

      // Menu lateral
      drawer: CustomDrawer(),

      // Contenido central
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verifica que se carguen las categorías antes de mostrar el DropdownButton (Selector de tipo de bebida)
                if (_categorias.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: color_white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color_font,
                        width: 1,
                      ),
                    ),

                    // %%%%%%%%%%%%%%%%%%%%%%%%%%%% Cuerpo del selector
                    child: DropdownButton<int>(
                      hint: Text(
                        'Selecciona una categoría',
                        style: TextStyle(
                          color: color_white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // %%%%%%%%%%%%%%%%%%%%%%%%% Atributos de selector
                      borderRadius: BorderRadius.circular(5),
                      dropdownColor: color_white,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: color_font,
                      ),

                      underline: SizedBox(),
                      value: _selectedCategoriaId,

                      items: [
                        DropdownMenuItem<int>(
                          value: null, // Valor especial para "Todos"
                          child: Text(
                            'Todos',
                            style: TextStyle(
                              color: color_font,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ..._categorias.map<DropdownMenuItem<int>>((categoria) {
                          return DropdownMenuItem<int>(
                            value: categoria[
                                'pk_categoria'], // Clave primaria de la categoría
                            child: Text(
                              categoria['nombre_cat'], // Nombre de la categoría
                              style: TextStyle(
                                color: color_font,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (int? value) {
                        setState(
                          () {
                            _selectedCategoriaId = value;
                            _fetchProductos(
                              value,
                            ); // Filtrar productos por categoría o mostrar todos
                          },
                        );
                      },
                    ),
                  ),

                // %%%%%%%%%%%%%%%%%%%%%%%%%%%% Mensaje en caso de que el selector este vacio
                if (_categorias
                    .isEmpty) // Mostrar un mensaje si no hay categorías
                  Text(
                    'No hay categorías disponibles',
                    style: TextStyle(
                      color: color_black,
                    ),
                  ),

                // %%%%%%%%%%%%%%%%%%%%%%%% Aqui empieza el diseño de las cards
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(15),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300, // Numero de columnas
                      crossAxisSpacing: 8, // Espacio horizontal entre cards
                      mainAxisSpacing: 8, // Espacio vertical entre cards
                      childAspectRatio: 0.680, // ajusta el aspecto de las cards
                    ),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];
                      double precioTotal =
                          producto['precio'] * _cantidad[index];

                      return Card(
                        color: color_white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: color_font,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double fontSizeTitle =
                                  constraints.maxWidth * 0.08;
                              double fontSizeSubTitle =
                                  constraints.maxWidth * 0.06;
                              double iconSize = constraints.maxWidth * 0.13;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  producto['foto'] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15),
                                          ),
                                          child: Image.network(
                                            _getImageUrl(producto['foto']),
                                            width: double.infinity,
                                            height: constraints.maxHeight *
                                                0.502, //La altura de la imagen se escala dependiendo del tamaño de la card
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.image,
                                          color: color_font,
                                          size: constraints.maxWidth *
                                              0.7, //Escala el tamaño del icono
                                        ),

                                  SizedBox(
                                    height: constraints.maxHeight * 0.02,
                                  ),

                                  Text(
                                    producto['nombre'] ?? 'Producto sin nombre',
                                    style: TextStyle(
                                      color: color_font,
                                      fontSize: fontSizeTitle,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    'Precio unitario: \$${producto['precio']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      color: color_font,
                                      fontSize: fontSizeSubTitle,
                                    ),
                                  ),

                                  Text(
                                    'Precio total: \$${precioTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: color_font,
                                      fontSize: fontSizeSubTitle,
                                    ),
                                  ),

                                  // Espacio dentro de las cards
                                  SizedBox(
                                    height: constraints.maxHeight * 0.02,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          color: color_font,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (_cantidad[index] > 1) {
                                              _cantidad[index]--;
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        _cantidad[index].toString(),
                                        style: TextStyle(
                                          color: color_font,
                                          fontSize: fontSizeSubTitle,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: color_font,
                                          size: iconSize,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _cantidad[index]++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // Botón para seleccionar toppings
                                  ElevatedButton(
                                    onPressed: () => _showToppingsSheet(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color_font,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      'Seleccionar Toppings',
                                      style: TextStyle(
                                        color: color_white,
                                        fontSize: fontSizeSubTitle,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Clases e instancias para la logica de tickets */

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
        print(
            'Los datos no son una lista. Tipo recibido: ${response.runtimeType}');
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

  /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Segundo Scaffold (cuerpo de diseño) */

  @override
  Widget build(BuildContext context) {
    print('Longitud de _ticketData: ${_ticketData.length}');

    return Scaffold(
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Tickets',
          colorsito: color_bg,
        ),
      ),
      body: _ticketData.isEmpty
          ? Center(
              child: Text(
                'No hay datos de ventas.',
                style: TextStyle(fontSize: 18, color: color_grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: _ticketData.length,
                    itemBuilder: (context, index) {
                      final producto = _ticketData[index];
                      final nombreProducto =
                          producto['producto_nombre'] ?? 'Nombre no disponible';
                      final precioProducto = producto['producto_precio'] ?? 0;
                      final cantidad = producto['cantidad_producto'] ?? 0;
                      final totalVenta = producto['total_venta'] ?? 0;
                      final fecha = producto['fecha'] ?? 'Fecha no disponible';
                      final toppingNombre =
                          producto['topping_nombre'] ?? 'Sin topping';
                      final toppingPrecio = producto['topping_precio'] ?? 0;
                      final topping2Nombre =
                          producto['topping2_nombre'] ?? 'Sin topping';
                      final topping2Precio = producto['topping2_precio'] ?? 0;

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreProducto,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Precio: \$${precioProducto.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Cantidad: $cantidad',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Topping 1: $toppingNombre (\$${toppingPrecio.toStringAsFixed(2)})',
                                style:
                                    TextStyle(fontSize: 14, color: color_grey),
                              ),
                              Text(
                                'Topping 2: $topping2Nombre (\$${topping2Precio.toStringAsFixed(2)})',
                                style:
                                    TextStyle(fontSize: 14, color: color_grey),
                              ),
                              Divider(color: color_grey),
                              Text(
                                'Fecha: $fecha',
                                style:
                                    TextStyle(fontSize: 14, color: color_grey),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Total Venta: \$${totalVenta.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color_green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _imprimirTicket,
        label: Text(
          'Imprimir Ticket',
          style: TextStyle(
            color: color_white,
          ),
        ),
        icon: Icon(
          Icons.print,
          color: color_white,
        ),
        backgroundColor: color_font,
      ),
    );
  }
}
