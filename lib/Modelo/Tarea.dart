// ============================
// MODELO: Tarea (Itinerario)
// ============================
class Tarea {
  final int id;
  final int usuarioId;
  final String ubicacionId;
  final DateTime fechaAsignacion;
  final DateTime? fechaRealizacion;
  final String estado; // pendiente, en_progreso, completada, revisada
  final String? observaciones;
  final Map<String, dynamic>? checklist;
  final int? evaluadoPor;
  final double? calificacion;

  Tarea({
    required this.id,
    required this.usuarioId,
    required this.ubicacionId,
    required this.fechaAsignacion,
    this.fechaRealizacion,
    this.estado = 'pendiente',
    this.observaciones,
    this.checklist,
    this.evaluadoPor,
    this.calificacion,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      usuarioId: map['usuario_id'],
      ubicacionId: map['ubicacion_id'],
      fechaAsignacion: DateTime.parse(map['fecha_asignacion']),
      fechaRealizacion: map['fecha_realizacion'] != null
          ? DateTime.parse(map['fecha_realizacion'])
          : null,
      estado: map['estado'] ?? 'pendiente',
      observaciones: map['observaciones'],
      checklist: map['checklist'] != null
          ? Map<String, dynamic>.from(map['checklist'])
          : null,
      evaluadoPor: map['evaluado_por'],
      calificacion: map['calificacion']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'ubicacion_id': ubicacionId,
      'fecha_asignacion': fechaAsignacion.toIso8601String(),
      'fecha_realizacion': fechaRealizacion?.toIso8601String(),
      'estado': estado,
      'observaciones': observaciones,
      'checklist': checklist,
      'evaluado_por': evaluadoPor,
      'calificacion': calificacion,
    };
  }
}
