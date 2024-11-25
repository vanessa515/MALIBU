import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';

class EditarUnidad extends StatefulWidget {
  const EditarUnidad({Key? key}) : super(key: key);

  @override
  State<EditarUnidad> createState() => _EditarUnidadState();
}

class _EditarUnidadState extends State<EditarUnidad> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isSubmitting = false;
  late int pkUnidad;

  @override
  void initState() {
    super.initState();
    pkUnidad = Get.arguments['pk_unidad']; // Obtener la pk enviada desde la pantalla anterior
    _cargarUnidad(); // Cargar los datos actuales de la unidad
  }

  Future<void> _cargarUnidad() async {
    try {
      final response = await Supabase.instance.client
          .from("unidad")
          .select("nom_unidad")
          .eq('pk_unidad', pkUnidad)
          .single();

      if (response != null) {
        setState(() {
          _nombreController.text = response['nom_unidad'] ?? ''; // Rellenar el campo con el nombre existente
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la unidad: $e')),
      );
    }
  }

  Future<void> _editarUnidad() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        await Supabase.instance.client
            .from('unidad')
            .update({
              'nom_unidad': _nombreController.text,
            })
            .eq('pk_unidad', pkUnidad);

        // Redirige a la pantalla de /unidades e indica que se realizó una actualización
        Get.offNamed('/unidades', arguments: {'updated': true});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la unidad: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'EDITAR UNIDAD',
        colorsito: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Unidad',
                  hintText: 'Ejemplo: cajas, paquetes, frascos, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre de unidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _editarUnidad,
                      child: Text('Actualizar Unidad'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
