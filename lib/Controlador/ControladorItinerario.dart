import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';

class ControladorItinerario {
  /// Obtiene las tareas asignadas a un usuario con estado 'pendiente' o 'en_progreso'.
  static Future<List<Map<String, dynamic>>> obtenerTareas(int usuarioId) async {
    try {
      final resp = await SupabaseConfig.client
          .from('tareas')
          .select('id,usuario_id,ubicacion_id,fecha_asignacion,fecha_realizacion,estado,observaciones,checklist,calificacion,evaluado_por')
          .eq('usuario_id', usuarioId)
          .order('fecha_asignacion', ascending: true);

      final data = resp as List<dynamic>;
      // Filtrar en Dart los estados que nos interesan: incluir también las tareas completadas
      final List<Map<String, dynamic>> parsed = data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((m) {
        final estado = (m['estado'] ?? '').toString();
        return estado == 'pendiente' || estado == 'en_progreso' || estado == 'completada' || estado == 'revisada';
      }).toList();
      return parsed;
    } catch (_) {
      return [];
    }
  }

  /// Obtiene una sola tarea por su id.
  static Future<Map<String, dynamic>?> obtenerTareaPorId(int tareaId) async {
    try {
      final resp = await SupabaseConfig.client.from('tareas').select('id,usuario_id,ubicacion_id,estado,fecha_asignacion,fecha_realizacion').eq('id', tareaId).maybeSingle();
      if (resp == null) return null;
      return Map<String, dynamic>.from(resp as Map);
    } catch (e) {
      print('Error obtenerTareaPorId: $e');
      return null;
    }
  }

  /// Marca una tarea como 'en_progreso'
  static Future<bool> iniciarTarea(int tareaId) async {
    try {
      // obtener tarea para saber usuario y estado actual
      final tareaRow = await SupabaseConfig.client.from('tareas').select('usuario_id,estado').eq('id', tareaId).maybeSingle();
      if (tareaRow == null) return false;
      final tareaMap = Map<String, dynamic>.from(tareaRow as Map);
      final estadoActual = (tareaMap['estado'] ?? '').toString();
      final usuarioId = tareaMap['usuario_id'] is int ? tareaMap['usuario_id'] as int : int.tryParse('${tareaMap['usuario_id']}') ?? 0;

      // Si la tarea ya está en progreso, nada que hacer
      if (estadoActual == 'en_progreso') return false;

      // Verificar que el usuario no tenga otra tarea en progreso
      final otherInProgress = await SupabaseConfig.client.from('tareas').select('id').eq('usuario_id', usuarioId).eq('estado', 'en_progreso').neq('id', tareaId).limit(1).maybeSingle();
      if (otherInProgress != null) {
        // ya existe otra tarea en progreso para ese usuario
        return false;
      }

      await SupabaseConfig.client.from('tareas').update({'estado': 'en_progreso'}).eq('id', tareaId);
      return true;
    } catch (e) {
      print('Error iniciarTarea: $e');
      return false;
    }
  }

  /// Completa la tarea: guarda checklist (en campo checklist o tabla checklist_servicio),
  /// actualiza estado a 'completada', setea fecha_realizacion y actualiza control_bahias.
  /// [checklist] es un Map con claves booleans como planograma, displays, limpieza, etc.
  static Future<bool> completarTareaConChecklist(int tareaId, Map<String, dynamic> checklist, int usuarioId) async {
    try {
      // Validación: la tarea debe estar en estado 'en_progreso' y pertenecer al usuario
      final tareaRow = await SupabaseConfig.client.from('tareas').select('estado,usuario_id').eq('id', tareaId).maybeSingle();
      if (tareaRow == null) return false;
      final tareaMap = Map<String, dynamic>.from(tareaRow as Map);
      final estadoActual = (tareaMap['estado'] ?? '').toString();
      final assignedUser = tareaMap['usuario_id'] is int ? tareaMap['usuario_id'] as int : int.tryParse('${tareaMap['usuario_id']}') ?? 0;
      if (estadoActual != 'en_progreso') {
        // no se puede completar una tarea que no ha sido iniciada
        return false;
      }
      if (assignedUser != usuarioId) {
        // seguridad: el usuario que intenta completar no es el asignado
        return false;
      }

      // 1) Actualizar la tarea con checklist y estado
      await SupabaseConfig.client.from('tareas').update({
        'estado': 'completada',
        'checklist': checklist,
        'fecha_realizacion': DateTime.now().toIso8601String(),
      }).eq('id', tareaId);

      // Obtener la ubicacion relacionada con la tarea para actualizar ultimo_servicio
      final tareaLoc = await SupabaseConfig.client.from('tareas').select('ubicacion_id').eq('id', tareaId).maybeSingle();
      String? ubicacionId;
      if (tareaLoc != null && (tareaLoc as Map).containsKey('ubicacion_id')) {
        ubicacionId = (tareaLoc as Map)['ubicacion_id']?.toString();
      }

      // 2) Insertar registro en checklist_servicio (si la tabla existe)
      final Map<String, dynamic> insertData = {
        'servicio_id': tareaId,
        'usuario_id': usuarioId,
        'planograma': checklist['planograma'] ?? false,
        'displays': checklist['displays'] ?? false,
        'pop': checklist['pop'] ?? false,
        'fixture': checklist['fixture'] ?? false,
        'merca_cruzada': checklist['merca_cruzada'] ?? false,
        'seguridad': checklist['seguridad'] ?? false,
        'overhead': checklist['overhead'] ?? false,
        'packdown': checklist['packdown'] ?? false,
        'limpieza': checklist['limpieza'] ?? false,
        'etiquetado': checklist['etiquetado'] ?? false,
      };

      // Intentar insertar; si la columna 'servicio_id' no existe en la tabla
      // (diferentes esquemas usan 'tarea_id' u otro nombre), intentaremos
      // un fallback automático.
      try {
        await SupabaseConfig.client.from('checklist_servicio').insert(insertData);
      } catch (e) {
        final msg = e.toString();
        print('Insert checklist_servicio fallo con servicio_id: $msg');
        // Si el error indica que la columna 'servicio_id' no existe, reintentar
        if (msg.contains("Could not find the 'servicio_id' column") || msg.contains("servicio_id")) {
          final fallback = Map<String, dynamic>.from(insertData);
          fallback.remove('servicio_id');
          fallback['tarea_id'] = tareaId; // usar nombre alternativo común
          try {
            await SupabaseConfig.client.from('checklist_servicio').insert(fallback);
          } catch (e2) {
            print('Insert checklist_servicio fallback fallo: ${e2.toString()}');
          }
        } else {
          // Re-throw para ser capturado por el catch exterior
          rethrow;
        }
      }

  // 3) Actualizar control_bahias: intentar actualizar registro de hoy, si no existe insertar
      final today = DateTime.now().toIso8601String().split('T').first;
      final existing = await SupabaseConfig.client
          .from('control_bahias')
          .select('id,completadas')
          .eq('usuario_id', usuarioId)
          .eq('fecha', today)
          .maybeSingle();

      if (existing != null) {
        // incrementar completadas
        await SupabaseConfig.client.from('control_bahias').update({
          'completadas': (existing['completadas'] as num) + 1,
        }).eq('id', existing['id']);
      } else {
        // crear registro con completadas = 1 (total_bahias debería preexistir o 0)
        await SupabaseConfig.client.from('control_bahias').insert({
          'usuario_id': usuarioId,
          'total_bahias': 0,
          'completadas': 1,
          'fecha': today,
        });
      }

      // 4) Actualizar la tabla 'ubicaciones' con la fecha de ultimo_servicio si tenemos ubicacionId
      if (ubicacionId != null && ubicacionId.isNotEmpty) {
        try {
          await SupabaseConfig.client.from('ubicaciones').update({'ultimo_servicio': today}).eq('id', ubicacionId);
        } catch (e) {
          print('Error actualizando ubicaciones.ultimo_servicio: $e');
        }
      }

      return true;
    } catch (e) {
      print('Error completarTareaConChecklist: $e');
      return false;
    }
  }

  /// Registra una evaluación por un jefe y actualiza la tarea.
  static Future<bool> registrarEvaluacion(int tareaId, int evaluadorId, String comentarios, double puntaje) async {
    try {
      // Insertar evaluación
      await SupabaseConfig.client.from('evaluaciones').insert({
        'tarea_id': tareaId,
        'evaluador_id': evaluadorId,
        'comentarios': comentarios,
        'puntaje': puntaje,
      });

      // Actualizar tarea: evaluado_por, calificacion, estado='revisada'
      await SupabaseConfig.client.from('tareas').update({
        'evaluado_por': evaluadorId,
        'calificacion': puntaje,
        'estado': 'revisada',
      }).eq('id', tareaId);

      return true;
    } catch (e) {
      print('Error registrarEvaluacion: $e');
      return false;
    }
  }

  /// Obtiene una tarea con su campo checklist (si existe)
  static Future<Map<String, dynamic>?> obtenerTareaConChecklist(int tareaId) async {
    try {
      final resp = await SupabaseConfig.client.from('tareas').select('id,checklist').eq('id', tareaId).maybeSingle();
      if (resp == null) return null;
      return Map<String, dynamic>.from(resp as Map);
    } catch (e) {
      print('Error obtenerTareaConChecklist: $e');
      return null;
    }
  }

  /// Guarda una evaluación completa (inserta en evaluaciones y actualiza la tarea).
  static Future<bool> guardarEvaluacion({required int tareaId, required int evaluadorId, required double puntaje, required String comentarios, required Map<String, dynamic> checklistEvaluador}) async {
    try {
      // Insertar la evaluación con el checklist del evaluador (se almacenará como jsonb)
      await SupabaseConfig.client.from('evaluaciones').insert({
        'tarea_id': tareaId,
        'evaluador_id': evaluadorId,
        'comentarios': comentarios,
        'puntaje': puntaje,
        'checklist_evaluador': checklistEvaluador,
      });

      // Actualizar la tarea: evaluado_por, calificacion y estado
      await SupabaseConfig.client.from('tareas').update({
        'evaluado_por': evaluadorId,
        'calificacion': puntaje,
        'estado': 'revisada',
      }).eq('id', tareaId);

      return true;
    } catch (e) {
      print('Error guardarEvaluacion: $e');
      return false;
    }
  }

  /// Obtiene los productos asociados a una ubicación que son rango A/B/C
  /// o que tienen `cambio_precio = true`.
  static Future<List<Map<String, dynamic>>> obtenerProductosParaSurtido(String ubicacionId) async {
    try {
      // 1) obtener product_ids desde producto_ubicaciones
      final resp = await SupabaseConfig.client
          .from('producto_ubicaciones')
          .select('producto_id')
          .eq('ubicacion_id', ubicacionId);

      final ids = (resp as List<dynamic>).map((e) {
        if (e is Map && e.containsKey('producto_id')) return e['producto_id'];
        return null;
      }).where((e) => e != null).cast<int>().toList();

      if (ids.isEmpty) return [];

      // 2) traer los productos por id
  final idList = ids.join(',');
  final prodResp = await SupabaseConfig.client.from('productos').select().filter('id', 'in', '($idList)');
      final products = (prodResp as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // 3) filtrar en Dart: rango A,B,C OR cambio_precio == true
      final filtered = products.where((p) {
        final rango = (p['rango'] ?? '').toString();
        final cambio = p['cambio_precio'] == true || p['cambio_precio'] == 't' || p['cambio_precio'] == 1;
        return ['A', 'B', 'C'].contains(rango) || cambio;
      }).toList();

      return filtered;
    } catch (e) {
      print('Error obtenerProductosParaSurtido: $e');
      return [];
    }
  }

  /// Obtiene información de la ubicación y un valor de progreso basado en la
  /// última tarea para esa ubicación. Devuelve un Map con campos de la tabla
  /// `ubicaciones` y un campo adicional `progress` (0..100) y `last_task`.
  static Future<Map<String, dynamic>?> obtenerInfoUbicacion(String ubicacionId) async {
    try {
      final ubic = await SupabaseConfig.client.from('ubicaciones').select('id,descripcion,area,ultimo_servicio').eq('id', ubicacionId).maybeSingle();

      final lastTaskResp = await SupabaseConfig.client.from('tareas').select('id,estado,fecha_realizacion').eq('ubicacion_id', ubicacionId).order('fecha_asignacion', ascending: false).limit(1).maybeSingle();

      int progress = 0;
      Map<String, dynamic>? lastTask;
      if (lastTaskResp != null) {
        lastTask = Map<String, dynamic>.from(lastTaskResp as Map);
        final estado = (lastTask['estado'] ?? '').toString();
        if (estado == 'pendiente') progress = 0;
        else if (estado == 'en_progreso') progress = 50;
        else if (estado == 'completada') progress = 100;
        else progress = 0;
      }

      final result = <String, dynamic>{};
      if (ubic != null) result.addAll(Map<String, dynamic>.from(ubic as Map));
      result['progress'] = progress;
      result['last_task'] = lastTask;
      return result;
    } catch (e) {
      print('Error obtenerInfoUbicacion: $e');
      return null;
    }
  }

}