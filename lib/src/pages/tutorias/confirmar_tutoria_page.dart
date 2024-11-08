import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/tutoria.dart';

class ConfirmarTutoriaPage extends StatelessWidget {
  final Tutoria tutoria;

  const ConfirmarTutoriaPage({super.key, required this.tutoria});
  Future<void> _confirmar(Tutoria tutoria) async {
    tutoria.confirmada=true;
    //print(tutoria.toMap());
    MentorMeDatabase db=MentorMeDatabase.instance;
    db.updateTutoria(tutoria);
  }

  Future<void> _rechazar(Tutoria tutoria) async {
    MentorMeDatabase db=MentorMeDatabase.instance;
    db.deleteTutoria(tutoria);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tutoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${tutoria.dia.toLocal()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Descripción: ${tutoria.descripcion}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _confirmar(tutoria);
                    Navigator.pop(context, 'confirmada');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Confirmar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _rechazar(tutoria);
                    Navigator.pop(context, 'rechazada');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
