import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Logout extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      
      // Mostrar diálogo de confirmación
      Get.dialog(
        AlertDialog(
          title: Text('Cerrando Sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(), // Cierra el diálogo
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Get.back(); // Cierra el diálogo
                await Future.delayed(Duration(milliseconds: 500));
                Get.offAllNamed('/login'); // Redirige al login
              },
              child: Text('Sí, cerrar sesión'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cerrar la sesión',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerrar Sesión'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              '¿Deseas cerrar tu sesión?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}