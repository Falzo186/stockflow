import 'package:flutter/material.dart';
import 'package:stockflow/Vista/Vista_CheckListBahia.dart';
import 'package:stockflow/Vista/Vista_InfoBahia.dart';
import 'package:stockflow/Controlador/ControladorItinerario.dart';
import 'package:stockflow/Controlador/ControladorBahias.dart';
import 'package:stockflow/Vista/ItinerarioWidgets.dart' as itw;


// --- Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);


// ----------------------------------------------------------------------------
// Pantalla Principal
// -----------------------------------------------------------------------------
class ItinerarioBahiasScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const ItinerarioBahiasScreen({super.key, this.user});

  @override
  State<ItinerarioBahiasScreen> createState() => _ItinerarioBahiasScreenState();
}

class _ItinerarioBahiasScreenState extends State<ItinerarioBahiasScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tareas = [];
  int _completadas = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final userId = widget.user != null ? (widget.user!['id'] is int ? widget.user!['id'] as int : int.tryParse('${widget.user!['id']}') ?? 0) : 0;
    if (userId > 0) {
      final tareas = await ControladorItinerario.obtenerTareas(userId);
      final control = await ControladorBahias.obtenerUltimoControlUsuario(userId);
      setState(() {
        _tareas = tareas;
        _completadas = control != null ? (control['completadas'] is num ? (control['completadas'] as num).toInt() : int.tryParse('${control['completadas']}') ?? 0) : 0;
        _total = control != null ? (control['total_bahias'] is num ? (control['total_bahias'] as num).toInt() : int.tryParse('${control['total_bahias']}') ?? 0) : 0;
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    // Título
                    const Text(
                      'Progreso Personal',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorBlack),
                    ),
                    const SizedBox(height: 30),

                    // Medidor de Progreso
                    itw.CircularProgressMeter(
                      percentage: _total > 0 ? (_completadas / _total) : 0.0,
                      completed: _completadas,
                      total: _total,
                    ),
                    const SizedBox(height: 30),

                    // Lista de Bahías como botones
                    for (final t in _tareas)
                      itw.TaskButton(
                        name: '${t['ubicacion_id'] ?? 'Sin Ubicación'}',
                        progress: ((t['estado'] == 'completada' || t['estado'] == 'revisada') ? 1.0 : (t['estado'] == 'en_progreso' ? 0.5 : 0.0)),
                        status: '${t['estado']}',
                        onTap: () => _onTapTarea(t),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapTarea(Map<String, dynamic> tarea) async {
    // Mostrar opciones: Iniciar o Completar
    final action = await showModalBottomSheet<String>(context: context, builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Iniciar tarea'),
              onTap: () => Navigator.pop(ctx, 'iniciar'),
            ),
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Completar tarea (checklist)'),
              onTap: () => Navigator.pop(ctx, 'completar'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Ver información'),
              onTap: () => Navigator.pop(ctx, 'ver'),
            ),
          ],
        ),
      );
    });

    if (action == 'iniciar') {
      // Validación: el usuario no puede iniciar si ya tiene otra tarea en progreso
      final userId = widget.user != null ? (widget.user!['id'] is int ? widget.user!['id'] as int : int.tryParse('${widget.user!['id']}') ?? 0) : 0;
      if (userId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario inválido'), backgroundColor: Colors.red));
        return;
      }

      final tareasUsuario = await ControladorItinerario.obtenerTareas(userId);
      final hasOtherInProgress = tareasUsuario.any((x) => (x['estado'] ?? '') == 'en_progreso' && (x['id'] as int) != (tarea['id'] as int));
      if (hasOtherInProgress) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes iniciar: ya tienes otra tarea en progreso'), backgroundColor: Colors.orange));
        return;
      }

      final ok = await ControladorItinerario.iniciarTarea(tarea['id'] as int);
      if (ok) {
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo iniciar la tarea'), backgroundColor: Colors.red));
      }
    } else if (action == 'completar') {
        // Pre-validar estado y asignación para dar feedback inmediato
        final userId = widget.user != null ? (widget.user!['id'] is int ? widget.user!['id'] as int : int.tryParse('${widget.user!['id']}') ?? 0) : 0;
        if (userId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario inválido'), backgroundColor: Colors.red));
          return;
        }

        // Si la tarea no está en progreso o no pertenece al usuario, avisar
        final tareaRow = await ControladorItinerario.obtenerTareaPorId(tarea['id'] as int);
        if (tareaRow == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea no encontrada'), backgroundColor: Colors.red));
          return;
        }
        final estado = (tareaRow['estado'] ?? '').toString();
        final assigned = tareaRow['usuario_id'] is int ? tareaRow['usuario_id'] as int : int.tryParse('${tareaRow['usuario_id']}') ?? 0;
        if (estado != 'en_progreso') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes completar: la tarea no fue iniciada'), backgroundColor: Colors.orange));
          return;
        }
        if (assigned != userId) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes completar: no eres el usuario asignado a esta tarea'), backgroundColor: Colors.orange));
          return;
        }

        // Navegar a la pantalla de checklist y dejar que ella haga la persistencia mediante el controlador
        final res = await Navigator.push<bool>(context, MaterialPageRoute(builder: (ctx) {
          return ChecklistBahiaScreen(ubicacionId: tarea['ubicacion_id']?.toString(), tareaId: tarea['id'] as int, usuarioId: userId);
        }));

        // Si la pantalla indicó éxito (true), refrescar la lista
        if (res == true) {
          await _loadData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea completada'), backgroundColor: Colors.green));
        }
    } else if (action == 'ver') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BayInformationScreen(ubicacionId: tarea['ubicacion_id']?.toString() ?? 'Sin Ubicación')));
    }
  }

  // Header con botón de retroceso
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorOrange.withOpacity(0.1),
              shape: const CircleBorder(),
              minimumSize: const Size(40, 40),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: const Icon(Icons.arrow_back, color: colorOrange, size: 28),
          ),
        const SizedBox(width: 15),
        const Text(
          'Itinerario',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorBlack),
        ),
      ],
    )
    );
  }
}

