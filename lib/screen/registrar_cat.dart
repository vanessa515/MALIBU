import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';

//Variables de colores
Color color_bg = Color.fromARGB(255, 230, 190, 152);
Color color_font = Color.fromARGB(255, 69, 65, 129);
Color color_white = Color.fromARGB(255, 255, 255, 255);
Color color_cancelar = Color.fromARGB(255, 244, 63, 63);
Color color_black = Color.fromARGB(255, 0, 0, 0);
Color color_effects = Colors.black.withOpacity(0.3);

class RegistroCategoria extends StatefulWidget {
  const RegistroCategoria({super.key});

  @override
  State<RegistroCategoria> createState() => _RegistroCategoriaState();
}

class _RegistroCategoriaState extends State<RegistroCategoria> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _registrarCategoria() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response =
            await Supabase.instance.client.from("categoria").insert({
          'nombre_cat': _nombreController.text,
          'estatus': 1,
        }).select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoría registrada exitosamente')),
          );
          _nombreController.clear(); // Limpiar el formulario
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar categoría')),
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
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Ventas',
          colorsito: color_bg,
        ),
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
                  labelText: 'Nombre de la Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre de categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registrarCategoria,
                      child: Text('Registrar Categoría'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
