import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductosModificaciones extends StatefulWidget {
  const ProductosModificaciones({super.key});

  @override
  _ProductosModificacionesState createState() => _ProductosModificacionesState();
}

class _ProductosModificacionesState extends State<ProductosModificaciones> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> productos = [];

  @override
  void initState() {
    super.initState();
    _getProductos();
  }

  Future<void> _getProductos() async {
    final response = await supabase.from('producto').select('*');
    if (response != null) {
      setState(() {
        productos = response;
      });
    }
  }

  Future<void> _deleteProducto(int id) async {
    await supabase.from('producto').delete().eq('pk_producto', id);
    _getProductos(); // Recargar la lista de productos después de eliminar
  }

  void _editarProducto(dynamic producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(producto: producto),
      ),
    ).then((value) {
      if (value == true) {
        _getProductos(); // Recargar la lista de productos si se ha editado alguno
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
        titulo: 'Funciones productos',
        colorsito: Colors.teal,
      ),
      drawer: CustomDrawer(),
      body: productos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(
                      getImageUrl(producto['foto']), 
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(producto['nombre']),
                    subtitle: Text('Precio: \$${producto['precio']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editarProducto(producto),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteProducto(producto['pk_producto']),
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

class EditarProductoScreen extends StatefulWidget {
  final dynamic producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  _EditarProductoScreenState createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto['nombre']);
    _precioController = TextEditingController(text: widget.producto['precio'].toString());
  }

  Future<void> _updateProducto() async {
    if (_formKey.currentState!.validate()) {
      // Actualizar el producto en la base de datos
      await Supabase.instance.client
          .from('producto')
          .update({
            'nombre': _nombreController.text,
            'precio': double.parse(_precioController.text),
          })
          .eq('pk_producto', widget.producto['pk_producto']);

      // Volver a la pantalla anterior e indicar que se ha realizado una actualización
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
        titulo: 'Editar producto',
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
                onPressed: _updateProducto,
                child: Text('Actualizar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
