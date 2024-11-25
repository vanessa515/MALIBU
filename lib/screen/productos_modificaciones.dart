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

class ProductosModificaciones extends StatefulWidget {
  const ProductosModificaciones({super.key});

  @override
  _ProductosModificacionesState createState() =>
      _ProductosModificacionesState();
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
    setState(() {
      productos = response;
    });
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

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  void _verDetallesProducto(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            producto['nombre'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              producto['foto'] != null
                  ? Image.network(
                      getImageUrl(producto['foto']),
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
                'Precio: \$${producto['precio']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Descripción: ${producto['descripcion'] ?? "No disponible"}',
                style: TextStyle(fontSize: 14, color: color_grey),
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

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Diseño de la lista de productos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_bg2,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppbar(
          titulo: 'Funciones productos',
          colorsito: color_bg,
        ),
      ),
      drawer: CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Verificamos si el ancho de la pantalla es menor a 600px
          bool isSmallScreen = constraints.maxWidth < 600;

          return Column(
            children: [
              // Si la pantalla es pequeña, mostramos el título en el body
              if (isSmallScreen)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Funciones productos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color_font,
                    ),
                  ),
                ),

              // diseño de la lista
              Expanded(
                child: productos.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10.0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: producto['foto'] != null &&
                                        producto['foto'].isNotEmpty
                                    ? Image.network(
                                        getImageUrl(producto['foto']),
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
                                producto['nombre'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color_font,
                                ),
                              ),
                              subtitle: Text(
                                'Precio: \$${producto['precio']}',
                                style:
                                    TextStyle(fontSize: 14, color: color_grey),
                              ),
                              trailing: Wrap(
                                spacing: 5.0,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: color_font),
                                    onPressed: () => _editarProducto(producto),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: color_cancelar),
                                    onPressed: () => _deleteProducto(
                                        producto['pk_producto']),
                                  ),
                                ],
                              ),
                              onTap: () => _verDetallesProducto(producto),
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

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Aqui empieza otra parte del codigo (logica) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    _precioController =
        TextEditingController(text: widget.producto['precio'].toString());
  }

  Future<void> _updateProducto() async {
    if (_formKey.currentState!.validate()) {
      // Actualizar el producto en la base de datos
      await Supabase.instance.client.from('producto').update({
        'nombre': _nombreController.text,
        'precio': double.parse(_precioController.text),
      }).eq('pk_producto', widget.producto['pk_producto']);

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
          titulo: 'Editar Producto',
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
                                fillColor: color_white2,
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
                                fillColor: color_white2,
                                prefixIcon: Icon(
                                  Icons.attach_money,
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
                              onPressed: _updateProducto,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                backgroundColor: color_font,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Actualizar Producto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
