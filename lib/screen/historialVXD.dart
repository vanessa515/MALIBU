import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/screen/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Variables de colores
final Color color_bg = Color.fromARGB(255, 230, 190, 152);
final Color color_bg2 = Color.fromARGB(255, 254, 235, 216);
final Color color_font = Color.fromARGB(255, 69, 65, 129);
final Color color_white = Color.fromARGB(255, 255, 255, 255);
final Color color_white2 = Color.fromARGB(255, 250, 250, 250);
final Color color_cancelar = Color.fromARGB(255, 244, 63, 63);
final Color color_grey = Colors.grey;
final Color color_black = Color.fromARGB(255, 0, 0, 0);
final Color color_effects = Colors.black.withOpacity(0.3);

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

List<dynamic> _cajaData = [];

  List<dynamic> _detallesVentaOptions = []; // Opciones de detalles_venta
  dynamic _selectedDetalleVenta; // Opción seleccionada

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
    _fetchDetallesVentaOptions(); // Cargar opciones de detalles_venta
    _fetchCajaData();
  }

String _formatearFecha(String fechaCompleta) {
  try {
    // Imprimir la fecha para verificar si está en el formato esperado
    print('Fecha original: $fechaCompleta');
    DateTime fecha = DateTime.parse(fechaCompleta);  // Convertir el String en DateTime
    return DateFormat('yyyy-MM-dd').format(fecha); // Formato: Año-Mes-Día
  } catch (e) {
    print('Error al formatear la fecha: $e');
    return 'Fecha no disponible';
  }
}



  // Función para obtener y sumar los datos

Future<void> _fetchCajaData() async {
  try {
    final response = await Supabase.instance.client.from('caja').select();
    double totalcaja = 0.0;
    List<Map<String, dynamic>> cajaConFechas = [];

    for (var item in response) {
      double otros = item['otros'] ?? 0.0;
      double sueldo = item['sueldo'] ?? 0.0;
      totalcaja += otros + sueldo;

      // Consulta para obtener la fecha del detalle de venta
      final detalleResponse = await Supabase.instance.client
          .from('detalle_venta')
          .select('fecha')
          .eq('pk_detalle_venta', item['fk_detalle_venta'])
          .single();

      String fecha = 'Fecha no disponible';
      if (detalleResponse['fecha'] != null) {
        fecha = detalleResponse['fecha'];  // Usamos la fecha directamente
      }

      cajaConFechas.add({
        'sueldo': sueldo,
        'otros': otros,
        'motivos': item['motivos'],
        'fecha': fecha,
        'total': otros + sueldo,
      });
    }

    setState(() {
      _cajaData = cajaConFechas;  // Actualizamos el estado con los datos obtenidos
    });

    print('Total Caja: $totalcaja');
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al obtener datos de la caja: $e')),
    );
  }
}


Future<String> _obtenerFechaDetalleVenta(String fkDetalleVenta) async {
  try {
    final response = await Supabase.instance.client
        .from('detalle_venta')  // Tabla donde se encuentra la fecha
        .select('fecha')  // Campo 'fecha'
        .eq('pk_detalle_venta', fkDetalleVenta)  // Buscar por el id del detalle de venta
        .single();  // Obtener un solo resultado

    if (response['fecha'] != null) {
      var fecha = response['fecha'];

      // Verificar si la fecha es un String
      if (fecha is String) {
        // Verificar si la fecha tiene el formato esperado
        if (fecha.contains('-') && fecha.contains(':')) {
          return _formatearFecha(fecha);  // Si tiene formato adecuado, la formateamos
        } else {
          return 'Formato de fecha inválido';
        }
      } else {
        return 'Fecha no disponible';
      }
    } else {
      return 'Fecha no disponible';
    }
  } catch (e) {
    print('Error al obtener la fecha: $e');
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
        print(
            'Los datos no son una lista. Tipo recibido: ${response.runtimeType}');
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
      final response =
          await Supabase.instance.client.from('detalle_venta').select();

      setState(() {
        _detallesVentaOptions = response;
      });
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
        final response = await Supabase.instance.client.from("caja").insert({
          'sueldo': _sueldoController.text,
          'otros': _otrosController.text,
          'motivos': _motivosController.text,
          'fk_detalle_venta':
              _selectedDetalleVenta, // Asigna el detalle seleccionado
        }).select();

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
    backgroundColor: color_bg2,
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: CustomAppbar(
        titulo: 'Historial de Ventas por Día',
        colorsito: color_bg,
      ),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView( // Permite el desplazamiento de todo el contenido
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sueldoController,
                              decoration: InputDecoration(
                                labelText: 'Sueldo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: color_white2,
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                ),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Campo requerido' : null,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _otrosController,
                              decoration: InputDecoration(
                                labelText: 'Otros',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: color_white2,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Campo requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _motivosController,
                        decoration: InputDecoration(
                          labelText: 'Motivos',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: color_white2,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField(
                        value: _selectedDetalleVenta,
                        items: _detallesVentaOptions.map((detalle) {
                          return DropdownMenuItem(
                            value: detalle['pk_detalle_venta'],
                            child: Text(detalle['fecha']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDetalleVenta = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Seleccionar Detalle de Venta',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: color_white2,
                        ),
                        validator: (value) => value == null
                            ? 'Seleccione un detalle de venta'
                            : null,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _registrarCaja,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 24.0,
                          ),
                          backgroundColor: color_font,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isSubmitting
                            ? CircularProgressIndicator()
                            : Text(
                                'Registrar Caja',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color_white2,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Ventas por Fecha
              _ventasPorFecha.isEmpty
                  ? Center(child: Text('No hay datos de ventas.'))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _ventasPorFecha.keys.length,
                      shrinkWrap: true, // Permite que el ListView no ocupe toda la altura
                      physics: NeverScrollableScrollPhysics(), // Deshabilita el desplazamiento aquí
                      itemBuilder: (context, index) {
                        String fecha = _ventasPorFecha.keys.elementAt(index);
                        List<dynamic> ventasDelDia = _ventasPorFecha[fecha]!;
                        double totalVentasDelDia =
                            _calcularTotalPorDia(ventasDelDia);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ExpansionTile(
                            title: Text(
                              'Ventas del $fecha',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 16 : 18,
                              ),
                            ),
                            subtitle: Text(
                              'Total del día: \$${totalVentasDelDia.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: color_green,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                            children: ventasDelDia.map((venta) {
                              final nombreProducto =
                                  venta['producto_nombre'] ?? 'Nombre no disponible';
                              final precioProducto =
                                  venta['producto_precio'] ?? 0;
                              final cantidad =
                                  venta['cantidad_producto'] ?? 0;
                              final totalVenta = venta['total_venta'] ?? 0;
                              final toppingNombre =
                                  venta['topping_nombre'] ?? 'Sin topping';
                              final toppingPrecio =
                                  venta['topping_precio'] ?? 0;
                              final topping2Nombre =
                                  venta['topping2_nombre'] ?? 'Sin topping';
                              final topping2Precio =
                                  venta['topping2_precio'] ?? 0;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 6.0),
                                child: ListTile(
                                  tileColor: color_grey,
                                  title: Text(
                                    nombreProducto,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Precio Producto: \$${precioProducto.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: isMobile ? 12 : 14),
                                      ),
                                      Text(
                                        'Topping 1: $toppingNombre (\$${toppingPrecio.toStringAsFixed(2)})',
                                        style: TextStyle(
                                            fontSize: isMobile ? 12 : 14),
                                      ),
                                      Text(
                                        'Topping 2: $topping2Nombre (\$${topping2Precio.toStringAsFixed(2)})',
                                        style: TextStyle(
                                            fontSize: isMobile ? 12 : 14),
                                      ),
                                      Text(
                                        'Cantidad: $cantidad',
                                        style: TextStyle(
                                            fontSize: isMobile ? 12 : 14),
                                      ),
                                      Text(
                                        'Total Venta: \$${totalVenta.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: isMobile ? 12 : 14),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
              // Registros de Caja (Colocado al final)
            SizedBox(height: 20),
Text(
  'Registros de Caja:',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
_cajaData.isEmpty
  ? Center(child: Text('No hay datos disponibles.'))
  : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _cajaData.length,
      itemBuilder: (context, index) {
        final caja = _cajaData[index];
        return ListTile(
          title: Text('Sueldo: ${caja['sueldo']}'),
          subtitle: Text(
            'Otros: ${caja['otros']}\nMotivos: ${caja['motivos']}\nFecha: ${caja['fecha']}',
          ),
          trailing: Text('Total: ${caja['total']}'),
        );
      },
    )



            ],
          ),
        );
      },
    ),
  );
}
}