import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Variables de colores
final Color color_bg = Color.fromARGB(255, 230, 190, 152);
final Color color_bg2 = Color.fromARGB(255, 254, 235, 216);
final Color color_font = Color.fromARGB(255, 69, 65, 129);
final Color color_white = Color.fromARGB(255, 255, 255, 255);
final Color color_white2 = Color.fromARGB(255, 250, 250, 250);
final Color color_cancelar = Color.fromARGB(255, 244, 63, 63);
final Color color_black = Color.fromARGB(255, 0, 0, 0);
final Color color_effects = Colors.black.withOpacity(0.3);
final Color color_green = Colors.green;

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
      backgroundColor: color_bg2,

/* ----------------------------------------------- Cuerpo principal ----------------------------------------------- */
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Verifica el ancho de la pantalla
          bool isSmallScreen = constraints.maxWidth < 600;

          return Center(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: isSmallScreen ? 80 : 100,
                    color: color_effects,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '¿Deseas cerrar tu sesión?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 30 : 50,
                        vertical: 15,
                      ),
                      backgroundColor: color_cancelar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: color_white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: color_font,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
