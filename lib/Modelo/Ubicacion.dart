class Ubicacion {
  final String id; // ej. "01012"
  final String? descripcion;
  final String? area;
  final DateTime? ultimoServicio;
  final bool over;
  final bool pop;
  final bool estorbo;

  Ubicacion({
    required this.id,
    this.descripcion,
    this.area,
    this.ultimoServicio,
    this.over = false,
    this.pop = false,
    this.estorbo = false,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        id: json['id'],
        descripcion: json['descripcion'],
        area: json['area'],
        ultimoServicio: json['ultimo_servicio'] != null
            ? DateTime.parse(json['ultimo_servicio'])
            : null,
        over: json['over'] ?? false,
        pop: json['pop'] ?? false,
        estorbo: json['estorbo'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'descripcion': descripcion,
        'area': area,
        'ultimo_servicio': ultimoServicio?.toIso8601String(),
        'over': over,
        'pop': pop,
        'estorbo': estorbo,
      };
}
