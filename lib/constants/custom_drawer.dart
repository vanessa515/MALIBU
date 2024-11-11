import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  //Variables de colores
  final Color color_1 = Color.fromARGB(255, 230, 192, 152);
  final Color color_2 = Color.fromARGB(255, 69, 65, 129);
  final Color color_3 = Color.fromARGB(255, 0, 0, 0);

  //Variables de imagenes
  final String logo_img = '../assets/logos/logo.png';
  final String logo_rmvbg = '../assets/logos/logo_bgremove.png';

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
              child: Image.asset(
                logo_rmvbg,
                height: 150,
                width: 150,
              ),
            ),

            //Menu en listado
            ListTile(
              leading: Icon(
                Icons.home,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "INICIO",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/');
              },
            ),

            //Espaciado 1
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.add,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Registrar categoria",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/registrocat');
              },
            ),

            //Espaciado 2
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.add,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Registrar productos",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/registroprod');
              },
            ),

            //Espaciado 3
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.add,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Registrar toppings",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/registrartopp');
              },
            ),

            //Espaciado 4
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.settings,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Funciones Productos",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/productomod');
              },
            ),

            //Espaciado 5
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.settings,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Funciones Toppings",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/toppingsmodificaciones');
              },
            ),

            //Espaciado 6
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.task,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Inventario",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/inventario');
              },
            ),

            //Espaciado 7
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.task,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Tickets historial",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/ticketsh');
              },
            ),

            //Espaciado 7
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.book,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Historial venta por dia",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Get.toNamed('/historialVXD');
              },
            ),

            //Espaciado 8
            Divider(color: color_2),

            ListTile(
              leading: Icon(
                Icons.logout,
                size: 30,
                color: color_2,
              ),
              title: Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: color_3,
                  fontSize: 20,
                ),
              ),
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
