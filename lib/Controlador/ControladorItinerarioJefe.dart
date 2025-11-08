import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';
import 'ControladorItinerario.dart';

class ControladorItinerarioJefe {
  /// Obtiene la lista de usuarios de nivel 1 (asociados) junto con su progreso
  /// calculado a partir de las tareas asignadas (completadas/total).
  static Future<List<Map<String, dynamic>>> obtenerAsociadosConProgreso() async {
    try {
      final usuariosResp = await SupabaseConfig.client.from('usuarios').select('id,nombre,nivel').eq('nivel', 1);
      final usuarios = (usuariosResp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final List<Map<String, dynamic>> out = [];
      for (final u in usuarios) {
        final uid = u['id'] is int ? u['id'] as int : int.tryParse('${u['id']}') ?? 0;
        // contar tareas
        final totalResp = await SupabaseConfig.client.from('tareas').select('id').eq('usuario_id', uid);
        final total = (totalResp as List).length;
        // contar completadas o revisadas
        final doneResp = await SupabaseConfig.client
            .from('tareas')
            .select('id')
            .eq('usuario_id', uid)
            .filter('estado', 'in', ['completada', 'revisada']);
        final done = (doneResp as List).length;
        final porcentaje = total == 0 ? 0.0 : (done / total) * 100.0;

        out.add({
          'id': uid,
          'nombre': u['nombre'] ?? 'N/D',
          'nivel': u['nivel'] ?? 1,
          'total_tareas': total,
          'completadas': done,
          'porcentaje': porcentaje,
        });
      }
      return out;
    } catch (e) {
      print('Error obtenerAsociadosConProgreso: $e');
      return [];
    }
  }

  /// Obtiene todas las tareas de un usuario (todas las estados)
  static Future<List<Map<String, dynamic>>> obtenerTareasPorUsuario(int usuarioId) async {
    try {
      final resp = await SupabaseConfig.client.from('tareas').select().eq('usuario_id', usuarioId).order('fecha_asignacion', ascending: false);
      return (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error obtenerTareasPorUsuario: $e');
      return [];
    }
  }

  /// Asigna una tarea a un usuario (cambia usuario_id)
  static Future<bool> asignarTareaAUsuario(int tareaId, int usuarioId) async {
    try {
      // obtener usuario actual de la tarea
      final tareaRec = await SupabaseConfig.client.from('tareas').select('usuario_id').eq('id', tareaId).maybeSingle();
      final prevUser = (tareaRec != null && (tareaRec as Map).containsKey('usuario_id')) ? (tareaRec['usuario_id'] is int ? tareaRec['usuario_id'] as int : int.tryParse('${tareaRec['usuario_id']}') ?? 0) : null;

      // si ya está asignada al mismo usuario, no hacemos cambios
      if (prevUser != null && prevUser == usuarioId) return true;

      // actualizar la tarea
      await SupabaseConfig.client.from('tareas').update({'usuario_id': usuarioId}).eq('id', tareaId);

      // decrementar total_bahias del usuario previo (si aplica y no es el sentinel 186187)
      if (prevUser != null && prevUser != 186187) {
        final cbPrev = await SupabaseConfig.client.from('control_bahias').select('id,total_bahias').eq('usuario_id', prevUser).maybeSingle();
        if (cbPrev != null) {
          final mapPrev = Map<String, dynamic>.from(cbPrev as Map);
          final current = (mapPrev['total_bahias'] is int) ? (mapPrev['total_bahias'] as int) : int.tryParse('${mapPrev['total_bahias']}') ?? 0;
          final newVal = (current - 1) < 0 ? 0 : (current - 1);
          await SupabaseConfig.client.from('control_bahias').update({'total_bahias': newVal}).eq('id', mapPrev['id']);
        }
      }

      // incrementar total_bahias del usuario destino (si no es sentinel)
      if (usuarioId != 186187) {
        final cbDest = await SupabaseConfig.client.from('control_bahias').select('id,total_bahias,completadas').eq('usuario_id', usuarioId).maybeSingle();
        if (cbDest == null) {
          await SupabaseConfig.client.from('control_bahias').insert({'usuario_id': usuarioId, 'total_bahias': 1, 'completadas': 0});
        } else {
          final mapDest = Map<String, dynamic>.from(cbDest as Map);
          final current = (mapDest['total_bahias'] is int) ? (mapDest['total_bahias'] as int) : int.tryParse('${mapDest['total_bahias']}') ?? 0;
          await SupabaseConfig.client.from('control_bahias').update({'total_bahias': current + 1}).eq('id', mapDest['id']);
        }
      }

      return true;
    } catch (e) {
      print('Error asignarTareaAUsuario: $e');
      return false;
    }
  }

  /// Desasigna una tarea: pone usuario_id = 186187 if estado == 'pendiente'
  static Future<bool> desasignarTarea(int tareaId) async {
    try {
      // obtener info de la tarea (estado y usuario actual)
      final tarea = await SupabaseConfig.client.from('tareas').select('estado,usuario_id').eq('id', tareaId).maybeSingle();
      final mapT = tarea != null ? Map<String, dynamic>.from(tarea as Map) : {};
      final estado = mapT.containsKey('estado') ? (mapT['estado'] ?? '') : '';
      final prevUser = mapT.containsKey('usuario_id') && mapT['usuario_id'] != null ? (mapT['usuario_id'] is int ? mapT['usuario_id'] as int : int.tryParse('${mapT['usuario_id']}') ?? 0) : null;
      if (estado != 'pendiente') return false; // solo pendientes se pueden quitar

      // actualizar la tarea a sentinel (sin asignar)
      await SupabaseConfig.client.from('tareas').update({'usuario_id': 186187}).eq('id', tareaId);

      // decrementar total_bahias del usuario previo si corresponde
      if (prevUser != null && prevUser != 186187) {
        final cbPrev = await SupabaseConfig.client.from('control_bahias').select('id,total_bahias').eq('usuario_id', prevUser).maybeSingle();
        if (cbPrev != null) {
          final mapPrev = Map<String, dynamic>.from(cbPrev as Map);
          final current = (mapPrev['total_bahias'] is int) ? (mapPrev['total_bahias'] as int) : int.tryParse('${mapPrev['total_bahias']}') ?? 0;
          final newVal = (current - 1) < 0 ? 0 : (current - 1);
          await SupabaseConfig.client.from('control_bahias').update({'total_bahias': newVal}).eq('id', mapPrev['id']);
        }
      }

      return true;
    } catch (e) {
      print('Error desasignarTarea: $e');
      return false;
    }
  }

  /// Lista tareas sin asignar (usuario_id = 186187)
  static Future<List<Map<String, dynamic>>> listarTareasSinAsignar() async {
    try {
      final resp = await SupabaseConfig.client.from('tareas').select().eq('usuario_id', 186187).order('fecha_asignacion', ascending: false);
      return (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error listarTareasSinAsignar: $e');
      return [];
    }
  }

  /// Registra una evaluación para una tarea (usa ControladorItinerario existente)
  static Future<bool> evaluarTarea(int tareaId, int evaluadorId, String comentarios, double puntaje) async {
    return await ControladorItinerario.registrarEvaluacion(tareaId, evaluadorId, comentarios, puntaje);
  }

  /// Resumen global de tareas: total y completadas
  static Future<Map<String, int>> obtenerResumenTareasGlobal() async {
    try {
      final allResp = await SupabaseConfig.client.from('tareas').select('id');
      final completedResp = await SupabaseConfig.client
          .from('tareas')
          .select('id')
          .filter('estado', 'in', ['completada', 'revisada']);
      final int total = (allResp as List).length;
      final int done = (completedResp as List).length;
      return {'total': total, 'completadas': done};
    } catch (e) {
      print('Error obtenerResumenTareasGlobal: $e');
      return {'total': 0, 'completadas': 0};
    }
  }

  /// Obtiene la lista de asociados (nivel 1) junto con el promedio de calificaciones
  /// de sus tareas que están en estado 'revisada'. Esta función invoca la
  /// función SQL registrada en la base de datos: obtener_promedio_asociados().
  static Future<List<Map<String, dynamic>>> obtenerPromedioAsociados() async {
    try {
      final data = await SupabaseConfig.client.rpc('obtener_promedio_asociados');
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Error en obtenerPromedioAsociados: $e');
      return [];
    }
  }

  /// Obtiene el detalle de tareas (todas las tareas) para un asociado concreto
  /// Invoca la función RPC 'obtener_detalle_asociado' en la base de datos.
  static Future<List<Map<String, dynamic>>> obtenerTareasDetalleAsociado(int asociadoId) async {
    try {
      final data = await SupabaseConfig.client.rpc(
        'obtener_detalle_asociado',
        params: {'p_usuario_id': asociadoId},
      );
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      return [];
    } catch (e) {
      print('Error en obtenerTareasDetalleAsociado: $e');
      return [];
    }
  }
}
