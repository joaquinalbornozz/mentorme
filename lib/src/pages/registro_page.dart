import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas.
import 'package:shared_preferences/shared_preferences.dart';
import '../models/materia.dart';
import '../models/user.dart';
import '../database/database.dart';
import '/src/utils/responsive.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  String _nom = '';
  String _email = '';
  DateTime _fechan=DateTime(1000);
  String _telefono = '';
  Materia? _materiaSeleccionada;
  String _rolSeleccionado = 'Sin rol';
  String _horarios = '';
  String _password = '';
  String _confirmPassword = '';

  final TextEditingController _inputFieldController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _horariosController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  List<Materia> materias = []; 
  final List<String> _roles = ['Sin rol', 'Alumno', 'Profesor'];

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  Future<void> _loadMaterias() async {
    final db = MentorMeDatabase.instance;
    final loadedMaterias = await db.getAllMaterias();
    setState(() {
      materias = loadedMaterias;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A), // Azul Marino
      ),
      body: Stack(
        children: [
          // Decoración con círculos de fondo dentro de un Stack
          Positioned(
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
          ),
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      '¡Bienvenido a MentorMe!',
                      style: TextStyle(
                        fontSize: responsive.dp(
                            3.5), // Ajusta el tamaño según la diagonal de la pantalla
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A), // Azul Marino
                      ),
                    ),
                    SizedBox(height: responsive.hp(1)),
                    Text(
                      'Por favor, ingresa tus datos para comenzar tu experiencia eduativa.',
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
              _emailInput(),
              const SizedBox(height: 20),
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
              _rolDropdown(),
              const SizedBox(height: 20),
              _rolSeleccionado == 'Profesor'
                  ? _materiaDropdown()
                  : const SizedBox(height: 1),
              const SizedBox(height: 20),
              _rolSeleccionado == 'Profesor'
                  ? _horariosInput()
                  : const SizedBox(height: 1),
              const SizedBox(height: 40),
              _buildRegisterButton(context), // Botón que abre el modal
            ],
          ),
        ],
      ),
    );
  }

  // Función para crear un círculo de fondo
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

  Widget _emailInput() {
    final RegExp exp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        counter: Text('Letras ${_email.length}'),
        hintText: 'Correo Electronico',
        labelText: 'Correo Electronico',
        helperText: 'Tu correo electronico',
        suffixIcon: exp.hasMatch(_email)
            ? const Icon(Icons.check_circle,
                color: Colors.green) // Ícono de éxito si es válido
            : _email.isEmpty
                ? null
                : const Icon(Icons.error,
                    color: Colors.red), // Ícono de error si no es válido
        errorText: _email.isNotEmpty && !exp.hasMatch(_email)
            ? 'Formato inválido, use el formato correcto' // Mensaje de error si el formato no es válido
            : null,
        icon: const Icon(Icons.email, color: Color(0xFF4B5563)), // Gris Neutro
      ),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
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
      controller: _inputFieldController,
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
        _inputFieldController.text = DateFormat('yyyy-MM-dd')
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

  Widget _rolDropdown() {
    return Row(
      children: [
        const Icon(Icons.person, color: Color(0xFF1E3A8A)),
        const SizedBox(width: 16.0),
        Expanded(
          child: DropdownButton<String>(
            value: _rolSeleccionado,
            items: _roles.map((rol) {
              return DropdownMenuItem(value: rol, child: Text(rol));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _rolSeleccionado = newValue!;
              });
            },
            isExpanded: true,
            underline: Container(
              height: 2,
              color: const Color(0xFF60A5FA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _materiaDropdown() {
    return Row(
      children: [
        const Icon(Icons.book, color: Color(0xFF10B981)),
        const SizedBox(width: 16.0),
        Expanded(
          child: DropdownButton<Materia>(
            value: _materiaSeleccionada,
            items: materias.map<DropdownMenuItem<Materia>>((Materia materia) {
              return DropdownMenuItem<Materia>(
                value: materia,
                child: Text(materia.nombre),
              );
            }).toList(),
            onChanged: (Materia? newValue) {
              setState(() {
                _materiaSeleccionada = newValue;
              });
            },
            isExpanded: true,
            underline: Container(
              height: 2,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
      ],
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
        hintText: 'Horario (ej. 10:00 AM)',
        labelText: 'Horario de Tutoría',
        suffixIcon: horarioRegExp.hasMatch(_horarios)
            ? const Icon(Icons.check_circle, color: Colors.green)
            : _horarios.isEmpty
                ? null
                : const Icon(Icons.error, color: Colors.red),
        icon: const Icon(Icons.access_time, color: Color(0xFF4B5563)),
        errorText: _horarios.isNotEmpty && !horarioRegExp.hasMatch(_horarios)
            ? 'Formato inválido. Ejemplo: 10:00 AM'
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
      child: const Text('Registrarse',
          style: TextStyle(fontSize: 18, color: Colors.white)),
      onPressed: () {
        _validateAndShowConfirmationDialog(context);
      },
    );
  }

  // Validación antes de mostrar el modal
  void _validateAndShowConfirmationDialog(BuildContext context) {
    if (_nom.isEmpty ||
        _email.isEmpty ||
        _fechan==DateTime(1000) ||
        _telefono.isEmpty ||
        _rolSeleccionado == 'Sin rol' ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      // faltan datos obligatorios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, completa todos los campos obligatorios.')),
      );
    } else if (_rolSeleccionado == 'Profesor' &&
        (_materiaSeleccionada == null || _horarios.isEmpty)) {
      // el profesor no completó materia y horarios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Los profesores deben seleccionar una materia y un horario.')),
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

  Future<void> _guardarSesion(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', _email);
    await prefs.setString('rol', _rolSeleccionado);
    await prefs.setString('nombre', _nom);  // Si quieres guardar más datos, lo puedes hacer aquí
    await prefs.setInt('userid', id);
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
                User newUser = User(
                  nombre: _nom,
                  email: _email,
                  fechanacimiento: _fechan,
                  telefono: _telefono,
                  rol: _rolSeleccionado,
                  idMateria: _rolSeleccionado == 'Profesor' ? _materiaSeleccionada?.id : null,
                  horario: _rolSeleccionado == 'Profesor' ? _horarios : null,
                  password: _password, // En un caso real, deberías encriptar la contraseña
                );

                // Guardar en la base de datos
                int id=await MentorMeDatabase.instance.insertUser(newUser);

                _guardarSesion(id);
                Navigator.pushReplacementNamed(context, 'home'); 
              },
            ),
          ],
        );
      },
    );
  }
}
