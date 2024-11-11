import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';
import 'package:intl/intl.dart';

class EntradaIn extends StatefulWidget {
  const EntradaIn({super.key});

  @override
  State<EntradaIn> createState() => _EntradaInState();
}

class _EntradaInState extends State<EntradaIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();
  bool _isSubmitting = false;

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

  Future<void> _registrarEntrada() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final fechaActual = DateTime.now().toIso8601String(); // Fecha actual
        final horaActual = DateFormat('HH:mm:ss').format(DateTime.now());

        final response = await Supabase.instance.client
            .from("entrada")
            .insert({
              
              'cantidad': int.parse(_cantidadController.text),
              'fecha': fechaActual,
              'fk_productoin': fkProducto,
              'estatus': 1,
              'hora': horaActual,
            })
            .select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro de entrada exitoso')),
          );
          Get.toNamed('/inventario'); // Redirigir a inventario
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar la entrada')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'REGISTRO DE ENTRADA',
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
                _isSubmitting
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _registrarEntrada,
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
