import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Unidades extends StatefulWidget {
  Unidades({super.key});

  @override
  State<Unidades> createState() => _UnidadesState();
}

class _UnidadesState extends State<Unidades> {
  Color color_1 = Color.fromARGB(255, 255, 192, 152);
  List<Map<String, dynamic>> unidadesActivas = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    traerUnidades();
  }

  // Función para obtener los registros con estatus = 1
  Future<void> traerUnidades() async {
    setState(() {
      cargando = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('unidad')
          .select()
          .eq('estatus', 1)
          .order('pk_unidad', ascending: true)
          .then((data) {
        return data;
      });

      unidadesActivas = List<Map<String, dynamic>>.from(response).map((unidad) {
        return {
          'pk_unidad': unidad['pk_unidad'] ?? 0,
          'nom_unidad': unidad['nom_unidad'] ?? 'Sin nombre',
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

  Future<void> _darBaja(int pk_unidad) async {
    await Supabase.instance.client
        .from('unidad')
        .update({'estatus': 0})
        .eq('pk_unidad', pk_unidad)
        .then((_) {
          traerUnidades(); // Actualiza la lista después de dar de baja
        }).catchError((error) {
          print('Error al dar de baja: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'Unidades registradas',
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
                            'Unidad',
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
                      rows: unidadesActivas.map((unidad) {
                        return DataRow(
                          cells: [
                            DataCell(Text(unidad['nom_unidad'])),
                            DataCell(
                              Row(
                                children: [
                                  // Botón Editar
                                  OutlinedButton(
                                    onPressed: () {
                                      Get.toNamed(
                                        '/editarunidad',
                                        arguments: {'pk_unidad': unidad['pk_unidad']},
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
                                          context, unidad['pk_unidad']);
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

          // Botón "Agregar unidad"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/registrarunidad');
                },
                child: Text('Agregar unidad'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionDarBaja(BuildContext context, int pk_unidad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Deseas dar de baja esta unidad?'),
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
                _darBaja(pk_unidad); // Procede a dar de baja
              },
            ),
          ],
        );
      },
    );
  }
}
