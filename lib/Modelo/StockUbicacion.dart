// archivo: modelos_producto.dart

// --- NUEVA CLASE PARA LA "TABLA RELACIÓN" ---
class StockUbicacion {
  final String idRelacion;
  final String skuProducto;   // "Foreign Key" a Producto
  final String idUbicacion;   // "Foreign Key" a Ubicacion
  final int cantidad;         // La cantidad vive AQUÍ

  StockUbicacion({
    required this.idRelacion,
    required this.skuProducto,
    required this.idUbicacion,
    required this.cantidad,
  });
}

