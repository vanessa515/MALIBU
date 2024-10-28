import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/custom_appbar.dart';


class TicketVentaScreen extends StatefulWidget {
  @override
  _TicketVentaScreenState createState() => _TicketVentaScreenState();
}

class _TicketVentaScreenState extends State<TicketVentaScreen> {
  List<dynamic> _ticketData = [];

  @override
  void initState() {
    super.initState();
    _fetchTicketData(); // obtener los datos de los tickets
  }

  Future<void> _fetchTicketData() async {
    try {
      final response = await Supabase.instance.client.rpc('obtener_tickets');
      print('Full Response: $response');

      if (response is List) {
        print('Response is a list with ${response.length} items.');
        setState(() {
          _ticketData = response;
        });
      } else {
        print('Los datos no son una lista. Tipo recibido: ${response.runtimeType}');
      }
    } catch (e) {
      print('Caught error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _imprimirTicket() {
    // Si los videos de youtube no se equivocan aqui va la logica de impresion
    print('Botón de imprimir ticket presionado');
  }

  @override
  Widget build(BuildContext context) {
    print('Longitud de _ticketData: ${_ticketData.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de ventas(tickets)'),
        backgroundColor: Colors.teal,
      ),
      body: _ticketData.isEmpty
          ? Center(child: Text('No hay datos de ventas.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _ticketData.length,
                    itemBuilder: (context, index) {
                      final producto = _ticketData[index];

                      // Impresión 
                      print('Producto $index: $producto');

                     
                      final nombreProducto = producto['producto_nombre'] ?? 'Nombre no disponible';
                      final precioProducto = producto['producto_precio'] ?? 0;
                      final cantidad = producto['cantidad_producto'] ?? 0;
                      final totalVenta = producto['total_venta'] ?? 0;
                      final fecha = producto['fecha'] ?? 'Fecha no disponible';

                      final toppingNombre = producto['topping_nombre'] ?? 'Sin topping';
                      final toppingPrecio = producto['topping_precio'] ?? 0;
                      final topping2Nombre = producto['topping2_nombre'] ?? 'Sin topping';
                      final topping2Precio = producto['topping2_precio'] ?? 0;

                      return Card(
                        child: ListTile(
                          title: Text('$nombreProducto'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio Producto: \$${precioProducto.toStringAsFixed(2)}'),
                              Text('Topping 1: $toppingNombre (\$${toppingPrecio.toStringAsFixed(2)})'),
                              Text('Topping 2: $topping2Nombre (\$${topping2Precio.toStringAsFixed(2)})'),
                               Text('Cantidad: $cantidad'),
                              Text('Fecha: $fecha'),
                              Text('Total Venta: \$${totalVenta.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _imprimirTicket,
                  child: Text('Imprimir Ticket'),
                ),
              ],
            ),
    );
  }
}