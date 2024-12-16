import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/user.dart';
class FirebaseServices {
  static final FirebaseServices instance= FirebaseServices();
  final FirebaseFirestore _db;

  // Referencias a las colecciones
  final CollectionReference users;
  final CollectionReference materias;
  final CollectionReference tutorias;

  // Constructor
  FirebaseServices()
      : _db= FirebaseFirestore.instance,
        users = FirebaseFirestore.instance.collection("Users"),
        materias = FirebaseFirestore.instance.collection("Materias"), 
        tutorias = FirebaseFirestore.instance.collection("Tutorias");

  // Obtener todas las materias desde Firestore
  Future<List<Materia>> getAllMateriasFB() async {
    List<Materia> mat = [];
    try {
      QuerySnapshot snapshot = await materias.get();
      for (var d in snapshot.docs) {
        Map<String, dynamic> data = d.data() as Map<String, dynamic>;
        data['id'] = d.id; // Potencial mejora: Considerar usar un método centralizado para asignar 'id' y mapear los datos.
        if (data['nombre'] != null) mat.add(Materia.fromMap(data));
      }
    } catch (e) {
      print("Error al obtener materias: $e"); 
    }
    return mat;
  }

  // Obtener usuario por email y contraseña
  Future<User?> getUserLogin(String email, String password) async {
    User? user;
    try {
      QuerySnapshot snapshot = await users
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get(); 
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs[0].data() as Map<String, dynamic>;
        data['id'] = snapshot.docs[0].id;
        user = User.fromMap(data);
      }
    } catch (e) {
      print("Error al obtener usuario: $e"); 
    }
    return user;
  }

  Future<void> insertarMateria(Materia mat) async {
    await materias.add(mat.toMap());
  }

  Future<void> updateMateria(Materia mat) async{
    await materias.doc(mat.id).update({"nombre":mat.nombre});
  }
}
