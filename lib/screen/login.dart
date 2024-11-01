import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: Duration(seconds: 3),
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

      if (response != null && response['password'] == passwordController.text) {
        final roleId = response['role_id'] as int;
        
        Get.snackbar(
          'Éxito',
          'Inicio de sesión exitoso',
          backgroundColor: Colors.green.withOpacity(0.1),
          duration: Duration(seconds: 2),
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
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('../assets/logos/logo.jpg', height: 120),
                
                SizedBox(height: 40),

                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF414581),
                  ),
                ),
                SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth > 600
                        ? 500
                        : double.infinity;

                    return Center(
                      child: Container(
                        width: cardWidth,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Color(0xFF414581),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                                    prefixIcon: Icon(Icons.email, color: Color(0xFFFFFFFF)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  style: TextStyle(color: Color(0xFFFFFFFF)),
                                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                ),
                                SizedBox(height: 20),

                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                                    prefixIcon: Icon(Icons.lock, color: Color(0xFFFFFFFF)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  style: TextStyle(color: Color(0xFFFFFFFF)),
                                  onSubmitted: (_) => _signIn(),
                                ),
                                SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFC098),
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
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
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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