import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogicaLogin extends StatefulWidget {
  @override
  _LogicaLoginState createState() => _LogicaLoginState();
}

class _LogicaLoginState extends State<LogicaLogin> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Modificamos la consulta para usar el id correcto y manejar UUID
      final response = await supabase
          .from('usuario')
          .select('id, role_id, email, password')
          .eq('email', emailController.text.trim())
          .maybeSingle(); // Usamos maybeSingle en lugar de single

      if (response == null) {
        throw Exception('Usuario no encontrado');
      }

      // Verificar la contraseña
      if (response['password'] == passwordController.text) {
        final roleId = response['role_id'] as int;
        await _navigateToRoleBasedScreen(roleId);
      } else {
        throw Exception('Contraseña incorrecta');
      }
    } on PostgrestException catch (error) {
      print("Error de base de datos: ${error.message}");
      if (!mounted) return; // Verificamos si el widget está montado
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${error.message}')),
      );
    } catch (e) {
      print("Excepción capturada: $e");
      if (!mounted) return; // Verificamos si el widget está montado

      String errorMessage = e.toString().contains('Usuario no encontrado')
          ? 'Usuario no encontrado. Verifica tu correo electrónico.'
          : e.toString().contains('Contraseña incorrecta')
              ? 'Contraseña incorrecta. Por favor, inténtalo de nuevo.'
              : 'Error inesperado: ${e.toString()}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) { // Verificamos si el widget está montado
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToRoleBasedScreen(int roleId) async {
    switch (roleId) {
      case 1:
        await Get.offNamed('/admin');
        break;
      case 2:
        await Get.offNamed('/user');
        break;
      default:
        if (mounted) { // Verificamos si el widget está montado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Rol de usuario desconocido')),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            if (isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _signIn,
                child: Text('Iniciar Sesión'),
              ),
          ],
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