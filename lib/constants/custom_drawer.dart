import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  //Variables de colores
  final Color color_1 = Color.fromARGB(255, 255, 192, 152);
  final Color color_2 = Color.fromARGB(255, 69, 65, 129);
  final Color color_3 = Color.fromARGB(255, 0, 0, 0);

  //Variables de imagenes
  final String logo_img = '../../assets/logos/logo.png';

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: color_1,
      width: 304,
      child: SafeArea(
        child: ListView(
          children: [

            //Header del menu (Logo)
            DrawerHeader(
              child: Image.asset(logo_img, height: 100,),
            ),

            //Menu en listado
            ListTile(
              leading: Icon(Icons.home),
              title: Text("INICIO"),
              subtitle: Text('HOME'),
              onTap: () {
                Get.toNamed('/');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text("Registrar categoria"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registrocat');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Registrar productos"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registroprod');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Registrar toppings"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registrartopp');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Funciones Productos"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/productomod');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Funciones Toppings"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/toppingsmodificaciones');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("Tickets historial"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/ticketsh');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("Historial venta por dia"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/historialVXD');
              },
            ),
            Divider(color: color_2),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Cerrar Sesión"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/logoout');
              },
            ),
          ],
        ),
      ),
    );
  }
}
