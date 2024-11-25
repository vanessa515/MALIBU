import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:malibu/screen/registrar_prod.dart';
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
    setState(() {
      toppings = response;
    });
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

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  void _verDetallesTopping(Map<String, dynamic> topping) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            topping['nombre'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              topping['foto'] != null
                  ? Image.network(
                      getImageUrl(topping['foto']),
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: color_grey,
                      ),
                    )
                  : Icon(Icons.image_not_supported,
                      size: 100, color: color_grey),
              SizedBox(height: 10),
              Text(
                'Precio: \$${topping['precio']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  /* ###############%%%%%%%%%%%%%%%%%%%%%% Aqui empieza el diseño de la vista Modificacion de toppings %%%%%%%%%%%%%%%%%%%%%%%%########################## */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Funciones Toppings',
          colorsito: color_bg,
        ),
      ),
      drawer: CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Se verifica si el ancho de la pantalla es menor a 600px
          bool isSmallScreen = constraints.maxWidth < 600;

          return Column(
            children: [
              if (isSmallScreen)
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Funciones Toppings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color_font,
                    ),
                  ),
                ),
              Expanded(
                child: toppings.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: toppings.length,
                        itemBuilder: (context, index) {
                          final topping = toppings[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10.0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: topping['foto'] != null &&
                                        topping['foto'].isNotEmpty
                                    ? Image.network(
                                        getImageUrl(topping['foto']),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: color_grey,
                                        ),
                                      )
                                    : Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: color_grey,
                                      ),
                              ),

                              title: Text(
                                topping['nombre'] ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color_font,
                                ),
                              ),

                              subtitle: Text(
                                'Precio: \$${topping['precio'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: color_grey,
                                ),
                              ), // Manejar precio nulo

                              trailing: Wrap(
                                spacing: 5.0,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: color_font,
                                    ),
                                    onPressed: () => _editarTopping(topping),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: color_cancelar,
                                    ),
                                    onPressed: () =>
                                        _deleteTopping(topping['pk_topping']),
                                  ),
                                ],
                              ),
                              onTap: () => _verDetallesTopping(topping),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Logica de editar toppings %%%%%%%%%%% */

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
    _precioController =
        TextEditingController(text: widget.topping['precio'].toString());
  }

  Future<void> _updateTopping() async {
    if (_formKey.currentState!.validate()) {
      await Supabase.instance.client.from('topping').update({
        'nombre': _nombreController.text,
        'precio': double.parse(_precioController.text),
      }).eq('pk_topping', widget.topping['pk_topping']);

      // Volver a la pantalla anterior e indicar que se ha realizado una actualización
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Editar Topping',
          colorsito: color_bg,
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nombreController,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: color_white,
                                prefixIcon: Icon(
                                  Icons.abc_outlined,
                                  color: color_font,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingresa un nombre';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _precioController,
                              decoration: InputDecoration(
                                labelText: 'Precio',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: color_white,
                                prefixIcon: Icon(
                                  Icons.attach_money_outlined,
                                  color: color_font,
                                ),
                              ),
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
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                backgroundColor: color_font,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Actualizar Topping',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: color_white,
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
            ),
          );
        },
      ),
    );
  }
}
