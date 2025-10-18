class Promocion {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? tipo;
  final double? valor;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  Promocion({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.tipo,
    this.valor,
    this.fechaInicio,
    this.fechaFin,
  });

  factory Promocion.fromJson(Map<String, dynamic> json) => Promocion(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        tipo: json['tipo'],
        valor: json['valor']?.toDouble(),
        fechaInicio: json['fecha_inicio'] != null
            ? DateTime.parse(json['fecha_inicio'])
            : null,
        fechaFin: json['fecha_fin'] != null
            ? DateTime.parse(json['fecha_fin'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'tipo': tipo,
        'valor': valor,
        'fecha_inicio': fechaInicio?.toIso8601String(),
        'fecha_fin': fechaFin?.toIso8601String(),
      };
}
