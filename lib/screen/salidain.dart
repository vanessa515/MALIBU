import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';
import 'package:intl/intl.dart';

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

class SalidaOut extends StatefulWidget {
  const SalidaOut({super.key});

  @override
  State<SalidaOut> createState() => _SalidaOutState();
}

class _SalidaOutState extends State<SalidaOut> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  bool _isSubmitting = false;
  bool _mostrarComentario = false;

  int? fkProducto;

  @override
  void initState() {
    super.initState();
    // Obtener el pk_productoin de los argumentos recibidos y asignarlo a fkProducto
    final argumentos = Get.arguments;
    if (argumentos != null && argumentos['pk_productoin'] != null) {
      fkProducto = argumentos['pk_productoin'];
    }
  }

  Future<void> _registrarSalida() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final fechaActual = DateTime.now().toIso8601String(); // Fecha actual
        final horaActual = DateFormat('HH:mm:ss').format(DateTime.now());

        final response = await Supabase.instance.client.from("salida").insert({
          'cantidad': int.parse(_cantidadController.text),
          'fecha': fechaActual,
          'fk_productoin': fkProducto,
          'comentario': _comentarioController.text.isNotEmpty
              ? _comentarioController.text
              : null,
          'estatus': 1,
          'hora': horaActual,
        }).select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro de salida exitoso')),
          );
          Get.toNamed('/inventario'); // Redirigir a inventario
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar la salida')),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,

/* ----------------------------------------------- AppBar ----------------------------------------------- */
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Registro de Salidas',
          colorsito: color_bg,
        ),
      ),

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: 600), // Ancho máximo para responsividad
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de cantidad
                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: color_font, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color_font, width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese la cantidad';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Solo se permiten números';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Botón para añadir comentario
                    if (!_mostrarComentario)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _mostrarComentario = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color_font,
                            padding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 32.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Añadir un comentario',
                            style: TextStyle(
                              color: color_white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Campo de comentario
                    if (_mostrarComentario) ...[
                      TextFormField(
                        controller: _comentarioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Comentario',
                          labelStyle:
                              TextStyle(color: color_font, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: color_font, width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    SizedBox(height: 20),

                    // Botón de guardar
                    Center(
                      child: _isSubmitting
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _registrarSalida,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color_font,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 32.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: TextStyle(
                                  color: color_white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
