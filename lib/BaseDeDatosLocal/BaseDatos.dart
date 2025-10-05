// archivo: base_de_datos_simulada.dart



import '../Modelo/Producto.dart';
import '../Modelo/StockUbicacion.dart';
import '../Modelo/Ubicacion.dart';

class BaseDeDatosSimulada {

  // --- "TABLA" DE TODAS LAS UBICACIONES POSIBLES EN LA TIENDA ---
  final List<Ubicacion> _mapaDeUbicaciones = [
    Ubicacion(id: '05108', area: 'Iluminación'),
    Ubicacion(id: '08012', area: 'Iluminación'),
    Ubicacion(id: '01CA1', area: 'Bodega'),
    Ubicacion(id: '01CA2', area: 'Bodega'),
    Ubicacion(id: '02005', area: 'Ferretería'),
  ];

  // --- "TABLA" DE TODOS LOS PRODUCTOS DISPONIBLES (CATÁLOGO) ---
  final List<Producto> _catalogoDeProductos = [
    Producto(
      sku: '202399',
      nombre: 'Foco LED 13W Luz Blanca',
      descripcion: 'FOCO LED LEDVANCE 13 W 1500 LÚMENES LUZ BLANCA',
      costo: 36.00,
      urlImagen: '',
    ),
    Producto(
      sku: '505810',
      nombre: 'Martillo de Goma',
      descripcion: 'MARTILLO CON CABEZA DE GOMA Y MANGO DE MADERA',
      costo: 120.00,
      urlImagen: '',
    ),
  ];

  // --- "TABLA RELACIÓN" (LA MÁS IMPORTANTE) ---
  // Nos dice QUÉ producto está en QUÉ ubicación y en QUÉ cantidad.
  final List<StockUbicacion> _inventarioGeneral = [
    // El Foco LED (202399) está en 3 lugares distintos
    StockUbicacion(idRelacion: '1', skuProducto: '202399', idUbicacion: '05108', cantidad: 50),
    StockUbicacion(idRelacion: '2', skuProducto: '202399', idUbicacion: '08012', cantidad: 30),
    StockUbicacion(idRelacion: '3', skuProducto: '202399', idUbicacion: '01CA2', cantidad: 120),
    
    // El Martillo (505810) está en 2 lugares distintos
    StockUbicacion(idRelacion: '4', skuProducto: '505810', idUbicacion: '02005', cantidad: 15),
    StockUbicacion(idRelacion: '5', skuProducto: '505810', idUbicacion: '01CA1', cantidad: 5),
  ];


  // --- MÉTODOS PARA "CONSULTAR" LA BASE DE DATOS ---

  /// Busca un producto en el catálogo por su SKU.
  Producto? buscarProductoPorSku(String sku) {
    try {
      return _catalogoDeProductos.firstWhere((p) => p.sku == sku);
    } catch (e) {
      return null;
    }
  }

  /// Busca una ubicación por su ID.
  Ubicacion? buscarUbicacionPorId(String id) {
     try {
      return _mapaDeUbicaciones.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Devuelve todas las entradas de inventario para un SKU específico.
  /// USE CASE: "Ver todas las ubicaciones de un producto".
  List<StockUbicacion> obtenerStockParaProducto(String sku) {
    return _inventarioGeneral.where((stock) => stock.skuProducto == sku).toList();
  }

  /// Devuelve todas las entradas de inventario para una ubicación específica.
  /// USE CASE: "Ver todos los productos en una ubicación".
  List<StockUbicacion> obtenerProductosEnUbicacion(String idUbicacion) {
    return _inventarioGeneral.where((stock) => stock.idUbicacion == idUbicacion).toList();
  }
  
  /// Calcula la existencia total de un producto sumando las cantidades de todas sus ubicaciones.
  int calcularExistenciaTotal(String sku) {
    final stocks = obtenerStockParaProducto(sku);
    if (stocks.isEmpty) return 0;
    return stocks.map((s) => s.cantidad).reduce((a, b) => a + b);
  }
}