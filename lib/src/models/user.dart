class User {
  final int? id;
  final String email;
  final String password;
  final String nombre;
  final DateTime fechanacimiento;
  final String telefono;
  final String rol;
  final int? idMateria;
  final String? horario;

  User(
      {this.id,
      required this.email,
      required this.password,
      required this.nombre,
      required this.fechanacimiento,
      required this.telefono,
      required this.rol,
      this.idMateria,
      this.horario});

  Map<String,dynamic> toMap(){
    return{
      'id': id,
      'email': email,
      'password': password,
      'nombre': nombre,
      'fechanacimiento': fechanacimiento.toIso8601String(),
      'telefono': telefono,
      'rol':rol,
      'idMateria': idMateria,
      'horario': horario,
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
      idMateria: map['idMateria'],
      horario: map['horario']
    );
  }
}
