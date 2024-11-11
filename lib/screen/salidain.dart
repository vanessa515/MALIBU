import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';
import 'package:intl/intl.dart';

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

        final response = await Supabase.instance.client
            .from("salida")
            .insert({
              'cantidad': int.parse(_cantidadController.text),
              'fecha': fechaActual,
              'fk_productoin': fkProducto,
              'comentario': _comentarioController.text.isNotEmpty ? _comentarioController.text : null,
              'estatus': 1,
              'hora': horaActual,
            })
            .select();

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
      appBar: CustomAppbar(
        titulo: 'REGISTRO DE SALIDA',
        colorsito: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 20),
                if (!_mostrarComentario)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mostrarComentario = true;
                      });
                    },
                    child: Text('Añadir un comentario'),
                  ),
                if (_mostrarComentario)
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 20),
                _isSubmitting
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _registrarSalida,
                        child: Text('Guardar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
