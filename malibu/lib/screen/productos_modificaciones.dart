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
    // Navegar a la pantalla de edición (esto es un ejemplo, debes implementar la pantalla de edición)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(producto: producto),
      ),
    );
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

class EditarProductoScreen extends StatelessWidget {
  final dynamic producto;
  const EditarProductoScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    // Aquí puedes implementar tu lógica para editar el producto
    return Scaffold(
      appBar: AppBar(title: Text('Editar Producto')),
      body: Center(
        child: Text('Editar ${producto['nombre']}'),
      ),
    );
  }
}
