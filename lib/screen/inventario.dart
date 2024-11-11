import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';

class Inventario extends StatefulWidget {
  Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  // Variables de diseño (colores)

  /* el color aqui en ARGB(alpha, red, green, blue)  */
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  Color color_2 = Color.fromARGB(255, 69, 65, 129);
  Color color_3 = Color.fromARGB(255, 0, 0, 0);

  // Imágenes y rutas
/*final String bg_img = '../assets/img/bg.jpg';
  final String bg_img2 = '../assets/img/bg_registrer.jpg'; */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Encabezado
      appBar: CustomAppbar(
        titulo: 'Inventario',
        colorsito: color_1,
      ),

      // Menú lateral
      drawer: CustomDrawer(),

      body: Column(
        children: [
          // Título de la tabla
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Inventario',
              style: TextStyle(
                fontSize: 40, // Tamaño de fuente
                fontWeight: FontWeight.bold,
                color: color_2,
              ),
            ),
          ),

          // Tabla de datos
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    // Encabezados de la tabla
                    columns: <DataColumn>[
                      //Columna 1
                      DataColumn(
                        label: Text(
                          'Articulos',
                          style: TextStyle(
                            color: color_3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      //Columna 2
                      DataColumn(
                        label: Text(
                          'Existencia',
                          style: TextStyle(
                            color: color_3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      //Columna 3
                      DataColumn(
                        label: Text(
                          'Minimo',
                          style: TextStyle(
                            color: color_3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      //Columna 4
                      DataColumn(
                        label: Text(
                          'Proveedor',
                          style: TextStyle(
                            color: color_3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      //Columna 5
                      DataColumn(
                        label: Text(
                          'Ordenar',
                          style: TextStyle(
                            color: color_3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // Filas de la tabla - Esta tabla no es dinamica aun, falta la programacion de la misma
                    rows: List<DataRow>.generate(
                      5, // Cambia el número para más o menos filas
                      (index) => DataRow(
                        cells: const [
                          DataCell(Text('dato 1')),
                          DataCell(Text('dato 2')),
                          DataCell(Text('dato 3')),
                          DataCell(Text('dato 4')),
                          DataCell(Text('dato 5')),
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
    );
  }
}
