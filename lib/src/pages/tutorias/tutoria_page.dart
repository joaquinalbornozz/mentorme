import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutoriaPage extends StatefulWidget {
  final Tutoria tutoria;

  const TutoriaPage({super.key, required this.tutoria});

  @override
  _TutoriaPageState createState() => _TutoriaPageState();
}

class _TutoriaPageState extends State<TutoriaPage> {
  String? rol;
  int? ratingProfesor;
  int? ratingAlumno;

  @override
  void initState() {
    super.initState();
    _initializeRole();
    ratingProfesor = widget.tutoria.calificacionProfesor;
    ratingAlumno = widget.tutoria.calificacionalumno;
  }

  Future<User?> getProfesor() async {
    return await FirebaseServices.instance
        .getUserById(widget.tutoria.idProfesor);
  }

  Future<User?> getAlumno() async {
    return await FirebaseServices.instance.getUserById(widget.tutoria.idAlumno);
  }

  Future<Materia?> getMateria(String? idMateria) async {
    print('idMateria$idMateria');
    return idMateria != null
        ? await FirebaseServices.instance.getMateriaById(idMateria)
        : null;
  }

  Future<void> _initializeRole() async {
    rol = await getRol();
    if (rol == null) {
      Navigator.pushNamed(context, 'welcome');
    } else {
      setState(() {});
    }
  }

  Future<String?> getRol() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('rol');
  }

  void _rateProfessor() {
    _showRatingDialog(context, 'Calificar Profesor', (rating) async {
      setState(() {
        ratingProfesor = rating;
        widget.tutoria.calificacionProfesor = rating;
      });
      await FirebaseServices.instance
          .updateTutoria(widget.tutoria.id, {'calificacionProfesor': rating});
    });
  }

  void _rateStudent() {
    _showRatingDialog(context, 'Calificar Alumno', (rating) async {
      setState(() {
        ratingAlumno = rating;
        widget.tutoria.calificacionalumno = rating;
      });
      await FirebaseServices.instance
          .updateTutoria(widget.tutoria.id, {'calificacionalumno': rating});
    });
  }

  void _showRatingDialog(
      BuildContext context, String title, Function(int) onSave) {
    int selectedRating = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: selectedRating,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRating = value;
                    });
                  }
                },
                items: List.generate(5, (index) => index + 1)
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text(val.toString()),
                        ))
                    .toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                onSave(selectedRating);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _completeTutoringDetails() {
    showDialog(
      context: context,
      builder: (context) {
        String? devolucion;
        String? tareasAsignadas;
        String? notaSeguimiento;

        return AlertDialog(
          title: const Text("Completar Detalles de Tutoría"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Devolución'),
                onChanged: (value) => devolucion = value,
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Tareas Asignadas'),
                onChanged: (value) => tareasAsignadas = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nota de Seguimiento',
                ),
                onChanged: (value) => notaSeguimiento = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  widget.tutoria.devolucion = devolucion;
                  widget.tutoria.tareasAsignadas = tareasAsignadas;
                  widget.tutoria.notasSeguimiento = notaSeguimiento;
                });
                await FirebaseServices.instance
                    .updateTutoria(widget.tutoria.id, widget.tutoria.toMap());
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  bool isPastTutoringDate() {
    return widget.tutoria.dia.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de la Tutoría',
          style: TextStyle(
              fontSize: responsive.dp(2.5),
              fontWeight: FontWeight.w500,
              color: Colors.amber[800]),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(5),
                    vertical: responsive.hp(3),
                  ),
            child: rol == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<User?>(
                        future: rol == 'Alumno' ? getProfesor() : getAlumno(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar el alumno');
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('Usuario no encontrado');
                          } else {
                            final User? user = snapshot.data;
                            final url = user?.fotoperfil;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: responsive.wp(17),
                                          backgroundImage:
                                              url != null && url.isNotEmpty
                                                  ? MemoryImage(base64Decode(url))
                                                  : const AssetImage(
                                                      'assets/images/user.png'),
                                        ),
                                        Text(
                                          user != null
                                              ? rol == 'Alumno'
                                                  ? 'Profesor: ${user.nombre}'
                                                  : 'Alumno: ${user.nombre}'
                                              : rol == 'Alumno'
                                                  ? 'Profesor no encontrado'
                                                  : 'Alumno no encontrado',
                                          style: TextStyle(
                                            fontSize: responsive.dp(2),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.dp(2)),
                                FutureBuilder<Materia?>(
                                  future: getMateria(widget.tutoria.idMateria),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                          'Error al cargar la materia');
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Text('Materia no encontrada');
                                    } else {
                                      final Materia? materia = snapshot.data;
                                      return Card(
                                        elevation: 5,
                                        margin: const EdgeInsets.only(bottom: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            materia != null
                                                ? 'Materia: ${materia.nombre}${rol == 'Alumno' ? '\nHorario: ${user?.horario ?? 'Horario no disponible'}' : ''}'
                                                : 'Materia no encontrada',
                                            style: TextStyle(
                                              fontSize: responsive.dp(2),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          leading: const Icon(
                                      Icons.book,
                                      color: Colors.blue,
                                    ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: responsive.dp(2)),
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children:[Text(
                            widget.tutoria.confirmada
                                ? 'Confirmada: Sí'
                                : 'Confirmada: No',
                            style: TextStyle(
                              fontSize: responsive.dp(2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: responsive.dp(2)),
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.tutoria.dia)}',
                            style: TextStyle(
                              fontSize: responsive.dp(1.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: responsive.dp(2)),
                          Text(
                            'Descripción: ${widget.tutoria.descripcion}',
                            style: TextStyle(fontSize: responsive.dp(1.8)),
                          ),
                          if (widget.tutoria.devolucion != null &&
                              widget.tutoria.devolucion!.isNotEmpty)
                            Text(
                              'Devolución:\n ${widget.tutoria.devolucion}',
                              style: TextStyle(fontSize: responsive.dp(1.8)),
                            ),
                          if (widget.tutoria.notasSeguimiento != null &&
                              widget.tutoria.notasSeguimiento!.isNotEmpty)
                            Text(
                              'Notas de Seguimiento:\n ${widget.tutoria.notasSeguimiento}',
                              style: TextStyle(fontSize: responsive.dp(1.8)),
                            ),
                          if (widget.tutoria.tareasAsignadas != null &&
                              widget.tutoria.tareasAsignadas!.isNotEmpty)
                            Text(
                              'Tareas de Seguimiento: \n${widget.tutoria.tareasAsignadas}',
                              style: TextStyle(fontSize: responsive.dp(1.8)),
                            ),]),
                        ),
                      ),
                      if (rol == 'Alumno' && ratingAlumno != null)
                        Text(
                          'Calificación del Alumno: $ratingAlumno',
                          style: TextStyle(fontSize: responsive.dp(1.8)),
                        ),
                      if (rol == 'Profesor' &&
                          ratingProfesor != null &&
                          ratingProfesor != 0)
                        Text(
                          'Calificación del Profesor: $ratingProfesor',
                          style: TextStyle(fontSize: responsive.dp(1.8)),
                        ),
                      SizedBox(height: responsive.dp(3)),
                      if (isPastTutoringDate()) ...[
                        Center(
                          child: Column(
                            children: [
                              if (rol == 'Alumno' && ratingProfesor == null)
                                ElevatedButton(
                                  onPressed: _rateProfessor,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrangeAccent,
                                    textStyle: TextStyle(
                                        fontSize: responsive.dp(1.8),
                                        color: Colors.white),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: responsive.dp(3),
                                        vertical: responsive.dp(1)),
                                  ),
                                  child: const Text('Calificar Profesor'),
                                ),
                              if (rol == 'Profesor' && ratingAlumno == null)
                                ElevatedButton(
                                  onPressed: _rateStudent,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrangeAccent,
                                    textStyle:
                                        TextStyle(fontSize: responsive.dp(1.8)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: responsive.dp(3),
                                        vertical: responsive.dp(1)),
                                  ),
                                  child: const Text('Calificar Alumno'),
                                ),
                              if (rol == 'Profesor' &&
                                  (widget.tutoria.devolucion == null ||
                                      widget.tutoria.notasSeguimiento == null ||
                                      widget.tutoria.tareasAsignadas == null))
                                ElevatedButton(
                                  onPressed: _completeTutoringDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrangeAccent,
                                    textStyle:
                                        TextStyle(fontSize: responsive.dp(1.8)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: responsive.dp(3),
                                        vertical: responsive.dp(1)),
                                  ),
                                  child: const Text("Completar Detalles"),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
