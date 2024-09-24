import 'package:flutter/material.dart';
import '../constants/custom_appbar.dart';
import '../constants/custom_drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
  appBar: CustomAppbar(titulo: 'HOME',
    colorsito: Colors.teal,
    ),
     drawer: CustomDrawer(),
      body: Center(

          child: Text('hola nueva act'),
        
      ),
      
    );

  }
}