class Notificacion {
  String? id; // ID único de la notificación
  final String titulo;
  final String mensaje;
  final String idUsuario;
  DateTime timestamp;
  bool leida=false;

  Notificacion({
    this.id,
    required this.titulo,
    required this.mensaje,
    required this.idUsuario,
    required this.timestamp,
    this.leida=false,
  });

  // Método para convertir el objeto Notificacion a un Map
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'idUsuario': idUsuario,
      'timestamp': timestamp.toIso8601String(), // Convertir DateTime a String
      'leida': leida,
    };
  }

  // Factory constructor para crear un objeto Notificacion desde un Map
  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id'],
      titulo: map['titulo'],
      mensaje: map['mensaje'] ?? '',
      idUsuario: map['idUsuario'] ?? '',
      timestamp: DateTime.parse(map['timestamp']), // Convertir String a DateTime
      leida: map['leida'] ?? false,
    );
  }
}
