class Producto {
  final String sku;
  final String nombre;
  final String descripcion;
  final double costo;
  final String urlImagen;
  // La existencia y la lista de ubicaciones ya no viven aquí

  Producto({
    required this.sku,
    required this.nombre,
    required this.descripcion,
    required this.costo,
    required this.urlImagen,
  });
}