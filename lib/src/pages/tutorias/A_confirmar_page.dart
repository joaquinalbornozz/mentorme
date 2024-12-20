import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/confirmar_tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmarPage extends StatefulWidget {
  const ConfirmarPage({super.key});

  @override
  _ConfirmarPageState createState() => _ConfirmarPageState();
}

class _ConfirmarPageState extends State<ConfirmarPage> {
  List<Map<String, dynamic>> tutorias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idProfesor = prefs.getString('userid');
    if (idProfesor == null) {
      Navigator.pushNamed(context, 'welcome');
      return;
    }
    final List<Map<String, dynamic>> allTutorias =
        await FirebaseServices.instance.getTutorias('Profesor', idProfesor);
    final List<Map<String, dynamic>> pendientes =
        allTutorias.where((tutoria) => !tutoria['confirmada']).toList();

    for (var tutoria in pendientes) {
      tutoria['tutoria'] = Tutoria.fromMap(tutoria);
      User? userAlumno =
          await FirebaseServices.instance.getUserById(tutoria['idAlumno']);
      tutoria['alumno'] = userAlumno?.nombre ?? "Desconocido";
    }

    setState(() {
      tutorias = pendientes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchTutorias,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutorías a Confirmar',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    tutorias.isEmpty
                        ? const Text(
                            'No tienes tutorías pendientes de confirmación.',
                            style: TextStyle(fontSize: 16, color: Colors.grey))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: tutorias.length,
                              itemBuilder: (context, index) {
                                final tutoria = tutorias[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    title: Text(
                                      'Alumno: ${tutoria['alumno']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Fecha: ${DateFormat('dd/MM/yyyy').format(tutoria['tutoria'].dia)}',
                                    ),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () async {
                                      final String? resultado =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmarTutoriaPage(
                                                  tutoria: tutoria['tutoria']),
                                        ),
                                      );
                                      fetchTutorias();
                                      if (resultado == 'confirmada') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'La Tutoria fue Confirmada')),
                                        );
                                      } else if(resultado=='rechazada'){
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'La Tutoria fue rechazada')),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
