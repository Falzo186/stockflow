import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';

class ControladorBahias {
  /// Obtiene el registro más reciente de control_bahias para un usuario.
  /// Retorna null si no existe registro.
  static Future<Map<String, dynamic>?> obtenerUltimoControlUsuario(int usuarioId) async {
    try {
      final resp = await SupabaseConfig.client
          .from('control_bahias')
          .select('id,usuario_id,total_bahias,completadas,porcentaje,fecha')
          .eq('usuario_id', usuarioId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      if (resp == null) return null;
      return Map<String, dynamic>.from(resp as Map);
    } catch (e) {
      // Propagar o retornar null en caso de error de conexión
      return null;
    }
  }

  /// Lista histórico de control_bahias para un usuario (opcional)
  static Future<List<Map<String, dynamic>>> listarHistoricoUsuario(int usuarioId, {int limit = 50}) async {
    try {
      final resp = await SupabaseConfig.client
          .from('control_bahias')
          .select('id,usuario_id,total_bahias,completadas,porcentaje,fecha')
          .eq('usuario_id', usuarioId)
          .order('fecha', ascending: false)
          .limit(limit);

  final data = resp as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
