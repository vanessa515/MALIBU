import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Inventario extends StatefulWidget {
  Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  bool isCardVisible = false;
  Offset cardPosition = Offset(0, 0);
  bool cargando = false;
  
  List<Map<String, dynamic>> unidadesActivas = [];
  List<Map<String, dynamic>> medidasActivas = [];
  List<Map<String, dynamic>> productoin = [];
  Map<String, dynamic>? productoSeleccionado;

  @override
  void initState() {
    super.initState();
    traerDatos();
    traerUnidades();
    traerMedidas();
    
  }

Future<void> traerDatos() async {
  setState(() {
    cargando = true;
  });

  try {
    final response = await supabase
        .from('productoin')
        .select()
        .eq('estatus', 1)
        .then((data) => data);

    productoin = List<Map<String, dynamic>>.from(response).map((producto) {
      // Encontrar el nombre de la unidad y la medida utilizando los valores de fk
      final unidad = unidadesActivas.firstWhere(
        (unidad) => unidad['pk_unidad'] == producto['fk_unidad'],
        orElse: () => {'nom_unidad': 'Sin unidad'},
      );
      final medida = medidasActivas.firstWhere(
        (medida) => medida['pk_medida'] == producto['fk_medida'],
        orElse: () => {'nom_medida': 'Sin medida'},
      );

      return {
        'pk_productoin': producto['pk_productoin'] ?? 0,
        'nom_productoin': producto['nom_productoin'] ?? 'Sin nombre',
        'stock': producto['stock'] ?? 0,
        'minimo': producto['minimo'] ?? 0,
        'descripcion': producto['descripcion'] ?? 'Sin descripción',
        'nom_unidad': unidad['nom_unidad'],
        'cantidad': producto['cantidad'] ?? 0,
        'nom_medida': medida['nom_medida']
      };
    }).toList();

    // Ordenar la lista alfabéticamente por el nombre del producto
    productoin.sort((a, b) =>
        (a['nom_productoin'] as String).compareTo(b['nom_productoin'] as String));

  } catch (e) {
    print('Error al traer datos: $e');
  } finally {
    setState(() {
      cargando = false;
    });
  }
}



  Future<void> traerUnidades() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await supabase
          .from('unidad')
          .select()
          .eq('estatus', 1)
          .order('pk_unidad', ascending: true)
          .then((data) => data);
        

      unidadesActivas = List<Map<String, dynamic>>.from(response).map((unidad) {
        return {
          'pk_unidad': unidad['pk_unidad'] ?? 0,
          'nom_unidad': unidad['nom_unidad'] ?? 'Sin nombre',
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
      final response = await supabase
          .from('medida')
          .select()
          .eq('estatus', 1)
          .order('pk_medida', ascending: true)
          .then((data) => data);

      medidasActivas = List<Map<String, dynamic>>.from(response).map((medida) {
        return {
          'pk_medida': medida['pk_medida'] ?? 0,
          'nom_medida': medida['nom_medida'] ?? 'Sin nombre',
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

  

 @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCardVisible = false;
        });
      },
      child: Scaffold(
        appBar: CustomAppbar(
          titulo: 'Inventario',
          colorsito: color_1,
        ),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: <DataColumn>[
                            DataColumn(label: Text('Producto')),
                            DataColumn(label: Text('Existencia')),
                            DataColumn(label: Text('Minimo')),
                            DataColumn(label: Text('Ordenar')),
                          ],
                          rows: productoin.map((producto) {
                            return DataRow(
                              cells: [
                                DataCell(TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isCardVisible = true;
                                      productoSeleccionado = producto;
                                    });
                                  },
                                  child: Text(producto['nom_productoin']),
                                )),
                                DataCell(Text('${producto['stock']}')),
                                DataCell(Text('${producto['minimo']}')),
                                DataCell(Text(
                                  producto['stock'] > producto['minimo']
                                      ? 'Aceptable'
                                      : 'Ordenar',
                                  style: TextStyle(
                                    color: producto['stock'] > producto['minimo']
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Botones de navegación
                Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/registrarproductoin');
            },
            child: Text('Agregar producto'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/unidades');
            },
            child: Text('Ver unidades'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/medidas');
            },
            child: Text('Ver medidas'),
          ),
        ],
      ),
      SizedBox(height: 16.0), // Espacio entre las filas
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/verentradas');
            },
            child: Text('Ver entradas'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/versalidas');
            },
            child: Text('Ver salidas'),
          ),
        ],
      ),
    ],
  ),
),
              ],
            ),
            // Tarjeta flotante de detalle
            if (isCardVisible && productoSeleccionado != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: MediaQuery.of(context).size.width * 0.15,
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Producto: ${productoSeleccionado!['nom_productoin']}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Existencia: ${productoSeleccionado!['stock']} unidades',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Minimo de existencias: ${productoSeleccionado!['minimo']} unidades',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Descripción: ${productoSeleccionado!['descripcion']}. Su unidad de medida es un ${productoSeleccionado!['nom_unidad']} de ${productoSeleccionado!['cantidad']} ${productoSeleccionado!['nom_medida']}',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Quedan ${productoSeleccionado!['stock'] * productoSeleccionado!['cantidad']} ${productoSeleccionado!['nom_medida']}.',
                            textAlign: TextAlign.center,
                            
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Get.toNamed('/entradain', arguments: {
                                    'pk_productoin':
                                        productoSeleccionado!['pk_productoin'],
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.green),
                                ),
                                child: Text('Añadir'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Get.toNamed('/salidain', arguments: {
                                    'pk_productoin':
                                        productoSeleccionado!['pk_productoin'],
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.orange),
                                ),
                                child: Text('Restar'),
                              ),
                            ],
                          ),
                          // Opciones de edición y baja
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Get.toNamed('/editarproductoin',
                                      arguments: {'pk_productoin': productoSeleccionado!['pk_productoin']});
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue),
                                ),
                                child: Text('Editar'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  // Lógica para eliminar el producto
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red),
                                ),
                                child: Text('Dar de baja'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}