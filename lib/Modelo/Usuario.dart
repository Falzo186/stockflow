// ============================
// MODELO: Usuario
// ============================
class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final int nivel; // 1=Asociado, 2=Jefatura Met, 3=RH, 4=Gerente
  final DateTime fechaIngreso;
  final String? telefono;
  final int? horarioId;
  final bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.nivel,
    required this.fechaIngreso,
    this.telefono,
    this.horarioId,
    this.activo = true,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      correo: map['correo'],
      contrasena: map['contrasena'],
      nivel: map['nivel'],
      fechaIngreso: DateTime.parse(map['fecha_ingreso']),
      telefono: map['telefono'],
      horarioId: map['horario_id'],
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'nivel': nivel,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'telefono': telefono,
      'horario_id': horarioId,
      'activo': activo,
    };
  }
}
