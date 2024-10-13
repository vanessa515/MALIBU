import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      //Columna 2
                      DataColumn(
                        label: Text(
                          'Existencia',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      //Columna 3
                      DataColumn(
                        label: Text(
                          'Minimo',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      //Columna 4
                      DataColumn(
                        label: Text(
                          'Proveedor',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),

                      //Columna 5
                      DataColumn(
                        label: Text(
                          'Ordenar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],

                    // Filas vacías
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
