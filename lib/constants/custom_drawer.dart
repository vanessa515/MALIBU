import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 304,
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              child: Icon(Icons.star),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("INICIO"),
              subtitle: Text('HOME'),
              onTap: () {
                Get.toNamed('/');
              },
            ),
            Divider(color: Colors.black),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text("Registrar categoria"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registrocat');
              },
            ),
            Divider(color: Colors.black),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Registrar productos"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registroprod');
              },
            ),
            Divider(color: Colors.black),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Registrar toppings"),
              subtitle: Text(''),
              onTap: () {
                Get.toNamed('/registrartopp');
              },
            ),
            Divider(color: Colors.black),
            ListTile(
              leading: Icon(Icons.inventory_2_sharp),
              title: Text("Inventario"),
              subtitle: Text('Lista de productos'),
              onTap: () {
                Get.toNamed('/inventario');
              },
            ),
          ],
        ),
      ),
    );
  }
}
