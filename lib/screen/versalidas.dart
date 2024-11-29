import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class VerSalidas extends StatefulWidget {
  VerSalidas({super.key});

  @override
  State<VerSalidas> createState() => _VerSalidasState();
}

class _VerSalidasState extends State<VerSalidas> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  bool cargando = false;

  List<Map<String, dynamic>> salidasConComentario = [];
  List<Map<String, dynamic>> salidasSinComentario = [];
  String? fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    traerSalidasRegistradas(fecha: fechaHoy);
  }

  Future<void> traerSalidasRegistradas({String? fecha}) async {
    setState(() {
      cargando = true;
    });

    try {
      var query = supabase.from('salida').select();

      // Filtrar por fecha si se proporciona
      if (fecha != null) {
        query = query.eq('fecha', fecha);
      }

      final response = await query;

      if (response.isEmpty) {
        setState(() {
          salidasConComentario = [];
          salidasSinComentario = [];
        });
        print("No hay salidas en la fecha seleccionada");
        return;
      }

      List<Map<String, dynamic>> tempSalidasConComentario = [];
      List<Map<String, dynamic>> tempSalidasSinComentario = [];

      for (var salida in response) {
        final productResponse = await supabase
            .from('productoin')
            .select('nom_productoin')
            .eq('pk_productoin', salida['fk_productoin'])
            .single();

        Map<String, dynamic> salidaData = {
          'cantidad': salida['cantidad'] ?? 0,
          'nom_productoin': productResponse['nom_productoin'] ?? 'Producto desconocido',
          'estatus': salida['estatus'] == 1 ? 'Activo' : 'Inactivo',
          'comentario': salida['comentario'] ?? '',
          'hora': salida['hora'] ?? 'Hora desconocida',
        };

        if (salida['comentario'] != null && salida['comentario'].isNotEmpty) {
          tempSalidasConComentario.add(salidaData);
        } else {
          tempSalidasSinComentario.add(salidaData);
        }
      }

      setState(() {
        salidasConComentario = tempSalidasConComentario;
        salidasSinComentario = tempSalidasSinComentario;
      });
    } catch (e) {
      print('Error al traer salidas: $e');
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void mostrarCalendario() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        fechaSeleccionada = DateFormat('yyyy-MM-dd').format(picked);
      });
      await traerSalidasRegistradas(fecha: fechaSeleccionada);
    }
  }

//   Future<void> crearReportePDF() async {
//   final pdf = pw.Document();

//   // Agrega una página al PDF
//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text("Reporte de Salidas", style: pw.TextStyle(fontSize: 24)),
//             pw.SizedBox(height: 16),

//             // Tabla de salidas comentadas
//             pw.Text("Salidas comentadas", style: pw.TextStyle(fontSize: 18)),
//             pw.SizedBox(height: 8),
//             pw.TableHelper.fromTextArray(
//               headers: ['Producto', 'Cantidad', 'Hora', 'Comentario'],
//               data: salidasConComentario.map((salida) {
//                 return [
//                   salida['nom_productoin'] ?? '',
//                   salida['cantidad'].toString(),
//                   salida['hora'] ?? '',
//                   salida['comentario'] ?? '',
//                 ];
//               }).toList(),
//             ),

//             pw.SizedBox(height: 20),

//             // Tabla de salidas registradas sin comentario
//             pw.Text("Salidas registradas", style: pw.TextStyle(fontSize: 18)),
//             pw.SizedBox(height: 8),
//             pw.TableHelper.fromTextArray(
//               headers: ['Producto', 'Cantidad', 'Hora'],
//               data: salidasSinComentario.map((salida) {
//                 return [
//                   salida['nom_productoin'] ?? '',
//                   salida['cantidad'].toString(),
//                   salida['hora'] ?? '',
//                 ];
//               }).toList(),
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   // Guardar el archivo PDF
//   try {
//     final output = await getApplicationDocumentsDirectory();
//     final file = File("${output.path}/reporte_salidas.pdf");
//     await file.writeAsBytes(await pdf.save());

//     // Mostrar notificación de éxito al usuario
//     Get.snackbar(
//       "Reporte generado",
//       "El archivo PDF ha sido guardado en: ${file.path}",
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   } catch (e) {
//     print("Error al guardar el PDF: $e");
//     Get.snackbar(
//       "Error",
//       "Hubo un problema al guardar el PDF.",
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          cargando = false;
        });
      },
      child: Scaffold(
        appBar: CustomAppbar(
          titulo: 'Salidas registradas',
          colorsito: color_1,
        ),
        drawer: CustomDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: mostrarCalendario,
                  child: Text('Seleccionar fecha'),
                ),
              ),
              Text(fechaSeleccionada != null ? 'Fecha seleccionada: $fechaSeleccionada' : 'Seleccione una fecha'),
              cargando
                  ? CircularProgressIndicator()
                  : salidasConComentario.isEmpty && salidasSinComentario.isEmpty
                      ? Center(child: Text('No hay salidas hoy'))
                      : Column(
                          children: [
                            Text("Salidas comentadas"),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
  columnSpacing: 20,
  columns: <DataColumn>[
    DataColumn(label: Text('Producto')),
    DataColumn(label: Text('Cantidad')),
    DataColumn(label: Text('Hora')),
    DataColumn(label: Text('Comentario')),
  ],
  rows: salidasConComentario.map((salida) {
    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              salida['nom_productoin'],
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '${salida['cantidad']}',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              salida['hora'],
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 170, maxHeight: 170),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                salida['comentario'],
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ),
      ],
    );
  }).toList(),
),

                            ),
                            SizedBox(height: 20),
                            Text("Salidas registradas"),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                columns: <DataColumn>[
                                  DataColumn(label: Text('Producto')),
                                  DataColumn(label: Text('Cantidad')),
                                  DataColumn(label: Text('Hora')),
                                ],
                                rows: salidasSinComentario.map((salida) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          width: 100,
                                          child: Text(
                                            salida['nom_productoin'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          width: 60,
                                          child: Text(
                                            '${salida['cantidad']}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          width: 80,
                                          child: Text(
                                            salida['hora'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Column(
              //     children: [
              //       ElevatedButton(
              //         // onPressed: () async {
              //         // await crearReportePDF();
              //         // },
              //         child: Text('Imprimir reporte'),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
