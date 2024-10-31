import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ToppingMOD extends StatefulWidget {
  const ToppingMOD({super.key});

  @override
  _ToppingMODState createState() => _ToppingMODState();
}

class _ToppingMODState extends State<ToppingMOD> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> toppings = [];

  @override
  void initState() {
    super.initState();
    _getToppings();
  }

  Future<void> _getToppings() async {
    final response = await supabase.from('topping').select('*');
    if (response != null) {
      setState(() {
        toppings = response;
      });
    }
  }

  Future<void> _deleteTopping(int id) async {
    await supabase.from('topping').delete().eq('pk_topping', id);
    _getToppings(); 
  }

  void _editarTopping(dynamic topping) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarToppingScreen(topping: topping),
      ),
    ).then((value) {
      if (value == true) {
        _getToppings(); 
      }
    });
  }

  String getImageUrl(String imagePath) {
    final bucket = supabase.storage.from('images'); 
    return bucket.getPublicUrl(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'Funciones toppings',
        colorsito: Colors.teal,
      ),
      drawer: CustomDrawer(),
      body: toppings.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: toppings.length,
              itemBuilder: (context, index) {
                final topping = toppings[index];
                return Card(
  margin: EdgeInsets.all(10),
  child: ListTile(
    leading: topping['foto'] != null
        ? Image.network(
            getImageUrl(topping['foto']),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
        : const Icon(Icons.image), // Icono por defecto
    title: Text(topping['nombre'] ?? 'Sin nombre'), // Manejar nombre nulo
    subtitle: Text('Precio: \$${topping['precio'] ?? 0}'), // Manejar precio nulo
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _editarTopping(topping),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _deleteTopping(topping['pk_topping']),
        ),
      ],
    ),
  ),
);

              },
            ),
    );
  }
}

class EditarToppingScreen extends StatefulWidget {
  final dynamic topping;

  const EditarToppingScreen({super.key, required this.topping});

  @override
  _EditarToppingScreenState createState() => _EditarToppingScreenState();
}

class _EditarToppingScreenState extends State<EditarToppingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.topping['nombre']);
    _precioController = TextEditingController(text: widget.topping['precio'].toString());
  }

  Future<void> _updateTopping() async {
    if (_formKey.currentState!.validate()) {
 
      await Supabase.instance.client
          .from('topping')
          .update({
            'nombre': _nombreController.text,
            'precio': double.parse(_precioController.text),
          })
          .eq('pk_topping', widget.topping['pk_topping']);

      // Volver a la pantalla anterior e indicar que se ha realizado una actualización
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
        titulo: 'Editar topping',
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
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un precio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTopping,
                child: Text('Actualizar Topping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
