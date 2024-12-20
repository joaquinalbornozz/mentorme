import 'dart:convert';
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
    Navigator.pop(context, 'confirmada');
  }

  Future<void> _rechazar(Tutoria tutoria) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseServices.instance.deleteTutoria(tutoria);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context, 'rechazada');
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
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(5),
                    vertical: responsive.hp(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<User?>(
                        future: getAlumno(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar el alumno');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('Alumno no encontrado');
                          } else {
                            final user = snapshot.data!;
                            final url = user.fotoperfil != null &&
                                    user.fotoperfil!.isNotEmpty
                                ? user.fotoperfil
                                : null;

                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.only(bottom: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: url != null
                                          ? MemoryImage(base64Decode(url))
                                          : const AssetImage(
                                                  'assets/images/user.png')
                                              as ImageProvider,
                                      radius: responsive.wp(15),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      user.nombre,
                                      style: TextStyle(
                                        fontSize: responsive.dp(2.5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (user.descripcion != null)
                                      Text(
                                        user.descripcion!,
                                        style: TextStyle(
                                          fontSize: responsive.dp(2),
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      FutureBuilder<Materia?>(
                        future: getMateria(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar la materia');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('Materia no encontrada');
                          } else {
                            final materia = snapshot.data!;
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  materia.nombre,
                                  style: TextStyle(
                                    fontSize: responsive.dp(2.5),
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
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity, // Ocupa todo el ancho posible
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha:',
                                style: TextStyle(
                                  fontSize: responsive.dp(2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.tutoria.dia.toLocal().toString(),
                                style: TextStyle(
                                  fontSize: responsive.dp(2),
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Descripción:',
                                style: TextStyle(
                                  fontSize: responsive.dp(2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.tutoria.descripcion,
                                style: TextStyle(
                                  fontSize: responsive.dp(2),
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async =>
                                await _confirmar(widget.tutoria),
                            icon: const Icon(Icons.check),
                            label: const Text('Confirmar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async =>
                                await _rechazar(widget.tutoria),
                            icon: const Icon(Icons.close),
                            label: const Text('Rechazar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
