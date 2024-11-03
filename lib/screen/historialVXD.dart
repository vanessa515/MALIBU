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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sueldoController = TextEditingController();
  final TextEditingController _otrosController = TextEditingController();
  final TextEditingController _motivosController = TextEditingController();
  bool _isSubmitting = false;

  List<dynamic> _detallesVentaOptions = []; // Opciones de detalles_venta
  dynamic _selectedDetalleVenta; // Opción seleccionada

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
    _fetchDetallesVentaOptions(); // Cargar opciones de detalles_venta
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

  Future<void> _fetchDetallesVentaOptions() async {
    try {
      final response = await Supabase.instance.client.from('detalle_venta').select();

      if (response is List) {
        setState(() {
          _detallesVentaOptions = response;
        });
      } else {
        print('Error al obtener detalles de venta: ${response.runtimeType}');
      }
    } catch (e) {
      print('Caught error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener detalles de venta: $e')),
      );
    }
  }

  double _calcularTotalPorDia(List<dynamic> ventasDelDia) {
    double total = 0;
    for (var venta in ventasDelDia) {
      total += (venta['total_venta'] ?? 0).toDouble();
    }
    return total;
  }

  Future<void> _registrarCaja() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await Supabase.instance.client
            .from("caja")
            .insert({
              'sueldo': _sueldoController.text,
              'otros': _otrosController.text,
              'motivos': _motivosController.text,
              'fk_detalle_venta': _selectedDetalleVenta, // Asigna el detalle seleccionado
            })
            .select();

        setState(() {
          _isSubmitting = false;
        });

        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Caja registrada exitosamente')),
          );
          _sueldoController.clear();
          _otrosController.clear();
          _motivosController.clear();
          _selectedDetalleVenta = null; // Reinicia la selección
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar caja')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas por Día'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _sueldoController,
                    decoration: InputDecoration(labelText: 'Sueldo'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _otrosController,
                    decoration: InputDecoration(labelText: 'Otros'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _motivosController,
                    decoration: InputDecoration(labelText: 'Motivos'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  DropdownButtonFormField(
                    value: _selectedDetalleVenta,
                    items: _detallesVentaOptions.map((detalle) {
                      return DropdownMenuItem(
                        value: detalle['pk_detalle_venta'], // Asume que la clave primaria es 'id'
                        child: Text(detalle['fecha']), // Muestra el nombre del detalle
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDetalleVenta = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Seleccionar Detalle de Venta'),
                    validator: (value) => value == null ? 'Seleccione un detalle de venta' : null,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _registrarCaja,
                    child: _isSubmitting
                        ? CircularProgressIndicator()
                        : Text('Registrar Caja'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _ventasPorFecha.isEmpty
                ? const Center(child: Text('No hay datos de ventas.'))
                : ListView.builder(
                    itemCount: _ventasPorFecha.keys.length,
                    itemBuilder: (context, index) {
                      String fecha = _ventasPorFecha.keys.elementAt(index);
                      List<dynamic> ventasDelDia = _ventasPorFecha[fecha]!;

                      double totalVentasDelDia = _calcularTotalPorDia(ventasDelDia);

                      return ExpansionTile(
                        title: Text('Ventas del $fecha (Total del día: \$${totalVentasDelDia.toStringAsFixed(2)})'),
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
          ),
        ],
      ),
    );
  }
}
