import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Color colorsito;
  final String titulo;

  CustomAppbar({
    super.key,
    required this.titulo,
    required this.colorsito,
  });

  // Variables de colores
  final Color color_bg = const Color.fromARGB(255, 230, 190, 152);
  final Color color_font = const Color.fromARGB(255, 69, 65, 129);
  final Color color_white = const Color.fromARGB(255, 255, 255, 255);

  // Variables de imágenes
  final String logo_malibu = "../assets/logos/logo_malibu.png";

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      // Título solo visible en pantallas grandes
      title: screenWidth > 600
          ? Text(
              titulo,
              style: TextStyle(
                color: color_font,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null, // En pantallas pequeñas, no se muestra el título

      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 5.0),
        title: Center(
          child: Row(
            mainAxisAlignment: screenWidth > 600
                ? MainAxisAlignment
                    .center // En pantallas grandes, el logo y el título están centrados
                : MainAxisAlignment
                    .center, // En pantallas pequeñas, solo el logo está centrado
            children: [
              // Espaciado entre logo y título en pantallas grandes
              if (screenWidth > 600) SizedBox(width: 50),

              // Logo en el centro
              Image.asset(
                logo_malibu,
                height: 80,
              ),
            ],
          ),
        ),
      ),

      // Color de fondo y color del texto
      backgroundColor: color_bg,
      foregroundColor: color_font,
      elevation: 0, // Borde del appbar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
