class ProductoUbicacion {
  final int id;
  final int productoId;
  final String ubicacionId;
  final String nivel; //over o pv
  final int cantidad;

  ProductoUbicacion({
    required this.id,
    required this.productoId,
    required this.ubicacionId,
    required this.nivel,
    required this.cantidad,
  });

  factory ProductoUbicacion.fromJson(Map<String, dynamic> json) =>
      ProductoUbicacion(
        id: json['id'],
        productoId: json['producto_id'],
        ubicacionId: json['ubicacion_id'],
        nivel: json['nivel'],
        cantidad: json['cantidad'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'producto_id': productoId,
        'ubicacion_id': ubicacionId,
        'nivel': nivel,
        'cantidad': cantidad,
      };
}
 