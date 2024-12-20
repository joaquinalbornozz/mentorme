import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutoriasPage extends StatefulWidget {
  const TutoriasPage({super.key});

  @override
  _TutoriasPageState createState() => _TutoriasPageState();
}

class _TutoriasPageState extends State<TutoriasPage> {
  List<Map<String, dynamic>> tutorias = [];
  String? rol;
  String? userName;
  String? userid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FirebaseServices db = FirebaseServices.instance;
      rol = prefs.getString('rol');
      userName = prefs.getString('nombre');
      userid = prefs.getString('userid');

      if (rol == null || userid == null) {
        Navigator.pushNamed(context, 'welcome');
        return;
      }

      final allTutorias = await db.getTutorias(rol!, userid!);
      final confirmedTutorias = allTutorias.where((tutoria) {
        return tutoria['confirmada'] &&
            DateTime.parse(tutoria['dia']).isAfter(DateTime.now());
      }).toList();

      for (var tutoria in confirmedTutorias) {
        tutoria['tutoria'] = Tutoria.fromMap(tutoria);
        if (rol == 'Profesor') {
          User? userAlu = await db.getUserById(tutoria['idAlumno']);
          tutoria['nombreAlu'] = userAlu?.nombre ?? "Desconocido";
        } else {
          User? userPro = await db.getUserById(tutoria['idProfesor']);
          tutoria['nombrePro'] = userPro?.nombre ?? "Desconocido";
        }
        Materia? materia = await db.getMateriaById(tutoria['idMateria']);
        tutoria['nombreMateria'] =
            materia != null ? materia.nombre : "Materia Desconocida";
        print(materia != null ? materia.nombre : 'no se encuentra la materia');
      }

      setState(() {
        tutorias = confirmedTutorias;
      });
    } catch (e) {
      print("Error al cargar las tutorías: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ocurrió un error al cargar las tutorías')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlumno = rol == 'Alumno';
    final responsive = Responsive(context);
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Permite desplazamiento
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido, $userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        // Cambiado de Row a Wrap para evitar overflow
                        spacing: 16, // Espaciado horizontal
                        runSpacing: 16, // Espaciado vertical
                        alignment: WrapAlignment.center,
                        children: isAlumno
                            ? [
                                _buildBotonAccion(context,
                                    icon: Icons.person_search,
                                    title: 'Profesores',
                                    color: Colors.white, onPressed: () {
                                  Navigator.pushNamed(context, 'profesores');
                                }),
                                _buildBotonAccion(context,
                                    icon: Icons.school_outlined,
                                    title: 'Seguimiento por\n Profesor',
                                    color: Colors.white, onPressed: () {
                                  Navigator.pushNamed(context, 'seguimiento');
                                }),
                              ]
                            : [
                                _buildBotonAccion(context,
                                    icon: Icons.assignment,
                                    title: 'Asignar y\n calificar Tareas',
                                    color: Colors.white, onPressed: () {
                                  Navigator.pushNamed(context, 'asignar');
                                }),
                                _buildBotonAccion(context,
                                    icon: Icons.book,
                                    title: 'Agregar Materias',
                                    color: Colors.white,
                                    onPressed: (){
                                      Navigator.pushNamed(context, 'materiaprofesor');
                                    })
                              ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Proximas Tutorias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    tutorias.isEmpty
                        ? const Text(
                            'No tienes tutorías pendientes.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        : SizedBox(
                            height: responsive.hp(60), // Ajuste dinámico
                            child: ListView.builder(
                              itemCount: tutorias.length,
                              itemBuilder: (context, index) {
                                final tutoria = tutorias[index];
                                final formattedDate = DateFormat('dd/MM/yyyy')
                                    .format(tutoria['tutoria'].dia);
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    title: Text(
                                      isAlumno
                                          ? 'Profesor: ${tutoria['nombrePro']}'
                                          : 'Alumno: ${tutoria['nombreAlu']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Materia: ${tutoria['nombreMateria']}\nFecha: $formattedDate',
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TutoriaPage(
                                            tutoria: tutoria['tutoria']),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isAlumno
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, 'requestTutoria');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBotonAccion(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = constraints.maxWidth / 3;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(16.0),
            backgroundColor: color,
            minimumSize: Size(buttonSize, buttonSize),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.amber[800]),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.amber[800],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
