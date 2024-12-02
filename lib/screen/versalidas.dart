import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malibu/constants/custom_appbar.dart';
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

class VerSalidas extends StatefulWidget {
  VerSalidas({super.key});

  @override
  State<VerSalidas> createState() => _VerSalidasState();
}

class _VerSalidasState extends State<VerSalidas> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
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
          'nom_productoin':
              productResponse['nom_productoin'] ?? 'Producto desconocido',
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
        backgroundColor: color_bg2,

/* ----------------------------------------------- AppBar ----------------------------------------------- */
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: CustomAppbar(
            titulo: 'Salidas Registradas',
            colorsito: color_bg,
          ),
        ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
        body: SingleChildScrollView(
          child: Center(
            // Centra el contenido en la pantalla
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón para seleccionar fecha
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: mostrarCalendario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color_font,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text(
                      'Seleccionar fecha',
                      style: TextStyle(
                        color: color_white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                // Mostrar la fecha seleccionada
                Text(
                  fechaSeleccionada != null
                      ? 'Fecha seleccionada: $fechaSeleccionada'
                      : '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                // Indicador de carga o contenido de las salidas
                cargando
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(),
                      )
                    : salidasConComentario.isEmpty &&
                            salidasSinComentario.isEmpty
                        ? Center(
                            child: Text(
                              'No hay salidas hoy',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Tabla de salidas con comentarios
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  "Salidas comentadas",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  margin: EdgeInsets.all(16.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: color_white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color_effects,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingTextStyle: TextStyle(
                                      color: color_font,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                              Text(salida['nom_productoin'])),
                                          DataCell(
                                              Text('${salida['cantidad']}')),
                                          DataCell(Text(salida['hora'])),
                                          DataCell(Text(
                                            salida['comentario'],
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),

                              // Tabla de salidas registradas
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  "Salidas registradas",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  margin: EdgeInsets.all(16.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingTextStyle: TextStyle(
                                      color: color_font,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    columns: <DataColumn>[
                                      DataColumn(label: Text('Producto')),
                                      DataColumn(label: Text('Cantidad')),
                                      DataColumn(label: Text('Hora')),
                                    ],
                                    rows: salidasSinComentario.map((salida) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                              Text(salida['nom_productoin'])),
                                          DataCell(
                                              Text('${salida['cantidad']}')),
                                          DataCell(Text(salida['hora'])),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
