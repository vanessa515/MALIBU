import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerEntradas extends StatefulWidget {
  VerEntradas({super.key});

  @override
  State<VerEntradas> createState() => _VerEntradasState();
}

class _VerEntradasState extends State<VerEntradas> {
  final supabase = SupabaseClient('https://xctdoftrftgaiwvfrdqj.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU');
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
          'nom_productoin': productResponse['nom_productoin'] ?? 'Producto desconocido',
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
        appBar: CustomAppbar(
          titulo: 'Entradas reistradas',
          colorsito: color_1,
        ),
        drawer: CustomDrawer(),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: mostrarCalendario,
                    child: Text('Seleccionar fecha'),
                  ),
                ),
                Text(fechaSeleccionada != null ? 'Fecha seleccionada: $fechaSeleccionada' : 'Seleccione una fecha'),

                cargando
                    ? CircularProgressIndicator() // Indicador de carga
                    : Expanded(
                        child: entradasRegistradas.isEmpty
                            ? Center(child: Text('No hay entradas hoy')) // Mensaje si no hay entradas
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: <DataColumn>[
                                    DataColumn(label: Text('Producto')),
                                    DataColumn(label: Text('Cantidad')),
                                    DataColumn(label: Text('Hora')),
                                  ],
                                  rows: entradasRegistradas.map((entrada) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(entrada['nom_productoin'])),
                                        DataCell(Text('${entrada['cantidad']}')),
                                        DataCell(Text('${entrada['hora']}')),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Lógica para imprimir reporte
                          //   },
                          //   child: Text('Imprimir reporte'),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
