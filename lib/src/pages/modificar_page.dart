// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ModificarPerfilPage extends StatefulWidget {
  const ModificarPerfilPage({super.key});

  @override
  State<ModificarPerfilPage> createState() => _ModificarPerfilPageState();
}

class _ModificarPerfilPageState extends State<ModificarPerfilPage> {
  String _nom = '';
  DateTime _fechan = DateTime.now();
  String _telefono = '';
  String _horarios = '';
  String _password = '';
  String _confirmPassword = '';
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _horariosController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final db = MentorMeDatabase.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid');
    
    if (userId != null) {
      final u = await db.getUserbyId(userId);
      if (u != null) {
        setState(() {
          user = u;
          _nombreController.text = u.nombre;
          _fechaController.text = DateFormat('yyyy-MM-dd').format(u.fechanacimiento);
          _telefonoController.text = u.telefono;
          _horariosController.text = u.horario ?? '';
          _passwordController.text = u.password;
          _nom=_nombreController.text;
          _telefono=_telefonoController.text;
          _horarios=_horariosController.text;
          _password=_passwordController.text;
        });
      } else {
        Navigator.pushNamed(context, 'welcome');
      }
    } else {
      Navigator.pushNamed(context, 'welcome');
    }
  }
  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil', style: TextStyle(color: Colors.amber[800])),
      ),
      body: Stack(
        children: [
          // Decoración con círculos de fondo dentro de un Stack
          /*Positioned(
            top: -responsive.wp(40) * 0.30,
            left: -responsive.wp(40) * 0.40,
            child: _buildBackgroundCircle(
                responsive.wp(40), const Color(0xFF60A5FA)), // Celeste Claro
          ),
          Positioned(
            bottom: -responsive.wp(35) * 0.30,
            right: -responsive.wp(35) * 0.40,
            child: _buildBackgroundCircle(
                responsive.wp(35), const Color(0xFF10B981)), // Verde Esmeralda
          ),*/
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: responsive.dp(
                            3.5), // Ajusta el tamaño según la diagonal de la pantalla
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A), // Azul Marino
                      ),
                    ),
                    SizedBox(height: responsive.hp(1)),
                    Text(
                      'Modifica tus datos de la manera que veas necesaria.',
                      style: TextStyle(
                        fontSize: responsive.dp(2), // Texto descriptivo
                        color: const Color(0xFF4B5563), // Gris Neutro
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.hp(3)),
              _nombreInput(),
              const SizedBox(height: 20),
              _fechaNacimientoInput(context),
              const SizedBox(height: 20),
              _telefonoInput(),
              const SizedBox(height: 20),
              _passwordInput(),
              const SizedBox(height: 20),
              _confirmPasswordInput(),
              const SizedBox(height: 20),
              user?.rol == 'Profesor'
                  ? _horariosInput()
                  : const SizedBox(height: 1),
              const SizedBox(height: 40),
              _buildRegisterButton(context), 
            ],
          ),
        ],
      ),
    );
  }


  Widget _passwordInput() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Contraseña',
        labelText: 'Contraseña',
        suffixIcon: _password.isNotEmpty
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        icon: const Icon(Icons.lock, color: Color(0xFF4B5563)), // Gris Neutro
      ),
      onChanged: (valor) {
        setState(() {
          _password = valor;
        });
      },
    );
  }

  Widget _confirmPasswordInput() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Confirmar Contraseña',
        labelText: 'Confirmar Contraseña',
        suffixIcon: _confirmPassword.isNotEmpty && _password == _confirmPassword
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.error, color: Colors.red),
        errorText: _confirmPassword.isNotEmpty && _password != _confirmPassword
            ? 'Las contraseñas no coinciden'
            : null,
        icon: const Icon(Icons.lock, color: Color(0xFF4B5563)),
      ),
      onChanged: (valor) {
        setState(() {
          _confirmPassword = valor;
        });
      },
    );
  }

  Widget _nombreInput() {
    return TextField(
      controller: _nombreController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        counter: Text('Letras ${_nom.length}'),
        hintText: 'Nombre de la persona',
        labelText: 'Nombre',
        helperText: 'Solo nombre',
        suffixIcon: const Icon(Icons.accessibility),
        icon: const Icon(Icons.account_circle,
            color: Color(0xFF4B5563)), // Gris Neutro
      ),
      onChanged: (valor) {
        setState(() {
          _nom = valor;
        });
      },
    );
  }

  Widget _fechaNacimientoInput(BuildContext context) {
    return TextField(
      enableInteractiveSelection: false,
      controller: _fechaController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Fecha de nacimiento',
        labelText: 'Fecha de nacimiento',
        suffixIcon: const Icon(Icons.perm_contact_calendar),
        icon: const Icon(Icons.calendar_today,
            color: Color(0xFF1E3A8A)), // Azul Marino
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context);
      },
    );
  }

  _selectDate(BuildContext context) async {
    DateTime? calendario = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (calendario != null) {
      setState(() {
        _fechan = calendario; // Formatear la fecha correctamente
        _fechaController.text = DateFormat('yyyy-MM-dd')
            .format(calendario);
      });
    }
  }

  Widget _telefonoInput() {
    return TextField(
      controller: _telefonoController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Número de teléfono',
        labelText: 'Teléfono',
        suffixIcon: _telefono.length == 10
            ? const Icon(Icons.check_circle, color: Colors.green) // Éxito
            : _telefono.isEmpty
                ? null
                : const Icon(Icons.error, color: Colors.red), // Error
        icon: const Icon(Icons.phone_android, color: Color(0xFF4B5563)),
        errorText: _telefono.isNotEmpty && _telefono.length != 10
            ? 'El número debe tener 10 dígitos' // Mensaje de error
            : null,
      ),
      onChanged: (valor) {
        setState(() {
          _telefono = valor;
        });
      },
    );
  }

  Widget _horariosInput() {
    final RegExp horarioRegExp =
        RegExp(r'^\d{1,2}:\d{2} (AM|PM) - \d{1,2}:\d{2} (AM|PM)$');

    return TextField(
      controller: _horariosController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Horario (ej. 09:00 AM - 10:00 AM)',
        labelText: 'Horario de Tutoría',
        suffixIcon: horarioRegExp.hasMatch(_horarios)
            ? const Icon(Icons.check_circle, color: Colors.green)
            : _horarios.isEmpty
                ? null
                : const Icon(Icons.error, color: Colors.red),
        icon: const Icon(Icons.access_time, color: Color(0xFF4B5563)),
        errorText: _horarios.isNotEmpty && !horarioRegExp.hasMatch(_horarios)
            ? 'Formato inválido. Ejemplo: 09:00 AM - 10:00 AM'
            : null,
      ),
      onChanged: (valor) {
        setState(() {
          _horarios = valor;
        });
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        backgroundColor: const Color(0xFFD97706),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text('Guardar Cambios',
          style: TextStyle(fontSize: 18, color: Colors.white)),
      onPressed: () {
        _validateAndShowConfirmationDialog(context);
      },
    );
  }

  // Validación antes de mostrar el modal
  void _validateAndShowConfirmationDialog(BuildContext context) {
    if (_nom.isEmpty ||
        _fechan==DateTime.now() ||
        _telefono.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      // faltan datos obligatorios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, completa todos los campos obligatorios.')),
      );
    } else if (user?.rol == 'Profesor' &&
        (_horarios.isEmpty)) {
      // el profesor no completó materia y horarios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Los profesores deben seleccionar un horario.')),
      );
    } else if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Las contraseñas no coinciden. Por favor verificalas.')),
      );
    } else {
      _showConfirmationDialog(context);
    }
  }

  void _showConfirmationDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de Registro'),
          content: const Text('¿Deseas confirmar tu registro con estos datos?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                user = User(
                    id: user!.id,
                    email: user!.email,
                    password: _password,
                    rol: user!.rol,
                    telefono: _telefono,
                    fechanacimiento: _fechan,
                    nombre: _nom,
                    horario: user!.rol == 'Profesor' ?_horarios : null,
                  );
                // Guardar en la base de datos
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('nombre', user!.nombre);
                await MentorMeDatabase.instance.updateUser(user!);
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, 'home'); 
              },
            ),
          ],
        );
      },
    );
  }
}