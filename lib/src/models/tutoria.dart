class Tutoria {
  final String? id;
  final String idAlumno;
  final String idProfesor;
  final String idMateria;
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
    required this.idMateria,
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
      'idMateria': idMateria,
      'dia': dia.toIso8601String(),
      'descripcion': descripcion,
      'confirmada': confirmada ? 1 : 0,
      if(devolucion!=null)'devolucion': devolucion,
      if(calificacionalumno!=null)'calificacionalumno': calificacionalumno,
      if(calificacionProfesor!=null)'calificacionProfesor': calificacionProfesor,
      if(tareasAsignadas!=null)'tareasAsignadas': tareasAsignadas,
      if(notasSeguimiento!=null)'notasSeguimiento': notasSeguimiento,
    };
  }

  factory Tutoria.fromMap(Map<String, dynamic> map) {
    return Tutoria(
      id: map['id'],
      idAlumno: map['idAlumno'],
      idProfesor: map['idProfesor'],
      idMateria: map['idMateria'],
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
