import 'package:flutter/material.dart';
import 'package:malibu/screen/historialVXD.dart';
import 'package:malibu/screen/login.dart';
import 'package:malibu/screen/logout.dart';
import 'package:malibu/screen/productos_modificaciones.dart';
import 'package:malibu/screen/registrar_cat.dart';
import 'package:malibu/screen/registrar_topp.dart';
import 'package:malibu/screen/registrar_unidad.dart';
import 'package:malibu/screen/registrar_medida.dart';
import 'package:malibu/screen/registrar_prodin.dart';
import 'package:malibu/screen/inventario.dart';
import 'package:malibu/screen/medidas.dart';
import 'package:malibu/screen/unidades.dart';
import 'package:malibu/screen/entradain.dart';
import 'package:malibu/screen/salidain.dart';
import 'package:malibu/screen/verentradas.dart';
import 'package:malibu/screen/versalidas.dart';
import 'package:malibu/screen/unidades_modificaciones.dart';
import 'package:malibu/screen/medidas_modificaciones.dart';
import 'package:malibu/screen/productoin_modificaciones.dart';
import 'package:malibu/screen/home.dart';
import 'package:get/get.dart';
import 'package:malibu/screen/registrar_prod.dart';
import 'package:malibu/screen/toppings_modificaciones.dart';

//Conexion a base de datos----------------------------
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xctdoftrftgaiwvfrdqj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU',
  );
  runApp(MyApp());
}
//------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Malibu",
      getPages: [
        GetPage(name: '/', page: () => Home()),
        GetPage(name: '/registrocat', page: () => RegistroCategoria()),
        GetPage(name: '/logoout', page: () => Logout()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/registrocat', page: () => RegistroCategoria()),
        GetPage(name: '/registroprod', page: () => RegistroProducto()),
        GetPage(name: '/registrartopp', page: () => RegistroTopping()),
        GetPage(name: '/inventario', page: () => Inventario()),
        GetPage(name: '/registrarproductoin', page: () => RegistroProductoIn()),
        GetPage(name: '/registrarunidad', page: () => RegistroUnidad()),
        GetPage(name: '/registrarmedida', page: () => RegistroMedida()),
        GetPage(name: '/unidades', page: () => Unidades()),
        GetPage(name: '/medidas', page: () => Medidas()),
        GetPage(name: '/entradain', page: () => EntradaIn()),
        GetPage(name: '/salidain', page: () => SalidaOut()),
        GetPage(name: '/verentradas', page: () => VerEntradas()),
        GetPage(name: '/versalidas', page: () => VerSalidas()),
        GetPage(name: '/editarmedida', page: () => EditarMedidas()),
        GetPage(name: '/editarunidad', page: () => EditarUnidad()),
        GetPage(name: '/editarproductoin', page: () => EditarProductoIn()),
        GetPage(name: '/productomod', page: () => ProductosModificaciones()),
        GetPage(name: '/toppingsmodificaciones', page: () => ToppingMOD()),
        GetPage(name: '/ticketsh', page: () => TicketVentaScreen()),
        GetPage(name: '/historialVXD', page: () => HISTORIALVXD()),
      ],
      initialRoute: '/login',
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
