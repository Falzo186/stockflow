class ControlBahias {
  final int id;
  final int usuarioId;
  final int totalBahias;
  final int completadas;
  final double porcentaje;
  final DateTime fecha;

  ControlBahias({
    required this.id,
    required this.usuarioId,
    required this.totalBahias,
    required this.completadas,
    required this.porcentaje,
    required this.fecha,
  });

  factory ControlBahias.fromMap(Map<String, dynamic> map) {
    return ControlBahias(
      id: map['id'],
      usuarioId: map['usuario_id'],
      totalBahias: map['total_bahias'],
      completadas: map['completadas'],
      porcentaje: (map['porcentaje'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'total_bahias': totalBahias,
      'completadas': completadas,
      'porcentaje': porcentaje,
      'fecha': fecha.toIso8601String(),
    };
  }
}
