import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HISTORIALVXD extends StatefulWidget {
  const HISTORIALVXD({super.key});

  @override
  _HISTORIALVXDState createState() => _HISTORIALVXDState();
}

class _HISTORIALVXDState extends State<HISTORIALVXD> {
  Map<String, List<dynamic>> _ventasPorFecha = {};

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }

  String _formatearFecha(String fechaCompleta) {
    try {
      DateTime fecha = DateTime.parse(fechaCompleta);
      return DateFormat('yyyy-MM-dd').format(fecha); // Formato: Año-Mes-Día
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  Future<void> _fetchTicketData() async {
    try {
      final response = await Supabase.instance.client.rpc('obtener_tickets');
      
      if (response is List) {
        setState(() {
          for (var venta in response) {
            String fechaCompleta = venta['fecha'] ?? 'Fecha no disponible';
            String fecha = _formatearFecha(fechaCompleta);

            if (!_ventasPorFecha.containsKey(fecha)) {
              _ventasPorFecha[fecha] = [];
            }
            _ventasPorFecha[fecha]!.add(venta);
          }
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

  // Función para calcular el total de ventas por día
  double _calcularTotalPorDia(List<dynamic> ventasDelDia) {
    double total = 0;
    for (var venta in ventasDelDia) {
      total += (venta['total_venta'] ?? 0).toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas por Día'),
        backgroundColor: Colors.teal,
      ),
      body: _ventasPorFecha.isEmpty
          ? const Center(child: Text('No hay datos de ventas.'))
          : ListView.builder(
              itemCount: _ventasPorFecha.keys.length,
              itemBuilder: (context, index) {
                String fecha = _ventasPorFecha.keys.elementAt(index);
                List<dynamic> ventasDelDia = _ventasPorFecha[fecha]!;

                // Calcula el total de ventas para el día
                double totalVentasDelDia = _calcularTotalPorDia(ventasDelDia);

                return ExpansionTile(
                  title: Text('Ventas del $fecha (Total de la venta del dia: \$${totalVentasDelDia.toStringAsFixed(2)})'),
                  children: ventasDelDia.map((venta) {
                    final nombreProducto = venta['producto_nombre'] ?? 'Nombre no disponible';
                    final precioProducto = venta['producto_precio'] ?? 0;
                    final cantidad = venta['cantidad_producto'] ?? 0;
                    final totalVenta = venta['total_venta'] ?? 0;

                    final toppingNombre = venta['topping_nombre'] ?? 'Sin topping';
                    final toppingPrecio = venta['topping_precio'] ?? 0;
                    final topping2Nombre = venta['topping2_nombre'] ?? 'Sin topping';
                    final topping2Precio = venta['topping2_precio'] ?? 0;

                    return ListTile(
                      title: Text(nombreProducto),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Precio Producto: \$${precioProducto.toStringAsFixed(2)}'),
                          Text('Topping 1: $toppingNombre (\$${toppingPrecio.toStringAsFixed(2)})'),
                          Text('Topping 2: $topping2Nombre (\$${topping2Precio.toStringAsFixed(2)})'),
                          Text('Cantidad: $cantidad'),
                          Text('Total Venta: \$${totalVenta.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
