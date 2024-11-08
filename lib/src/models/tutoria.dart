class Tutoria {
  final int? id;
  final int idAlumno;
  final int idProfesor;
  final DateTime dia;
  final String descripcion;
  bool confirmada = false;
  String? devolucion;
  int? calificacionalumno;
  int? calificacionProfesor;
  String? tareasAsignadas; 
  String? notasSeguimiento; 

  Tutoria({
    this.id,
    required this.idAlumno,
    required this.idProfesor,
    required this.dia,
    required this.descripcion,
    this.confirmada=false,
    this.devolucion,
    this.calificacionalumno,
    this.calificacionProfesor,
    this.tareasAsignadas,
    this.notasSeguimiento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idAlumno': idAlumno,
      'idProfesor': idProfesor,
      'dia': dia.toIso8601String(),
      'descripcion': descripcion,
      'confirmada': confirmada ? 1 : 0,
      'devolucion': devolucion,
      'calificacionalumno': calificacionalumno,
      'calificacionProfesor': calificacionProfesor,
      'tareasAsignadas': tareasAsignadas,
      'notasSeguimiento': notasSeguimiento,
    };
  }

  factory Tutoria.fromMap(Map<String, dynamic> map) {
    return Tutoria(
      id: map['id'],
      idAlumno: map['idAlumno'],
      idProfesor: map['idProfesor'],
      dia: DateTime.parse(map['dia']),
      descripcion: map['descripcion'],
      confirmada: map['confirmada'] == 1,
      devolucion: map['devolucion'],
      calificacionalumno: map['calificacionalumno'],
      calificacionProfesor: map['calificacionProfesor'],
      tareasAsignadas: map['tareasAsignadas'],
      notasSeguimiento: map['notasSeguimiento'],
    );
  }
}
