import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Color colorsito;
  final String titulo;

  const CustomAppbar({
    super.key,
    required this.titulo,
    required this.colorsito,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      backgroundColor: colorsito,
      centerTitle: false,
      elevation: 30,
      shadowColor: Colors.black,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.call),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.video_call),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
