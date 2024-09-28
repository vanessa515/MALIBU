import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _ListaProductosState();
}

class _ListaProductosState extends State<Home> {
  List<dynamic> _productos = [];
  List<int> _cantidad = [];

  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    try {
      final response = await Supabase.instance.client.from("producto").select();

      if (response.isNotEmpty) {
        setState(() {
          _productos = response;
          _cantidad = List<int>.filled(_productos.length, 0); // Inicializa el contador para cada producto en 0
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron productos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getImageUrl(String? imageName) {
    if (imageName == null) return ''; // Devuelve una cadena vacía si no hay imagen

    // Construye la URL pública desde el nombre de la imagen
    return Supabase.instance.client.storage
        .from('images') // Cambia 'image' a 'images'
        .getPublicUrl(imageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titulo: 'Home',
        colorsito: Colors.teal,
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _productos.length,
          itemBuilder: (context, index) {
            final producto = _productos[index];
            double precioTotal = producto['precio'] * _cantidad[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(producto['nombre']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precio unitario: \$${producto['precio']}'),
                    const SizedBox(height: 8),
                    Text('Precio total: \$${precioTotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_cantidad[index] > 0) {
                                _cantidad[index]--;
                              }
                            });
                          },
                        ),
                        Text(_cantidad[index].toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _cantidad[index]++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                leading: producto['foto'] != null
                    ? Image.network(
                        _getImageUrl(producto['foto']),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 50); // Imagen de error
                        },
                      )
                    : const Icon(Icons.image, size: 50),
              ),
            );
          },
        ),
      ),
    );
  }
}
