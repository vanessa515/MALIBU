import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Color colorsito;
  final String titulo;

  CustomAppbar({
    super.key,
    required this.titulo,
    required this.colorsito,
  });

  //Variables de colores
  final Color color_bg = Color.fromARGB(255, 230, 190, 152);
  final Color color_font = Color.fromARGB(255, 69, 65, 129);
  final Color color_white = Color.fromARGB(255, 255, 255, 255);
  final Color color_3 = Color.fromARGB(255, 0, 0, 0);

  //Variables de imagenes
  final String logo_img = "../assets/logos/logo.png";
  final String logo_rmvbg = "../assets/logos/logo_bgremove.png";
  final String logo_malibu = "../assets/logos/logo_malibu.png";

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //Titulo centralizado
      title: Text(
        titulo,
        style: TextStyle(
          color: color_font,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        overflow: TextOverflow.ellipsis,
      ),

      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 5.0),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Espaciado entre logo y titulo
              SizedBox(width: 50),

              Image.asset(
                logo_malibu,
                height: 80,
              ),
            ],
          ),
        ),
      ),

      //Color de fondo y color del texto
      backgroundColor: color_bg,
      foregroundColor: color_font,
      elevation: 0, // <-- Borde del appbar
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(30);
}
