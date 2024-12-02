import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class Medidas extends StatefulWidget {
  Medidas({super.key});

  @override
  State<Medidas> createState() => _MedidasState();
}

class _MedidasState extends State<Medidas> {
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  List<Map<String, dynamic>> medidasActivas = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    traerMedidas();
  }

  // Función para obtener los registros con estatus = 1
  Future<void> traerMedidas() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('medida')
          .select()
          .eq('estatus', 1)
          .order('pk_medida', ascending: true)
          .then((data) {
        return data;
      });

      medidasActivas = List<Map<String, dynamic>>.from(response).map((medida) {
        return {
          'pk_medida': medida['pk_medida'] ?? 0,
          'nom_medida': medida['nom_medida'] ?? 'Sin nombre',
        };
      }).toList();
    } catch (e) {
      print('Error al obtener datos: $e');
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> _darBaja(int pk_medida) async {
    await Supabase.instance.client
        .from('medida')
        .update({'estatus': 0})
        .eq('pk_medida', pk_medida)
        .then((_) {
          traerMedidas(); // Actualiza la lista después de dar de baja
        })
        .catchError((error) {
          print('Error al dar de baja: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,

/* ----------------------------------------------- AppBar ----------------------------------------------- */
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Medidas Registradas',
          colorsito: color_bg,
        ),
      ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
      body: Column(
        children: [
          // Mostrar un indicador de carga
          if (cargando)
            CircularProgressIndicator()
          else
            Padding(
              padding: EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: EdgeInsets.all(
                              16.0), // Espaciado alrededor de la tabla
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
                            headingTextStyle: TextStyle(
                              color: color_font,
                              fontWeight: FontWeight.bold,
                            ),
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'Medida',
                                  style: TextStyle(color: color_font),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Acciones',
                                  style: TextStyle(color: color_font),
                                ),
                              ),
                            ],
                            rows: medidasActivas.map((medida) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(medida['nom_medida'])),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Botón Editar
                                        OutlinedButton(
                                          onPressed: () {
                                            Get.toNamed(
                                              '/editarmedida',
                                              arguments: {
                                                'pk_medida': medida['pk_medida']
                                              },
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side:
                                                BorderSide(color: Colors.green),
                                          ),
                                          child: Text('Editar'),
                                        ),
                                        SizedBox(width: 8),
                                        // Botón Dar baja
                                        OutlinedButton(
                                          onPressed: () {
                                            _mostrarConfirmacionDarBaja(
                                                context, medida['pk_medida']);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.red),
                                          ),
                                          child: Text('Dar baja'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Botón "Agregar medida"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/registrarmedida');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color_font,
                  foregroundColor: color_white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(200, 50), // Botón adaptativo
                ),
                child: Text('Agregar medida'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionDarBaja(BuildContext context, int pk_medida) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Deseas dar de baja esta medida?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
            ),
            TextButton(
              child: Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                _darBaja(pk_medida); // Procede a dar de baja
              },
            ),
          ],
        );
      },
    );
  }
}
