import 'package:path/path.dart';
import '../models/materia.dart';
import '../models/tutoria.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';

class MentorMeDatabase {
  static final MentorMeDatabase instance = MentorMeDatabase._init();
  static Database? _database;

  MentorMeDatabase._init();

  final String tableUsers = 'users';
  final String tableMaterias = 'materias'; 
  final String tabletutorias='tutorias';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mentorme.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
    );
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Auto-increment ID
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        nombre TEXT NOT NULL,
        fechanacimiento DATE NOT NULL,
        telefono TEXT NOT NULL,
        rol TEXT NOT NULL,
        idMateria INTEGER,  -- Optional, can be NULL
        horario TEXT         -- Optional, can be NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMaterias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tutorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Clave primaria con AUTOINCREMENT
        idAlumno INTEGER NOT NULL,
        idProfesor INTEGER NOT NULL,
        dia DATE NOT NULL,  
        descripcion TEXT NOT NULL,
        confirmada INTEGER NOT NULL,  -- 0 (false) o 1 (true)
        devolucion TEXT,
        calificacionalumno INTEGER,
        calificacionProfesor INTEGER,
        tareasAsignadas TEXT,
        notasSeguimiento TEXT
      );
    ''');
    await db.insert(tableUsers, {
      'email': 'admin@gmail.com',
      'password': '12345678',
      'nombre':'admin',
      'fechanacimiento': DateTime.timestamp().toIso8601String(),
      'telefono': '1234567890',
      'rol': 'admin',
      });
    await db.insert(tableMaterias, {'nombre': 'Matemáticas'});
    await db.insert(tableMaterias, {'nombre': 'Programación web'});
    await db.insert(tableMaterias, {'nombre': 'Historia'});
    await db.insert(tableMaterias, {'nombre': 'Ciencias'});
    await db.insert(tableMaterias, {'nombre': 'Lengua y Literatura'});
    await db.insert(tableUsers,{
      'email': 'juan.perez@mail.com',
      'password': 'password123',
      'nombre': 'Juan Pérez',
      'fechanacimiento': DateTime(1995, 5, 10).toIso8601String(),
      'telefono': '5557121234',
      'rol': 'Alumno', // o 'Profesor'
    });
    await db.insert(tableUsers,{
      'email': 'juana.perez@mail.com',
      'password': 'password123',
      'nombre': 'Juana Sol',
      'fechanacimiento': DateTime(1995, 5, 10).toIso8601String(),
      'telefono': '5557121234',
      'rol': 'Profesor', 
      'idMateria': 1, // Si es profesor, tiene una materia asignada
      'horario': '8:00 AM - 10:00 AM',
    });
    // Inserción de profesores en la base de datos
    await db.insert(tableUsers, {
      'email': 'juana1.perez@mail.com',
      'password': 'password123',
      'nombre': 'Juana Sol',
      'fechanacimiento': DateTime(1995, 5, 10).toIso8601String(),
      'telefono': '5557121234',
      'rol': 'Profesor',
      'idMateria': 1, // Materia ID 1
      'horario': '8:00 AM - 10:00 AM',
    });

    await db.insert(tableUsers, {
      'email': 'carlos.fernandez@mail.com',
      'password': 'password456',
      'nombre': 'Carlos Fernández',
      'fechanacimiento': DateTime(1987, 3, 25).toIso8601String(),
      'telefono': '5557654321',
      'rol': 'Profesor',
      'idMateria': 2, // Materia ID 2
      'horario': '10:00 AM - 12:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'ana.martinez@mail.com',
      'password': 'password789',
      'nombre': 'Ana Martínez',
      'fechanacimiento': DateTime(1992, 7, 19).toIso8601String(),
      'telefono': '5551234567',
      'rol': 'Profesor',
      'idMateria': 3, // Materia ID 3
      'horario': '1:00 PM - 3:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'luis.gonzalez@mail.com',
      'password': 'password101',
      'nombre': 'Luis González',
      'fechanacimiento': DateTime(1985, 11, 5).toIso8601String(),
      'telefono': '5559876543',
      'rol': 'Profesor',
      'idMateria': 4, // Materia ID 4
      'horario': '3:00 PM - 5:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'maria.lopez@mail.com',
      'password': 'password202',
      'nombre': 'María López',
      'fechanacimiento': DateTime(1990, 6, 15).toIso8601String(),
      'telefono': '5554567890',
      'rol': 'Profesor',
      'idMateria': 1, // Materia ID 1, repetida
      'horario': '9:00 AM - 11:00 AM',
    });

    await db.insert(tableUsers, {
      'email': 'pedro.garcia@mail.com',
      'password': 'password303',
      'nombre': 'Pedro García',
      'fechanacimiento': DateTime(1988, 9, 27).toIso8601String(),
      'telefono': '5556781234',
      'rol': 'Profesor',
      'idMateria': 5, // Materia ID 5
      'horario': '11:00 AM - 1:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'rosa.sanchez@mail.com',
      'password': 'password404',
      'nombre': 'Rosa Sánchez',
      'fechanacimiento': DateTime(1983, 2, 14).toIso8601String(),
      'telefono': '5552345678',
      'rol': 'Profesor',
      'idMateria': 3, // Materia ID 3, repetida
      'horario': '12:00 PM - 2:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'miguel.ramos@mail.com',
      'password': 'password505',
      'nombre': 'Miguel Ramos',
      'fechanacimiento': DateTime(1991, 8, 30).toIso8601String(),
      'telefono': '5553456789',
      'rol': 'Profesor',
      'idMateria': 2, // Materia ID 2, repetida
      'horario': '2:00 PM - 4:00 PM',
    });

    await db.insert(tableUsers, {
      'email': 'luisa.diaz@mail.com',
      'password': 'password606',
      'nombre': 'Luisa Díaz',
      'fechanacimiento': DateTime(1989, 4, 21).toIso8601String(),
      'telefono': '5558765432',
      'rol': 'Profesor',
      'idMateria': 5, // Materia ID 5, repetida
      'horario': '4:00 PM - 6:00 PM',
    });
    //tutorias
    await db.insert(tabletutorias, 
    {
      'idAlumno': 2, 
      'idProfesor': 3, 
      'dia': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 
      'descripcion': 'Tutoría sobre matemáticas básicas',
      'confirmada':1,
      'devolucion': '',
      'calificacionalumno': 0,
      'calificacionProfesor': 0,

    }
    );

    await db.insert(tabletutorias, 
      {
        'idAlumno': 2, 
        'idProfesor': 8, 
        'dia': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(), 
        'descripcion': 'Tutoría sobre álgebra lineal',
        'confirmada': 1,
        'devolucion': 'Explicación clara y precisa.',
        'calificacionalumno': 4,
        'calificacionProfesor': 5,
        'tareasAsignadas': 'Resolver ecuaciones lineales',
        'notasSeguimiento': 'Ha mejorado en la resolución de sistemas de ecuaciones'
      }
    );

    await db.insert(tabletutorias, 
      {
        'idAlumno': 2, 
        'idProfesor': 9, 
        'dia': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(), 
        'descripcion': 'Tutoría sobre cálculo diferencial',
        'confirmada': 1,
        'devolucion': 'Gran comprensión en derivadas básicas.',
        'calificacionalumno': 5,
        'calificacionProfesor': 4,
        'tareasAsignadas': 'Practicar derivadas',
        'notasSeguimiento': 'Comprende el concepto de límites y derivadas'
      }
    );

    await db.insert(tabletutorias, 
      {
        'idAlumno': 2, 
        'idProfesor': 10, 
        'dia': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(), 
        'descripcion': 'Tutoría sobre geometría analítica',
        'confirmada': 1,
        'devolucion': 'Excelente manejo de vectores.',
        'calificacionalumno': 4,
        'calificacionProfesor': 5,
        'tareasAsignadas': 'Estudiar propiedades de vectores',
        'notasSeguimiento': 'Ha avanzado en la interpretación de coordenadas'
      }
    );

    await db.insert(tabletutorias, 
      {
        'idAlumno': 2, 
        'idProfesor': 11, 
        'dia': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(), 
        'descripcion': 'Tutoría sobre física mecánica',
        'confirmada': 1,
        'devolucion': 'Entiende bien los principios básicos.',
        'calificacionalumno': 3,
        'calificacionProfesor': 4,
        'tareasAsignadas': 'Revisar las leyes de Newton',
        'notasSeguimiento': 'Progreso en comprensión de fuerzas y movimiento'
      }
    );

    await db.insert(tabletutorias, 
      {
        'idAlumno': 2, 
        'idProfesor': 12, 
        'dia': DateTime.now().subtract(const Duration(days: 35)).toIso8601String(), 
        'descripcion': 'Tutoría sobre programación en Python',
        'confirmada': 1,
        'devolucion': 'Excelente en estructuras de control.',
        'calificacionalumno': 5,
        'calificacionProfesor': 5,
        'tareasAsignadas': 'Escribir funciones recursivas',
        'notasSeguimiento': 'Sigue progresando en lógica de programación'
      }
    );

    
  }

  //Users

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert(tableUsers, user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableUsers);
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        email: maps[i]['email'],
        password: maps[i]['password'],
        nombre: maps[i]['nombre'],
        fechanacimiento: DateTime.parse(maps[i]['fechanacimiento']),
        telefono: maps[i]['telefono'],
        rol: maps[i]['rol'],
        idMateria: maps[i]['idMateria'],
        horario: maps[i]['horario'],
      );
    });
  }
  Future<User?> getUserbyId(int id) async {
    final db= await instance.database;
    final List<Map<String,dynamic>> resultado=await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return resultado.isNotEmpty ? User.fromMap(resultado[0]):null;
  }

  Future<List<User>> getProfesoresbyMateria(int id) async {
    final db= await instance.database;
    final List<Map<String,dynamic>> resultado=await db.query(
      'users',
      where: 'idMateria = ?',
      whereArgs: [id],
    );
    return List.generate(resultado.length, (i) {
      return User.fromMap(resultado[i]);
    });
  }

  Future<User?> getUserLogin(String email, String password) async {
    final db= await instance.database;
    final List<Map<String,dynamic>> resultado=await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return resultado.isNotEmpty ? User.fromMap(resultado[0]):null;
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableUsers,
      where: "id = ?",
      whereArgs: [id],
    );
  }
  
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      tableUsers,
      user.toMap(),
      where: "id=?",
      whereArgs: [user.id],
    );
  }

  //Materias

  Future<void> insertMateria(Materia materia) async {
    final db = await instance.database;
    await db.insert(tableMaterias, materia.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Materia>> getAllMaterias() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableMaterias);

    return List.generate(maps.length, (i) {
      return Materia(
        id: maps[i]['id'],
        nombre: maps[i]['nombre'],
      );
    });
  }

  Future<Materia?> getMateriaById(int? id) async {
    if(id==null) return null;
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMaterias,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Materia.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteMateria(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableMaterias,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateMateria(Materia materia) async {
    final db = await instance.database;
    return await db.update(
      tableMaterias,
      materia.toMap(),
      where: 'id = ?',
      whereArgs: [materia.id],
    );
  }

  //Tutorias
  Future<void> insertTutoria(Tutoria tutoria) async {
    final db = await instance.database;
    await db.insert(
      tabletutorias,
      tutoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tutoria>> getTutorias() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tabletutorias);
    
    return List.generate(maps.length, (i) {
      return Tutoria.fromMap(maps[i]);
    });
  }

  Future<int> updateTutoria(Tutoria tutoria) async {
    final db = await instance.database;
    return await db.update(
      tabletutorias,
      tutoria.toMap(),
      where: 'id = ? AND idAlumno = ? AND idProfesor = ? AND dia = ?',
      whereArgs: [tutoria.id, tutoria.idAlumno, tutoria.idProfesor, tutoria.dia.toIso8601String()],
    );
  }

  Future<List<User>> getProfesoresPorAlumno(int aluId) async {
    final db = await instance.database;
    
    List<Map<String, dynamic>> tutorias = await db.query(
      tabletutorias,
      where: 'idAlumno = ?',
      whereArgs: [aluId],
    );

    List<User> profesores = [];

    for (var tutoria in tutorias) {
      List<Map<String, dynamic>> p = await db.query(
        tableUsers,
        where: 'id = ?',
        whereArgs: [tutoria['idProfesor']],
      );
      
      if (p.isNotEmpty) {
        User profesor = User.fromMap(p[0]);
        if (!profesores.any((p) => p.id == profesor.id)) {
          profesores.add(profesor);
        }
      }
    }

    return profesores;
  }

  Future<List<Tutoria>> getTutoriasPorProfesorYAlumno(int idprof, int idAlu) async {
    final db= await instance.database;
    List<Map<String,dynamic>> maps= await db.query(
      tabletutorias,
      where: 'idAlumno = ? AND idProfesor = ?',
      whereArgs: [idAlu,idprof]
    );
    return List.generate(maps.length, (i){
      return Tutoria.fromMap(maps[i]);
    });
  }
  Future<List<Tutoria>> getTutoriasByIdAlu(int? idAlu) async {
    final db= await instance.database;
    List<Map<String,dynamic>> maps= await db.query(
      tabletutorias,
      where: 'idAlumno = ?',
      whereArgs: [idAlu]
    );
    return List.generate(maps.length, (i){
      return Tutoria.fromMap(maps[i]);
    });
  }

  Future<List<Tutoria>> getTutoriasByIdProf(int? idProf) async {
    final db= await instance.database;
    List<Map<String,dynamic>> maps= await db.query(
      tabletutorias,
      where: 'idProfesor = ?',
      whereArgs: [idProf]
    );
    return List.generate(maps.length, (i){
      return Tutoria.fromMap(maps[i]);
    });
  }

  Future<int> deleteTutoria(Tutoria tutoria) async {
    final db = await instance.database;
    return await db.delete(
      tabletutorias,
      where: 'id = ? AND idAlumno = ? AND idProfesor = ? AND dia = ?',
      whereArgs: [tutoria.id, tutoria.idAlumno, tutoria.idProfesor, tutoria.dia.toIso8601String()],
    );
  }
}




