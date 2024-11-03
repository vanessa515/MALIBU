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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      backgroundColor: colorsito,
      centerTitle: false,
      elevation: 30,
      shadowColor: Colors.black,
      

/*       actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.call),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.video_call),
        )
      ], */
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
