import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor, complete todos los campos',
        backgroundColor: Colors.red.withOpacity(0.5),
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height *
              0.12, // Espacio desde la parte superior
          left: MediaQuery.of(context).size.width *
              0.33, // Margen izquierdo para centrar
          right: MediaQuery.of(context).size.width *
              0.33, // Margen derecho para centrar
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('usuario')
          .select('id, email, password, role_id')
          .eq('email', emailController.text.trim())
          .single();

      if (response['password'] == passwordController.text) {
        final roleId = response['role_id'] as int;

        Get.snackbar(
          'Bienvenido',
          'Inicio de sesión exitoso',
          backgroundColor: Colors.green.withOpacity(0.5),
          duration: Duration(seconds: 1),
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height *
                0.30, // Espacio desde la parte superior
            left: MediaQuery.of(context).size.width *
                0.33, // Margen izquierdo para centrar
            right: MediaQuery.of(context).size.width *
                0.33, // Margen derecho para centrar
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        );

        await Future.delayed(Duration(seconds: 1));

        if (roleId == 1) {
          Get.offAllNamed('/admin');
        } else if (roleId == 2) {
          Get.offAllNamed('/user');
        } else {
          throw Exception('Rol de usuario no válido');
        }
      } else {
        throw Exception('Contraseña incorrecta');
      }
    } on PostgrestException catch (e) {
      print('Error de base de datos: ${e.message}');
      Get.snackbar(
        'Error',
        'Error de conexión con la base de datos',
        backgroundColor: Colors.red.withOpacity(0.3),
        duration: Duration(seconds: 3),
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height *
              0.30, // Espacio desde la parte superior
          left: MediaQuery.of(context).size.width *
              0.33, // Margen izquierdo para centrar
          right: MediaQuery.of(context).size.width *
              0.33, // Margen derecho para centrar
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      );
    } catch (e) {
      print('Error: $e');
      String errorMessage = 'Error al iniciar sesión';

      if (e.toString().contains('no rows returned')) {
        errorMessage = 'Usuario no encontrado';
      } else if (e.toString().contains('Contraseña incorrecta')) {
        errorMessage = 'Contraseña incorrecta';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //Variables de colores
  Color color_bg = Color.fromARGB(255, 230, 190, 152);
  Color color_font = Color.fromARGB(255, 69, 65, 129);
  Color color_white = Color.fromARGB(255, 255, 255, 255);
  Color color_3 = Color.fromARGB(255, 0, 0, 0);

  //Variables de imagenes
  String logo_img = "../assets/logos/logo.png";
  String logo_rmvbg = "../assets/logos/logo_bgremove.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Background de login
      backgroundColor: (color_white),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Imagen del logo - contenedor
                Container(
                  child: Image.asset(
                    logo_rmvbg,
                    height: 250,
                  ),
                ),

                //Espaciado 1
                SizedBox(height: 25),

                //Texto de bienvenida
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color_font,
                  ),
                ),

                //Espaciado 2
                SizedBox(height: 20),

                //Texto de ingreso de correo electrónico
                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth =
                        constraints.maxWidth > 600 ? 500 : double.infinity;

                    return Center(
                      child: Container(
                        width: cardWidth,

                        //Contenedor del login
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: color_font,
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                //Input de ingresar CORREO
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    labelStyle: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: color_white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  onEditingComplete: () =>
                                      FocusScope.of(context).nextFocus(),
                                ),

                                //Espaciado 3
                                SizedBox(height: 20),

                                //Input de ingresar CONTRASEÑA
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    labelStyle:
                                        TextStyle(color: Color(0xFFFFFFFF)),
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xFFFFFFFF)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  style: TextStyle(color: Color(0xFFFFFFFF)),
                                  onSubmitted: (_) => _signIn(),
                                ),

                                //Espaciado 4
                                SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color_white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                          ),
                                        )
                                      : Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
