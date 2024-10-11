import 'package:flutter/material.dart';
import 'package:malibu/constants/custom_appbar.dart';
import 'package:malibu/constants/custom_drawer.dart';

class Inventario extends StatelessWidget {
  const Inventario({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(
        titulo: 'Inventario',
        /* el color aqui en ARGB(alpha, red, green, blue)  */
        colorsito: Color.fromARGB(255, 255, 192, 152),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Text('Inventario'),
      ),
    );
  }
}
