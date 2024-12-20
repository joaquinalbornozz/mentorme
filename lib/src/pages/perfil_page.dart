import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? rol;
  String? foto;
  String? userid;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getFoto() async {
    final User? user = await FirebaseServices.instance.getUserById(userid!);
    if (user != null) {
      setState(() {
        foto = user.fotoperfil;
      });
    } else {
      Navigator.pushReplacementNamed(context, 'welcome');
    }
  }

  Future<void> _getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rol = prefs.getString('rol');
      userid = prefs.getString('userid');
    });
    if (rol == null || userid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, 'welcome');
      });
    }
    await _getFoto();
  }

  void _navigateToPage(String pageName) {
    Navigator.pushNamed(context, pageName);
  }

  Future<void> _cerrarSesion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('rol');
    prefs.remove('userid');
    prefs.remove('isLoggedIn');
    prefs.remove('email');
    prefs.remove('nombre');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    List<Widget> commonOptions = [
      _buildListTile(
        icon: Icons.person_outline,
        title: 'Modificar perfil',
        onTap: () => _navigateToPage('modificarperfil'),
        responsive: responsive,
      ),
      _buildListTile(
        icon: Icons.logout,
        title: 'Cerrar Sesión',
        onTap: () => _showConfirmationDialog(),
        responsive: responsive,
      ),
    ];

    List<Widget> alumnoOptions = [
      _buildListTile(
        icon: Icons.history,
        title: 'Historial de Tutorías',
        onTap: () => _navigateToPage('historial'),
        responsive: responsive,
      ),
      _buildListTile(
        icon: Icons.analytics,
        title: 'Estadísticas',
        onTap: () => _navigateToPage('estadistica'),
        responsive: responsive,
      ),
      _buildListTile(
        icon: Icons.school_outlined,
        title: 'Seguimiento por Profesor',
        onTap: () => _navigateToPage('seguimiento'),
        responsive: responsive,
      ),
    ];

    List<Widget> profesorOptions = [
      _buildListTile(
        icon: Icons.history,
        title: 'Historial de Tutorías',
        onTap: () => _navigateToPage('historial'),
        responsive: responsive,
      ),
      _buildListTile(
        icon: Icons.assignment,
        title: 'Asignar y calificar Tareas',
        onTap: () => _navigateToPage('asignar'),
        responsive: responsive,
      ),
      _buildListTile(
        icon: Icons.analytics,
        title: 'Estadísticas',
        onTap: () => _navigateToPage('estadistica'),
        responsive: responsive,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(responsive.dp(2.5)),
        child: ListView(
          children: [
            Center(
                child: CircleAvatar(
              radius: responsive.wp(20),
              foregroundColor: Colors.amber[800],
              backgroundImage: foto != null && foto!.isNotEmpty
                  ? MemoryImage(base64Decode(foto!))
                  : const AssetImage('assets/images/user.png'),
            )),
            if (rol == 'Alumno') ...alumnoOptions,
            if (rol == 'Profesor') ...profesorOptions,
            ...commonOptions,
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Deseas cerrar sesión en este dispositivo?'),
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
                _cerrarSesion();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Responsive responsive,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: responsive.dp(1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: responsive.dp(3), color: Colors.deepOrange),
        title: Text(
          title,
          style: TextStyle(
            fontSize: responsive.dp(2),
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: responsive.dp(2.5),
          color: Colors.grey,
        ),
      ),
    );
  }
}
