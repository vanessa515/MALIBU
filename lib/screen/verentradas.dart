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

class VerEntradas extends StatefulWidget {
  VerEntradas({super.key});

  @override
  State<VerEntradas> createState() => _VerEntradasState();
}

class _VerEntradasState extends State<VerEntradas> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  bool cargando = false;

  List<Map<String, dynamic>> entradasRegistradas = [];
  String? fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    // Obtener entradas del día actual al iniciar
    String fechaHoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    traerEntradasRegistradas(fecha: fechaHoy);
  }

  Future<void> traerEntradasRegistradas({String? fecha}) async {
    setState(() {
      cargando = true;
    });

    try {
      var query = supabase.from('entrada').select();

      // Filtrar por fecha si se proporciona
      if (fecha != null) {
        query = query.eq('fecha', fecha);
      }

      final response = await query;

      if (response.isEmpty) {
        setState(() {
          entradasRegistradas = []; // Limpiar lista si no hay entradas
        });
        print("No hay entradas en la fecha seleccionada");
        return;
      }

      List<Map<String, dynamic>> tempEntradasRegistradas = [];

      for (var entrada in response) {
        final productResponse = await supabase
            .from('productoin')
            .select('nom_productoin')
            .eq('pk_productoin', entrada['fk_productoin'])
            .single();

        tempEntradasRegistradas.add({
          'cantidad': entrada['cantidad'] ?? 0,
          'nom_productoin':
              productResponse['nom_productoin'] ?? 'Producto desconocido',
          'estatus': entrada['estatus'] == 1 ? 'Activo' : 'Inactivo',
          'hora': entrada['hora'] ?? 'Hora desconocida',
        });
      }

      setState(() {
        entradasRegistradas = tempEntradasRegistradas;
      });
    } catch (e) {
      print('Error al traer entradas: $e');
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
      await traerEntradasRegistradas(fecha: fechaSeleccionada);
    }
  }

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
            titulo: 'Entradas Registradas',
            colorsito: color_bg,
          ),
        ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
        body: Stack(
          children: [
            Center(
              // Centra todo el contenido en la pantalla
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

                  // Indicador de carga o contenido de las entradas
                  cargando
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: CircularProgressIndicator(),
                        ) // Indicador de carga
                      : entradasRegistradas.isEmpty
                          ? Center(
                              child: Text(
                                'No hay entradas hoy',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    margin: EdgeInsets.all(
                                        16.0), // Espaciado externo
                                    padding: EdgeInsets.all(
                                        16.0), // Espaciado interno
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
                                      headingTextStyle: TextStyle(
                                        color: color_font,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      columns: <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'Producto',
                                            style: TextStyle(
                                              color: color_font,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Cantidad',
                                            style: TextStyle(
                                              color: color_font,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Hora',
                                            style: TextStyle(
                                              color: color_font,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: entradasRegistradas.map((entrada) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                entrada['nom_productoin'],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${entrada['cantidad']}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${entrada['hora']}',
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
