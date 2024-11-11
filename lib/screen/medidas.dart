import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        }).catchError((error) {
          print('Error al dar de baja: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'Medidas registradas',
        colorsito: color_1,
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          // Mostrar un indicador de carga
          if (cargando)
            CircularProgressIndicator()
          else
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Medida',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Acciones',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                      rows: medidasActivas.map((medida) {
                        return DataRow(
                          cells: [
                            DataCell(Text(medida['nom_medida'])),
                            DataCell(
                              Row(
                                children: [
                                  // Botón Editar
                                  OutlinedButton(
                                    onPressed: () {
                                      Get.toNamed(
                                        '/editarmedida',
                                        arguments: {'pk_medida': medida['pk_medida']},
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.green),
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
            ),

          // Botón "Agregar medida"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/registrarmedida');
                },
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
