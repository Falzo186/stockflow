// ============================
// MODELO: Horario
// ============================
class Horario {
  final int id;
  final String nombre;
  final String diasLaborales; // Ej: "Lunes a Viernes"
  final String? descanso;
  final String horaEntrada;
  final String horaSalida;

  Horario({
    required this.id,
    required this.nombre,
    required this.diasLaborales,
    this.descanso,
    required this.horaEntrada,
    required this.horaSalida,
  });

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'],
      nombre: map['nombre'],
      diasLaborales: map['dias_laborales'],
      descanso: map['descanso'],
      horaEntrada: map['hora_entrada'],
      horaSalida: map['hora_salida'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'dias_laborales': diasLaborales,
      'descanso': descanso,
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
    };
  }
}
