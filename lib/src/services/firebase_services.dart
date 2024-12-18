import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/notificacion.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';

class FirebaseServices {
  static final FirebaseServices instance = FirebaseServices();

  final CollectionReference users;
  final CollectionReference materias;
  final CollectionReference tutorias;
  final CollectionReference notificaciones;

  // Constructor
  FirebaseServices()
      : users = FirebaseFirestore.instance.collection("Users"),
        materias = FirebaseFirestore.instance.collection("Materias"),
        tutorias = FirebaseFirestore.instance.collection("Tutorias"),
        notificaciones =
            FirebaseFirestore.instance.collection("Notificaciones");

  // ------------Materias ------------
  Future<List<Materia>> getAllMateriasFB() async {
    List<Materia> mat = [];
    try {
      QuerySnapshot snapshot = await materias.get();
      for (var d in snapshot.docs) {
        Map<String, dynamic> data = d.data() as Map<String, dynamic>;
        data['id'] = d
            .id; // Potencial mejora: Considerar usar un método centralizado para asignar 'id' y mapear los datos.
        if (data['nombre'] != null) mat.add(Materia.fromMap(data));
      }
    } catch (e) {
      print("Error al obtener materias: $e");
    }
    return mat;
  }

  Future<void> insertarMateria(Materia mat) async {
    await materias.add(mat.toMap());
  }

  Future<void> updateMateria(Materia mat) async {
    await materias.doc(mat.id).update({"nombre": mat.nombre});
  }

  Future<Materia?> getMateriaById(String id) async {
    Materia? mat;
    final DocumentSnapshot doc = await materias.doc(id).get();
    mat =
        doc.exists ? Materia.fromMap(doc.data() as Map<String, dynamic>) : null;
    return mat;
  }

  // ------------Usuarios ------------
  Future<User?> getUserLogin(String email, String password) async {
    User? user;
    try {
      QuerySnapshot snapshot = await users
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data =
            snapshot.docs[0].data() as Map<String, dynamic>;
        data['id'] = snapshot.docs[0].id;
        user = User.fromMap(data);
      }
    } catch (e) {
      print("Error al obtener usuario: $e");
    }
    return user;
  }

  Future<String> insertUser(User user) async {
    String id = '';
    await users
        .add(user.toMap())
        .then((documentSnapshot) => id = documentSnapshot.id);
    return id;
  }

  Future<User?> getUserById(String id) async {
    try {
      final DocumentSnapshot doc = await users.doc(id).get();

      if (!doc.exists) {
        print("El documento con ID $id no existe.");
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        print("No hay datos en el documento.");
        return null;
      }

      data['id'] = doc.id;
      return User.fromMap(data);
    } catch (e) {
      print("Error al encontrar el usuario: $e");
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    await users.doc(user.id).update(user.toMap());
  }

  Future<List<User>> getProfesoresbyMateria(String idMateria) async{
    List<User> profesores=[];
    QuerySnapshot snapshot = await users.where('idMateria',arrayContains: idMateria).get();
    for(var doc in snapshot.docs){
      Map<String,dynamic> data= doc.data() as Map<String,dynamic>;
      data['id'] = doc.id;
      User u= User.fromMap(data);
      profesores.add(u);
    }
    return profesores;
  }

  //------------Tutorias ------------
  Future<List<Map<String, dynamic>>> getTutorias(String rol, String id) async {
    List<Map<String, dynamic>> t = [];
    String idrol = rol == "Alumno" ? "idAlumno" : "idProfesor";
    QuerySnapshot snapshot = await tutorias.where(idrol, isEqualTo: id).get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      t.add(data);
    }
    return t;
  }

  Future<void> updateTutoria(String? id, Map<String, dynamic> map) async {
    await tutorias.doc(id!).update(map);
  }

  Future<void> deleteTutoria(Tutoria t) async {
    await tutorias.doc(t.id).delete();
    User? profesor = await instance.getUserById(t.idProfesor);
    Materia? materia = await instance.getMateriaById(t.idMateria);
    Notificacion n = Notificacion(
        titulo:
            "Tutoria para el ${DateFormat("dd/MM/yyyy").format(t.dia)} fue Rechazada",
        mensaje:
            "${profesor?.nombre ?? "El/La profesor/a"} rechazo la tutoria ${materia?.nombre != null ? "de ${materia!.nombre}" : ''} propuesta para el dia ${DateFormat("dd/MM/yyyy").format(t.dia)}. Contactate con tu profesor(a) ${profesor?.telefono != null ? "a número su telefono ${profesor?.telefono}" : ''} para saber el motivo o solicita una tutoria con otro/a profesor(a).",
        idUsuario: t.idAlumno,
        timestamp: DateTime.timestamp());
    await instance.insertNotificacion(n);
  }

  Future<void> insertTutoria(Tutoria t) async{
    await tutorias.add(t.toMap());
  }

  

  // ------------Notificaciones ------------
  Future<void> insertNotificacion(Notificacion n) async{
    await notificaciones.add(n.toMap());
  }
}
