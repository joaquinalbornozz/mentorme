import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';

class ConfirmarTutoriaPage extends StatefulWidget {
  final Tutoria tutoria;

  const ConfirmarTutoriaPage({super.key, required this.tutoria});

  @override
  _ConfirmarTutoriaPageState createState() => _ConfirmarTutoriaPageState();
}

class _ConfirmarTutoriaPageState extends State<ConfirmarTutoriaPage> {
  bool isLoading = false;

  Future<void> _confirmar(Tutoria tutoria) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseServices.instance
        .updateTutoria(tutoria.id, {'confirmada': true});
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _rechazar(Tutoria tutoria) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseServices.instance.deleteTutoria(tutoria);
    setState(() {
      isLoading = false;
    });
  }

  Future<User?> getAlumno() async {
    return await FirebaseServices.instance.getUserById(widget.tutoria.idAlumno);
  }

  Future<Materia?> getMateria() async {
    return await FirebaseServices.instance
        .getMateriaById(widget.tutoria.idMateria);
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tutoría'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indicador de carga
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: getAlumno(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        final url = user?.fotoperfil != null &&
                                user!.fotoperfil!.isNotEmpty
                            ? user.fotoperfil
                            : null;
                        return Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: url != null
                                    ? NetworkImage(url)
                                    : const AssetImage(
                                        'assets/images/user.png'),
                                radius: Responsive.of(context).wp(50),
                              ),
                              SizedBox(height: responsive.hp(3)),
                              Text(
                                user != null
                                    ? 'Alumno: ${user.nombre}'
                                    : 'Alumno no encontrado',
                                style: TextStyle(
                                  fontSize: responsive.dp(3),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: responsive.hp(2)),
                              Text(user != null ? user.descripcion! : '',
                                  style: TextStyle(
                                    fontSize: responsive.dp(2),
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }),
                  const SizedBox(height: 10),
                  FutureBuilder(
                      future: getMateria(),
                      builder: (context, snapshot) {
                        final materia = snapshot.data;
                        return Text(
                          'Materia: ${materia!.nombre}',
                          style: TextStyle(
                            fontSize: responsive.dp(3),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                  Text(
                    'Fecha: ${widget.tutoria.dia.toLocal()}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descripción: ${widget.tutoria.descripcion}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _confirmar(widget.tutoria);
                          Navigator.pop(context, 'confirmada');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('Confirmar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _rechazar(widget.tutoria);
                          Navigator.pop(context, 'rechazada');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Rechazar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
