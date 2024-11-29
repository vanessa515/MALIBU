import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../constants/custom_appbar.dart';

class EditarMedidas extends StatefulWidget {
  const EditarMedidas({Key? key}) : super(key: key);

  @override
  State<EditarMedidas> createState() => _EditarMedidasState();
}

class _EditarMedidasState extends State<EditarMedidas> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isSubmitting = false;
  late int pkMedida;

  @override
  void initState() {
    super.initState();
    pkMedida = Get.arguments['pk_medida']; // Obtener la pk enviada desde la pantalla anterior
    _cargarMedida(); // Cargar los datos actuales de la medida
  }

  Future<void> _cargarMedida() async {
    try {
      final response = await Supabase.instance.client
          .from("medida")
          .select("nom_medida")
          .eq('pk_medida', pkMedida)
          .single();

      setState(() {
        _nombreController.text = response['nom_medida'] ?? ''; // Rellenar el campo con el nombre existente
      });
        } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la medida: $e')),
      );
    }
  }

Future<void> _editarMedida() async {
  if (_formKey.currentState!.validate()) {
    await Supabase.instance.client
        .from('medida')
        .update({
          'nom_medida': _nombreController.text,
        })
        .eq('pk_medida', pkMedida);

    // Redirige a la pantalla de /medidas e indica que se realizó una actualización
    Get.offNamed('/medidas', arguments: {'updated': true});
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
        titulo: 'EDITAR MEDIDA',
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
                  labelText: 'Nombre de la Medida',
                  hintText: 'Ejemplo: gramos, mililitros, piezas, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre de medida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _editarMedida,
                      child: Text('Actualizar Medida'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
