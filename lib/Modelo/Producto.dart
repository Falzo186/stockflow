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
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        precio: json['precio'].toDouble(),
        stock: json['stock'],
        categoria: json['categoria'],
        proveedor: json['proveedor'],
        enPromocion: json['en_promocion'] ?? false,
        idPromocion: json['id_promocion'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'stock': stock,
        'categoria': categoria,
        'proveedor': proveedor,
        'en_promocion': enPromocion,
        'id_promocion': idPromocion,
      };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'],
        precio: map['precio'].toDouble(),
        stock: map['stock'],
        categoria: map['categoria'],
        proveedor: map['proveedor'],
        enPromocion: map['en_promocion'] ?? false,
        idPromocion: map['id_promocion'],
      );
}
