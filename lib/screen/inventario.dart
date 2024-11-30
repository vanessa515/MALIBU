import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class Inventario extends StatefulWidget {
  Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
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
      productoin.sort((a, b) => (a['nom_productoin'] as String)
          .compareTo(b['nom_productoin'] as String));
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
        backgroundColor: color_bg2,

/* ----------------------------------------------- AppBar ----------------------------------------------- */
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: CustomAppbar(
            titulo: 'Inventario',
            colorsito: color_bg,
          ),
        ),

/* ----------------------------------------------- Drawer ----------------------------------------------- */
        drawer: CustomDrawer(),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 750;
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;

            /* double spaceButtonWidth = screenWidth * 0.40; */
            double spaceButtonHeight = screenHeight * 0.25;

            double maxButtonSize = 25.0; // Tamaño máximo para los botones
            spaceButtonHeight = spaceButtonHeight < maxButtonSize
                ? spaceButtonHeight
                : maxButtonSize; // Limita el tamaño máximo

/* ----------------------------------------------- Grupo de Botones para opciones del inventario ----------------------------------------------- */
            return Column(
              children: [
                // Botones de opciones
                if (isSmallScreen)
                  // --------------------------------- Botones en la parte superior en pantallas pequeñas
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(vertical: spaceButtonHeight),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 2,
                      runSpacing: 2,
                      children: _buildButtons(isSmallScreen)
                          .map(
                            (boton) => Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spaceButtonHeight,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.11,
                                height:
                                    MediaQuery.of(context).size.height * 0.055,
                                child: boton,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isSmallScreen)
                        // --------------------------- Botones a la izquierda en pantallas grandes
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          width: MediaQuery.of(context).size.width * 0.2,
                          color: color_bg2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildButtons(isSmallScreen),
                          ),
                        ),

/* ----------------------------------------------- Diseño de la Tabla del Inventario ----------------------------------------------- */
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          // Centramos la tabla en la pantalla
                          child: Padding(
                            padding: EdgeInsets.all(
                                16.0), // Añadimos un margen para alejar la tabla de los bordes
                            child: DataTable(
                              dataRowMinHeight:
                                  30, // Aumentamos la altura de las filas para que se vea más espacioso
                              headingRowHeight:
                                  56, // Mejoramos el tamaño de la fila de encabezado
                              columnSpacing:
                                  10, // Aumentamos el espacio entre las columnas para más claridad
                              horizontalMargin:
                                  10, // Margen horizontal para no pegarse a los bordes
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: color_white2,
                                boxShadow: [
                                  BoxShadow(
                                    color: color_effects,
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    'Producto',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: color_font,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Existencia',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: color_font,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Mínimo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: color_font,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Ordenar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: color_font,
                                    ),
                                  ),
                                ),
                              ],
                              rows: productoin.map((producto) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isCardVisible = true;
                                            productoSeleccionado = producto;
                                          });
                                        },
                                        child: Text(
                                          producto['nom_productoin'],
                                          style: TextStyle(
                                            color: Colors.pinkAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${producto['stock']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${producto['minimo']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        producto['stock'] > producto['minimo']
                                            ? 'Aceptable'
                                            : 'Ordenar',
                                        style: TextStyle(
                                          color: producto['stock'] >
                                                  producto['minimo']
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

/* ----------------------------------------------- Card modal flotante de detalle dentro de la tabla ----------------------------------------------- */
                      if (isCardVisible && productoSeleccionado != null)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isCardVisible = false;
                              });
                            },
                            child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Producto: ${productoSeleccionado!['nom_productoin']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                            'Existencia: ${productoSeleccionado!['stock']} unidades'),
                                        const SizedBox(height: 10),
                                        Text(
                                            'Minimo de existencias: ${productoSeleccionado!['minimo']} unidades'),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Descripción: ${productoSeleccionado!['descripcion']}. '
                                          'Unidad: ${productoSeleccionado!['nom_unidad']} de ${productoSeleccionado!['cantidad']} ${productoSeleccionado!['nom_medida']}',
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => Get.toNamed(
                                                '/entradain',
                                                arguments: {
                                                  'pk_productoin':
                                                      productoSeleccionado![
                                                          'pk_productoin'],
                                                },
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.green),
                                              ),
                                              child: const Text('Añadir'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => Get.toNamed(
                                                '/salidain',
                                                arguments: {
                                                  'pk_productoin':
                                                      productoSeleccionado![
                                                          'pk_productoin'],
                                                },
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.orange),
                                              ),
                                              child: const Text('Restar'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildButtons(bool isSmallScreen) {
    final List<Map<String, dynamic>> opciones = [
      {
        'texto': 'Agregar producto',
        'icono': Icons.add,
        'ruta': '/registrarproductoin'
      },
      {'texto': 'Ver unidades', 'icono': Icons.balance, 'ruta': '/unidades'},
      {'texto': 'Ver medidas', 'icono': Icons.straighten, 'ruta': '/medidas'},
      {
        'texto': 'Ver entradas',
        'icono': Icons.file_download,
        'ruta': '/verentradas'
      },
      {
        'texto': 'Ver salidas',
        'icono': Icons.file_upload,
        'ruta': '/versalidas'
      },
    ];

    // Obtén el tamaño de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    // Calcula un tamaño de ícono relativo en función del ancho de la pantalla
    double iconSizeWidth = screenWidth * 0.05; // 7% del ancho de la pantalla

    // Ajusta el tamaño del botón, pero limitando su valor mínimo
    double buttonSize = screenWidth *
        0.2; // 20% del ancho de la pantalla, puedes ajustarlo según tus necesidades
    double maxButtonSize = 100.0; // Tamaño máximo para los botones
    buttonSize = buttonSize < maxButtonSize
        ? buttonSize
        : maxButtonSize; // Limita el tamaño máximo

    // Genera la lista de botones con espaciado condicional
    final List<Widget> botones = [];
    for (var i = 0; i < opciones.length; i++) {
      botones.add(
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(opciones[i]['ruta']),
          icon: isSmallScreen
              ? Icon(opciones[i]['icono'], size: iconSizeWidth)
              : SizedBox.shrink(),
          label: isSmallScreen
              ? SizedBox.shrink()
              : Text(
                  opciones[i]['texto'],
                  style: TextStyle(
                    fontSize: 18,
                    color: color_white,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: color_font,
            iconColor: color_white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            padding: EdgeInsets.symmetric(
              horizontal: buttonSize * 0.05,
              vertical: buttonSize * 0.10,
            ),
            minimumSize: Size(buttonSize, buttonSize),
          ),
        ),
      );
      if (!isSmallScreen && i < opciones.length - 1) {
        // Añade espaciado entre botones, solo en pantallas grandes
        botones.add(SizedBox(height: 30));
      }
    }

    return botones;
  }
}
