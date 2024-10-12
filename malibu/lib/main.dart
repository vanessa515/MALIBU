import 'package:flutter/material.dart';
import 'package:malibu/screen/productos_modificaciones.dart';
import 'package:malibu/screen/registrar_cat.dart';
import 'package:malibu/screen/registrar_topp.dart';
import 'package:malibu/screen/home.dart';
import 'package:get/get.dart';
import 'package:malibu/screen/registrar_prod.dart';


//Conexion a base de datos----------------------------
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://xctdoftrftgaiwvfrdqj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjdGRvZnRyZnRnYWl3dmZyZHFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3ODY5OTcsImV4cCI6MjA0MjM2Mjk5N30.kyKvMcuXnLOMGWz2Mbyscok0l8DrB0-x0ug9jDIqDYU',
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
      title: "Hola mundo :D",
   
      getPages: 
      [GetPage(name: '/', page: ()=> Home() ),
       GetPage(name: '/registrocat', page: ()=> RegistroCategoria() ),
       GetPage(name: '/registroprod', page: ()=> RegistroProducto() ),
       GetPage(name: '/registrartopp', page: ()=> RegistroTopping() ),
          GetPage(name: '/productomod', page: ()=> ProductosModificaciones() )
      ],
      
      initialRoute: '/',
      theme: ThemeData(
      useMaterial3: true, 
      ),
    );
  }
}