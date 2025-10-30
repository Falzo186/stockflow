// ============================
// MODELO: Producto (actualizado)
// ============================
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String? categoria;
  final String? proveedor;
  final bool enPromocion;
  final int? idPromocion;
  final String rango; // A-Z
  final bool cambioPrecio;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    this.categoria,
    this.proveedor,
    this.enPromocion = false,
    this.idPromocion,
    this.rango = 'M',
    this.cambioPrecio = false,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      precio: (map['precio'] as num).toDouble(),
      stock: map['stock'],
      categoria: map['categoria'],
      proveedor: map['proveedor'],
      enPromocion: map['en_promocion'] ?? false,
      idPromocion: map['id_promocion'],
      rango: map['rango'] ?? 'M',
      cambioPrecio: map['cambio_precio'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'categoria': categoria,
      'proveedor': proveedor,
      'en_promocion': enPromocion,
      'id_promocion': idPromocion,
      'rango': rango,
      'cambio_precio': cambioPrecio,
    };
  }

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        precio: (json['precio'] as num).toDouble(),
        stock: json['stock'],
        categoria: json['categoria'],
        proveedor: json['proveedor'],
        enPromocion: json['en_promocion'] ?? false,
        idPromocion: json['id_promocion'],
        rango: json['rango'] ?? 'M',
        cambioPrecio: json['cambio_precio'] ?? false,
      );
}
