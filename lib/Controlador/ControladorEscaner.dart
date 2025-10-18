import 'package:flutter/services.dart';
import '../BaseDeDatosLocal/SupabaseConfig.dart';
import '../Modelo/Producto.dart';
import '../Modelo/ProductoUbicacion.dart';

class ControladorEscaner {
  final MethodChannel _channel = const MethodChannel('controlador_escaner');

  Future<String?> escanearCodigo() async {
    try {
      final String? codigo = await _channel.invokeMethod('escanearCodigo');
      return codigo;
    } catch (e) {
      print('Error al escanear código: $e');
      return null;
    }
  }

  Future<Producto?> obtenerProductoPorSku(String sku) async {
    try {
      final response = await SupabaseConfig.client
          .from('productos')
          .select()
          .eq('id', sku)
          .maybeSingle(); // retorna null si no hay resultados

      if (response == null) {
        print('Producto no encontrado.');
        return null;
      }

      return Producto.fromJson(response);
    } catch (e) {
      print('Error al buscar producto por SKU: $e');
      return null;
    }
  }
  Future<List<ProductoUbicacion>> obtenerProductoUbicacionesPorId(int productoId) async {
    try {
      final response = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .select()
          .eq('producto_id', productoId);

      return (response as List)
          .map((json) => ProductoUbicacion.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener ubicaciones del producto: $e');
      return [];
    }
  }
  
}
