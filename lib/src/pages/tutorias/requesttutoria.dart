import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NuevaTutoriaPage extends StatefulWidget {
  const NuevaTutoriaPage({super.key});

  @override
  _NuevaTutoriaPageState createState() => _NuevaTutoriaPageState();
}

class _NuevaTutoriaPageState extends State<NuevaTutoriaPage> {
  int? _materiaSeleccionadaId;
  int? _profesorSeleccionadoId;
  DateTime? _fechaSeleccionada;
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  // Future para obtener todas las materias
  Future<List<Materia>> _getMaterias() async {
    return await MentorMeDatabase.instance.getAllMaterias();
  }

  // Future para obtener los profesores por materia
  Future<List<User>> _getProfesoresPorMateria(int idMateria) async {
    return await MentorMeDatabase.instance.getProfesoresbyMateria(idMateria);
  }

  // Función para seleccionar una fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text =
            "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tutoría'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(5),
          vertical: responsive.hp(2),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Selecciona una Materia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<Materia>>(
                future: _getMaterias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final materias = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        border: OutlineInputBorder(),
                      ),
                      value: _materiaSeleccionadaId,
                      items: materias.map((materia) {
                        return DropdownMenuItem<int>(
                          value: materia.id,
                          child: Text(materia.nombre),
                        );
                      }).toList(),
                      onChanged: (int? materiaId) {
                        setState(() {
                          _materiaSeleccionadaId = materiaId;
                          _profesorSeleccionadoId = null;
                        });
                      },
                    );
                  } else {
                    return const Text('No hay materias disponibles');
                  }
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Selecciona un Profesor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_materiaSeleccionadaId != null)
                FutureBuilder<List<User>>(
                  future: _getProfesoresPorMateria(_materiaSeleccionadaId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final profesores = snapshot.data!;
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Profesor',
                          border: OutlineInputBorder(),
                        ),
                        value: _profesorSeleccionadoId,
                        items: profesores.map((profesor) {
                          return DropdownMenuItem<int>(
                            value: profesor.id,
                            child: Text(
                                '${profesor.nombre} - ${profesor.horario}'),
                          );
                        }).toList(),
                        onChanged: (int? profesorId) {
                          setState(() {
                            _profesorSeleccionadoId = profesorId;
                          });
                        },
                      );
                    } else {
                      return const Text('No hay profesores disponibles');
                    }
                  },
                ),
              const SizedBox(height: 20),

              const Text(
                'Selecciona una Fecha',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Tutoría',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _seleccionarFecha(context),
              ),
              const SizedBox(height: 20),

              const Text(
                'Descripción de la Tutoría',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              if (_fechaSeleccionada != null &&
                  _profesorSeleccionadoId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_descripcionController.text.isNotEmpty) {
                        _crearTutoria(
                          idAlumno: 1,
                          idProfesor: _profesorSeleccionadoId!,
                          dia: _fechaSeleccionada!,
                          descripcion: _descripcionController.text,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Por favor, ingresa una descripción.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Crear Tutoría'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearTutoria({
    required int idAlumno,
    required int idProfesor,
    required DateTime dia,
    required String descripcion,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idAlumno = prefs.getInt('userid');
    if (idAlumno != null) {
      final nuevaTutoria = Tutoria(
        idAlumno: idAlumno,
        idProfesor: idProfesor,
        dia: dia,
        descripcion: descripcion,
      );
      await MentorMeDatabase.instance.insertTutoria(nuevaTutoria);
      Navigator.pop(context, true);
    } else {
      Navigator.pushNamed(context, 'welcome');
    }
  }
}
