import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  //Variables de colores
  final Color color_1 = Color.fromARGB(255, 230, 192, 152);
  final Color color_2 = Color.fromARGB(255, 69, 65, 129);
  final Color color_3 = Color.fromARGB(255, 0, 0, 0);
  final Color color_4 = Color.fromARGB(255, 250, 250, 250);
  final Color color_5 = Color.fromARGB(255, 230, 202, 173);
  final Color color_6 = Color.fromARGB(0, 0, 0, 0);
  final Color color_7 = Color.fromARGB(255, 244, 63, 63);

  //Variables de imagenes
  final String logo_img = '../assets/logos/logo.png';
  final String logo_rmvbg = '../assets/logos/logo_bgremove.png';

  // Opcion para la seleccion en el dropdown
  final List<Map<String, dynamic>> registerOptions = [
    {"title": "Registrar categoría", "route": "/registrocat"},
    {"title": "Registrar productos", "route": "/registroprod"},
    {"title": "Registrar toppings", "route": "/registrartopp"},
  ];
  final List<Map<String, dynamic>> editionOptions = [
    {"title": "Funciones Productos", "route": "/productomod"},
    {"title": "Funciones Toppings", "route": "/toppingsmodificaciones"},
  ];
  final List<Map<String, dynamic>> historialOptions = [
    {"title": "Historial de tickets", "route": "/ticketsh"},
    {"title": "Historial de ventas por dia", "route": "/historialVXD"},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: color_4,
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
            Divider(color: color_6),

            // Dropdown para opciones de registro
            ExpansionTile(
              title: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: color_2,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Agregar Productos",
                    style: TextStyle(
                      fontSize: 20,
                      color: color_3,
                    ),
                  ),
                ],
              ),
              children: registerOptions.map((option) {
                return ListTile(
                  title: Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 18,
                      color: color_3,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(option['route']);
                  },
                );
              }).toList(),
            ),

            //Espaciado 2
            Divider(color: color_6),

            // Dropdown para opciones de Edicion
            ExpansionTile(
              title: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: color_2,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Editar Productos",
                    style: TextStyle(
                      fontSize: 20,
                      color: color_3,
                    ),
                  ),
                ],
              ),
              children: editionOptions.map((option) {
                return ListTile(
                  title: Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 18,
                      color: color_3,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(option['route']);
                  },
                );
              }).toList(),
            ),

            //Espaciado 4
            Divider(color: color_6),

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

            //Espaciado 5
            Divider(color: color_6),

            // Dropdown para opciones de Historiales
            ExpansionTile(
              title: Row(
                children: [
                  Icon(
                    Icons.work_history,
                    color: color_2,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Historiales",
                    style: TextStyle(
                      fontSize: 20,
                      color: color_3,
                    ),
                  ),
                ],
              ),
              children: historialOptions.map((option) {
                return ListTile(
                  title: Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 18,
                      color: color_3,
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(option['route']);
                  },
                );
              }).toList(),
            ),

            //Espaciado 7
            Divider(color: color_6),

            ListTile(
              leading: Icon(
                Icons.logout,
                size: 30,
                color: color_7,
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
