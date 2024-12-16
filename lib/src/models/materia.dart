class Materia {
  final String? id;
  final String nombre;

  Materia({this.id, required this.nombre});

  Map<String, dynamic> toMap() {
    return {
      if(id!=null) 'id': id,
      'nombre': nombre,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}
