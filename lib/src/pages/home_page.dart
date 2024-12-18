import 'package:flutter/material.dart';
import 'package:mentorme/src/pages/admin/admin_page.dart';
import 'package:mentorme/src/pages/tutorias/a_confirmar_page.dart';
import 'package:mentorme/src/pages/tutorias/pendientes_page.dart';
import 'package:mentorme/src/pages/perfil_page.dart';
import 'package:mentorme/src/pages/tutorias/tutorias_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _rol;
  bool? _loggedin;
  @override
  @override
  void initState() {
    super.initState();
    _loadNombreUsuario(); // Cargar el rol en initState
  }

  // Método para obtener el valor almacenado
  Future<void> _loadNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rol = prefs.getString('rol');
      _loggedin=prefs.getBool('isLoggedIn');
    });

    if (_loggedin == null || _loggedin == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, 'welcome');
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if(_rol == null){
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title:  Text("MentorMe",style: TextStyle(color: Colors.amber[800])),
        automaticallyImplyLeading: false,
      ),
      body: _selectedIndex == 0 
        ? _rol=='admin'
          ? const AdminPage()
          : const TutoriasPage()
        : _selectedIndex == 1
          ? _rol=='Alumno'
            ?const PendientesPage()
            : const ConfirmarPage()
          :const PerfilPage(),
      bottomNavigationBar: _rol!='admin'
      ? BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tutorias',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: _rol=='Profesor'?'Confirmar Tutorias':'Nueva Tutoria',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      )
      :null,
    );
  }
}