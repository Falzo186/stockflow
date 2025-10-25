import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';
import 'package:stockflow/Modelo/ProductoUbicacion.dart';

class ControladorSurtido {

  Future<List<ProductoUbicacion>> buscarProductosBahia(String bahiaId) async {
    try {
      final response = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .select()
          .eq('ubicacion_id', bahiaId);

      if (response == null) return [];

      return (response as List)
          .map((json) => ProductoUbicacion.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al buscar productos de bahía $bahiaId: $e');
      return [];
    }
  }

  /// Crea entradas en la tabla `producto_ubicaciones` para los niveles que tengan cantidad > 0.
  /// Devuelve true si la operación tuvo éxito.
  Future<bool> createProductEntries(String bahiaId, String productoId,
      {int stockPv = 0, int stockOver = 0}) async {
    try {
      // Usar createOrUpdateLevel para evitar conflictos de PK y duplicados
      if (stockPv > 0) {
        final ok = await createOrUpdateLevel(bahiaId, productoId, 'pv', stockPv);
        if (!ok) return false;
      }
      if (stockOver > 0) {
        final ok = await createOrUpdateLevel(bahiaId, productoId, 'over', stockOver);
        if (!ok) return false;
      }

      return true;
    } catch (e) {
      print('Error creando entradas para $productoId en bahía $bahiaId: $e');
      return false;
    }
  }

  /// Inserta una fila para un solo nivel (pv/over).
  Future<bool> insertProductLevel(String bahiaId, String productoId, String nivel, int cantidad) async {
    try {
      // Reuse createOrUpdateLevel for safe insert-or-update behavior
      return await createOrUpdateLevel(bahiaId, productoId, nivel, cantidad);
    } catch (e) {
      print('Error insertando nivel $nivel para $productoId en $bahiaId: $e');
      return false;
    }
  }

  /// Crea o actualiza la fila para (ubicacion_id, producto_id, nivel).
  /// Si existe, actualiza `cantidad`; si no existe, inserta una nueva fila.
  Future<bool> createOrUpdateLevel(String bahiaId, String productoId, String nivel, int cantidad) async {
    try {
      // Primero intentar actualizar (si existe la fila para esa combinación)
      final updateResp = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .update({'cantidad': cantidad})
          .match({'ubicacion_id': bahiaId, 'producto_id': productoId, 'nivel': nivel});

      if (updateResp != null) {
        // Si la respuesta trae filas (lista no vacía), la actualización se hizo
        try {
          final list = updateResp as List;
          if (list.isNotEmpty) return true;
        } catch (_) {
          // Si no es una lista, igualmente consideramos éxito
          return true;
        }
      }

      // Si no se actualizó nada, intentamos insertar.
      final insertResp = await SupabaseConfig.client.from('producto_ubicaciones').insert({
        'ubicacion_id': bahiaId,
        'producto_id': productoId,
        'nivel': nivel,
        'cantidad': cantidad,
      });
      return insertResp != null;
    } catch (e) {
      print('Error al createOrUpdateLevel $productoId nivel $nivel en $bahiaId: $e');
      return false;
    }
  }

  /// Actualiza la cantidad de un producto para un nivel dado.
  Future<bool> updateProductLevelQuantity(String bahiaId, String productoId, String nivel, int cantidad) async {
    try {
      final response = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .update({'cantidad': cantidad})
          .match({'ubicacion_id': bahiaId, 'producto_id': productoId, 'nivel': nivel});

      return response != null;
    } catch (e) {
      print('Error actualizando cantidad de $productoId nivel $nivel en $bahiaId: $e');
      return false;
    }
  }

  /// Elimina todas las entradas de un producto en una bahía (todos los niveles).
  Future<bool> deleteProduct(String bahiaId, String productoId) async {
    try {
      final response = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .delete()
          .match({'ubicacion_id': bahiaId, 'producto_id': productoId});

      return response != null;
    } catch (e) {
      print('Error eliminando producto $productoId en bahía $bahiaId: $e');
      return false;
    }
  }

}