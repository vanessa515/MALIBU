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
          preferredSize: Size.fromHeight(80),
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
            final isSmallScreen = constraints.maxWidth < 890;
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;

            double buttonWidth = screenWidth * 0.15;
            double buttonHeight = screenHeight * 0.08;
            const double minButtonSize = 50.0;
            const double maxButtonSize = 100.0;

            //Limita el tamaño de los botones
            buttonHeight = buttonHeight.clamp(minButtonSize, maxButtonSize);
            buttonWidth = buttonWidth.clamp(minButtonSize, maxButtonSize);

/* ----------------------------------------------- Grupo de Botones para opciones del inventario ----------------------------------------------- */
            return Column(
              children: [
                // Botones de opciones
                if (isSmallScreen)

                  // --------------------------------- Botones en la parte superior en pantallas pequeñas

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _buildButtons(
                        isSmallScreen,
                        buttonHeight,
                        buttonWidth,
                      ),
                    ),
                  ),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isSmallScreen)
                        // --------------------------- Botones a la izquierda en pantallas grandes
                        Container(
                          width: screenWidth * 0.2,
                          color: color_bg2,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildButtons(
                                isSmallScreen,
                                buttonHeight,
                                buttonWidth,
                              ),
                            ),
                          ),
                        ),

/* ----------------------------------------------- Diseño de la Tabla del Inventario ----------------------------------------------- */
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: EdgeInsets.all(16.0), // Margen externo
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Calcula el tamaño dinámico de las fuentes según el ancho disponible
                                final double screenWidth = constraints.maxWidth;
                                final double fontSize = (screenWidth < 400)
                                    ? 14
                                    : 18; // Tamaño mínimo y estándar
                                final double rowHeight =
                                    (screenWidth < 400) ? 24 : 40;
                                final double columnSpacing =
                                    (screenWidth < 400) ? 8 : 12;

                                return DataTable(
                                  dataRowMinHeight:
                                      rowHeight, // Altura mínima de las filas
                                  headingRowHeight:
                                      rowHeight + 12, // Altura del encabezado
                                  columnSpacing:
                                      columnSpacing, // Espaciado entre columnas
                                  horizontalMargin: 8, // Margen horizontal
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
                                          fontSize: fontSize,
                                          color: color_font,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Existencia',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: color_font,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Mínimo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
                                          color: color_font,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Ordenar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize,
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
                                              setState(
                                                () {
                                                  mostrarModalProducto(
                                                    context,
                                                    producto,
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              producto['nom_productoin'],
                                              style: TextStyle(
                                                color: Colors.pinkAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSize - 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${producto['stock']}',
                                            style: TextStyle(
                                              fontSize: fontSize - 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${producto['minimo']}',
                                            style: TextStyle(
                                              fontSize: fontSize - 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            producto['stock'] >
                                                    producto['minimo']
                                                ? 'Aceptable'
                                                : 'Ordenar',
                                            style: TextStyle(
                                              color: producto['stock'] >
                                                      producto['minimo']
                                                  ? color_green
                                                  : color_cancelar,
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSize - 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
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

  List<Widget> _buildButtons(
    bool isSmallScreen,
    double buttonHeight,
    double buttonWidth,
  ) {
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

    return opciones.map((opcion) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5.0),
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(opcion['ruta']),
          icon: Icon(
            opcion['icono'],
            size: buttonHeight *
                0.4, // Tamaño del icono relativo a la altura del botón
          ),
          label: isSmallScreen
              ? SizedBox.shrink()
              : Text(
                  opcion['texto'],
                  style: TextStyle(
                    fontSize: buttonHeight * 0.25, // Tamaño de fuente relativo
                    color: color_white,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: color_font,
            iconColor: color_white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            minimumSize: Size(buttonWidth, buttonHeight),
          ),
        ),
      );
    }).toList();
  }
}

/* ----------------------------------------------- Card modal flotante de detalle dentro de la tabla ----------------------------------------------- */

void mostrarModalProducto(
    BuildContext context, Map<String, dynamic> productoSeleccionado) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------------------------------- Título del producto
                Text(
                  'Producto: ${productoSeleccionado['nom_productoin']}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 5),

                // ---------------------------------- Existencias
                Text(
                  'Existencia: ${productoSeleccionado['stock']} unidades',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 5),

                // ---------------------------------- Mínimo de existencia
                Text(
                  'Mínimo de existencias: ${productoSeleccionado['minimo']} unidades',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 5),

                // ---------------------------------- Descripción
                Text(
                  'Descripción: ${productoSeleccionado['descripcion']}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 5),

                // ---------------------------------- Medidas y unidades
                Text(
                  'Unidad: ${productoSeleccionado['nom_unidad']} de ${productoSeleccionado['cantidad']} ${productoSeleccionado['nom_medida']}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 30),

                // ---------------------------------- Botones de acción
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    // --------------------------------------------------------- Boton de entradas de prodcutos
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        '/entradain',
                        arguments: {
                          'pk_productoin': productoSeleccionado['pk_productoin']
                        },
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color_font,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: color_green,
                        size: 18,
                      ),
                      label: Text(
                        'Añadir',
                        style: TextStyle(
                          color: color_white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // --------------------------------------------------------- Boton de salidas de prodcutos
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        '/salidain',
                        arguments: {
                          'pk_productoin': productoSeleccionado['pk_productoin']
                        },
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color_font,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(
                        Icons.remove,
                        color: Colors.orange,
                        size: 18,
                      ),
                      label: Text(
                        'Restar',
                        style: TextStyle(
                          color: color_white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // --------------------------------------------------------- Boton de editar prodcutos
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        '/editarproductoin',
                        arguments: {
                          'pk_productoin': productoSeleccionado['pk_productoin']
                        },
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color_font,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(
                        Icons.edit,
                        color: color_bg,
                        size: 18,
                      ),
                      label: Text(
                        'Editar',
                        style: TextStyle(
                          color: color_white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // --------------------------------------------------------- Boton de eliminar productos
                    OutlinedButton.icon(
                      onPressed: () {
                        // Lógica para eliminar el producto
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color_font,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(
                        Icons.delete,
                        color: color_cancelar,
                        size: 18,
                      ),
                      label: Text(
                        'Eliminar',
                        style: TextStyle(
                          color: color_white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // ---------------------------------- Botón para cerrar
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: color_cancelar),
                    iconColor: color_cancelar,
                  ),
                  icon: Icon(
                    Icons.close,
                    color: color_cancelar,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
