import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';


class ControladorHorarios {
  /// Obtiene la info del horario (JOIN con tabla horarios)
  static Future<Map<String, dynamic>?> obtenerHorarioUsuario(int usuarioId) async {
    try {
      // Seleccionamos el usuario y agregamos el join con horarios (si existe relación)
      final resp = await SupabaseConfig.client
          .from('usuarios')
          .select('*, horarios(*)')
          .eq('id', usuarioId)
          .maybeSingle();

      if (resp == null) return null;
      final Map<String, dynamic> map = Map<String, dynamic>.from(resp as Map);

      // La relación puede venir como lista o como mapa
      // Devolver el mapa completo del usuario (incluye la relación 'horarios')
      return map;
    } catch (e) {
      print('Error en obtenerHorarioUsuario: $e');
      return null;
    }
  }

  /// Inserta la solicitud en la tabla 'solicitudes_descanso'
  static Future<bool> crearSolicitudDescanso({required int usuarioId, required String diasSolicitados}) async {
    try {
      await SupabaseConfig.client.from('solicitudes_descanso').insert({
        'usuario_id': usuarioId,
        'dias_solicitados': diasSolicitados,
        'estado': 'pendiente',
      });
      return true;
    } catch (e) {
      print('Error en crearSolicitudDescanso: $e');
      return false;
    }
  }

  // --- MÉTODOS PARA ADMIN ---

  /// Obtiene las solicitudes pendientes con la info del usuario
  static Future<List<Map<String, dynamic>>> obtenerSolicitudesPendientes() async {
    try {
    final data = await SupabaseConfig.client
      .from('solicitudes_descanso')
      // especificar la relación correcta hacia usuarios (solicitante)
      .select('*, usuarios!solicitudes_descanso_usuario_id_fkey(id,nombre,apellido,correo)')
      .eq('estado', 'pendiente')
      .order('fecha_solicitud', ascending: true);

      final list = data as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error en obtenerSolicitudesPendientes: $e');
      return [];
    }
  }

  /// Obtiene los horarios del equipo (niveles 1 y 2)
  static Future<List<Map<String, dynamic>>> obtenerHorariosEquipo() async {
    try {
      final data = await SupabaseConfig.client
          .from('usuarios')
          .select('id,nombre,apellido,nivel,descanso_personalizado,horarios(*)')
          .filter('nivel', 'in', '(1,2)')
          .order('nombre', ascending: true);

      final list = data as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error en obtenerHorariosEquipo: $e');
      return [];
    }
  }

  /// Aprueba una solicitud usando la función RPC en la base de datos
  static Future<bool> aprobarSolicitud(int solicitudId, int adminId) async {
    try {
      await SupabaseConfig.client.rpc('aprobar_solicitud_descanso', params: {
        'p_solicitud_id': solicitudId,
        'p_admin_id': adminId,
      });
      return true;
    } catch (e) {
      print('Error en aprobarSolicitud: $e');
      return false;
    }
  }

  /// Rechaza una solicitud usando la función RPC en la base de datos
  static Future<bool> rechazarSolicitud(int solicitudId, int adminId, String motivo) async {
    try {
      await SupabaseConfig.client.rpc('rechazar_solicitud_descanso', params: {
        'p_solicitud_id': solicitudId,
        'p_admin_id': adminId,
        'p_motivo': motivo,
      });
      return true;
    } catch (e) {
      print('Error en rechazarSolicitud: $e');
      return false;
    }
  }
}
