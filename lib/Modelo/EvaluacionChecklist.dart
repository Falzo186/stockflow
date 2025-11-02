class EvaluacionChecklist {
  final int id;
  final int checklistId;
  final int? evaluadorId;
  final String? observaciones;
  final bool? aprobado;
  final DateTime fecha;

  EvaluacionChecklist({
    required this.id,
    required this.checklistId,
    this.evaluadorId,
    this.observaciones,
    this.aprobado,
    required this.fecha,
  });

  factory EvaluacionChecklist.fromMap(Map<String, dynamic> map) {
    return EvaluacionChecklist(
      id: map['id'],
      checklistId: map['checklist_id'],
      evaluadorId: map['evaluador_id'],
      observaciones: map['observaciones'],
      aprobado: map['aprobado'],
      fecha: DateTime.parse(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklist_id': checklistId,
      'evaluador_id': evaluadorId,
      'observaciones': observaciones,
      'aprobado': aprobado,
      'fecha': fecha.toIso8601String(),
    };
  }
}
