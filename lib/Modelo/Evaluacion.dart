// ============================
// MODELO: Evaluacion
// ============================
class Evaluacion {
  final int id;
  final int tareaId;
  final int evaluadorId;
  final String? comentarios;
  final DateTime fecha;
  final double puntaje;

  Evaluacion({
    required this.id,
    required this.tareaId,
    required this.evaluadorId,
    this.comentarios,
    required this.fecha,
    required this.puntaje,
  });

  factory Evaluacion.fromMap(Map<String, dynamic> map) {
    return Evaluacion(
      id: map['id'],
      tareaId: map['tarea_id'],
      evaluadorId: map['evaluador_id'],
      comentarios: map['comentarios'],
      fecha: DateTime.parse(map['fecha']),
      puntaje: map['puntaje'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'evaluador_id': evaluadorId,
      'comentarios': comentarios,
      'fecha': fecha.toIso8601String(),
      'puntaje': puntaje,
    };
  }
}
