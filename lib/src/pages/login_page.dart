import 'package:flutter/material.dart';
//import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '/src/utils/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A), // Azul Marino
      ),
      body: Stack(
        children: [
          Positioned(
            top: -responsive.wp(40) * 0.30,
            left: -responsive.wp(40) * 0.40,
            child: _buildBackgroundCircle(responsive.wp(40), const Color(0xFF60A5FA)), // Celeste Claro
          ),
          Positioned(
            bottom: -responsive.wp(35) * 0.30,
            right: -responsive.wp(35) * 0.40,
            child: _buildBackgroundCircle(responsive.wp(35), const Color(0xFF10B981)), // Verde Esmeralda
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¡Bienvenido de nuevo!',
                    style: TextStyle(
                      fontSize: responsive.dp(3.5), // Ajusta el tamaño según la diagonal de la pantalla
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A), // Azul Marino
                    ),
                  ),
                  SizedBox(height: responsive.hp(1)),
                  Text(
                    'Por favor, ingresa tus credenciales para continuar.',
                    style: TextStyle(
                      fontSize: responsive.dp(1.5), // Texto descriptivo
                      color: const Color(0xFF4B5563), // Gris Neutro
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsive.hp(3)),
                  _emailInput(responsive),
                  SizedBox(height: responsive.hp(2)),
                  _passwordInput(responsive),
                  SizedBox(height: responsive.hp(3)),
                  _loginButton(responsive,context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _emailInput(Responsive responsive) {
    final RegExp exp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Correo Electrónico',
        labelText: 'Correo Electrónico',
        suffixIcon: exp.hasMatch(_email)
            ? const Icon(Icons.check_circle, color: Colors.green) // Éxito
            : _email.isEmpty
                ? null
                : const Icon(Icons.error, color: Colors.red), // Error
        icon: const Icon(Icons.email, color: Color(0xFF4B5563)), // Gris Neutro
        errorText: _email.isNotEmpty && !exp.hasMatch(_email)
            ? 'Formato de correo inválido' // Mensaje de error
            : null,
      ),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
    );
  }

  Widget _passwordInput(Responsive responsive) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Contraseña',
        labelText: 'Contraseña',
        suffixIcon: _password.length >= 6
            ? const Icon(Icons.check_circle, color: Colors.green) // Éxito
            : _password.isEmpty
                ? null
                : const Icon(Icons.error, color: Colors.red), // Error
        icon: const Icon(Icons.lock, color: Color(0xFF4B5563)), // Gris Neutro
        errorText: _password.isNotEmpty && _password.length < 6
            ? 'La contraseña debe tener al menos 6 caracteres' // Mensaje de error
            : null,
      ),
      onChanged: (valor) {
        setState(() {
          _password = valor;
        });
      },
    );
  }

  Future<bool> _verificarCredenciales(String email, String password) async {
    final User? resultado = await FirebaseServices.instance.getUserLogin(email,password);// await MentorMeDatabase.instance.getUserLogin(email, password);
    
    if(resultado==null){
      return false;
    } 

    await _guardarSesion(resultado);
    
    return true;
  }

  Future<void> _guardarSesion(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', user.email);
    await prefs.setString('rol', user.rol);
    await prefs.setString('nombre', user.nombre);
    await prefs.setString('userid', user.id?? "");   
  }

  Widget _loginButton(Responsive responsive, BuildContext context) {
    return ElevatedButton(
      onPressed: _email.isNotEmpty && _password.isNotEmpty && _password.length >= 6
          ? () async {
              // Lógica de autenticación
            bool esValido = await _verificarCredenciales(_email, _password);
            
            if (esValido) {
              Navigator.pushReplacementNamed(context, 'home'); 
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credenciales incorrectas'))
              );
            }
            }
          : null, // Desactiva el botón si los campos no están completos
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(20), vertical: responsive.hp(2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: const Color(0xFF1E3A8A), // Azul Marino
      ),
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

}
