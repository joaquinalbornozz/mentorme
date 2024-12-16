class User {
  final String? id;
  final String email;
  final String password;
  final String nombre;
  final DateTime fechanacimiento;
  final String telefono;
  final String rol;
  final List<String>? idMateria;
  final String? horario;
  final String? descripcion;
  final String? fotoperfil;

  User(
      {this.id,
      required this.email,
      required this.password,
      required this.nombre,
      required this.fechanacimiento,
      required this.telefono,
      required this.rol,
      this.idMateria,
      this.horario,
      this.descripcion,
      this.fotoperfil});

  Map<String,dynamic> toMap(){
    return{
      //'id': id,
      'email': email,
      'password': password,
      'nombre': nombre,
      'fechanacimiento': fechanacimiento.toIso8601String(),
      'telefono': telefono,
      'rol':rol,
      if(idMateria!=null)'idMateria': idMateria,
      if(horario!=null)'horario': horario,
      if(descripcion!=null)'descripcion': descripcion,
      if(fotoperfil!=null)'fotoperfil': fotoperfil,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      nombre: map['nombre'],
      fechanacimiento: DateTime.parse(map['fechanacimiento']),
      telefono: map['telefono'],
      rol: map['rol'],
      idMateria: List.from(map['idMateria']),
      horario: map['horario'],
      descripcion: map['descripcion'],
      fotoperfil: map['fotoperfil'],
    );
  }
}
