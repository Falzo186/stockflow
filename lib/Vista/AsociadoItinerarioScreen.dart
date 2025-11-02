import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';

// Colores del proyecto
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

class AsociadoItinerarioScreen extends StatefulWidget {
  final int asociadoId;
  final Map<String, dynamic>? jefeUser;

  const AsociadoItinerarioScreen({super.key, required this.asociadoId, this.jefeUser});

  @override
  State<AsociadoItinerarioScreen> createState() => _AsociadoItinerarioScreenState();
}

class _AsociadoItinerarioScreenState extends State<AsociadoItinerarioScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tareas = [];
  List<Map<String, dynamic>> _sinAsignar = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final tareas = await ControladorItinerarioJefe.obtenerTareasPorUsuario(widget.asociadoId);
    final sinAsignar = await ControladorItinerarioJefe.listarTareasSinAsignar();
    if (mounted) setState(() {
      _tareas = tareas;
      _sinAsignar = sinAsignar;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _groupByEstado(String estado) {
    return _tareas.where((t) => (t['estado'] ?? '') == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _groupByEstado('pendiente');
    final enpro = _groupByEstado('en_progreso');
    final completadas = _groupByEstado('completada');
    final total = _tareas.length;
    final done = completadas.length;
    final porcentaje = total == 0 ? 0.0 : (done / total);

    return Scaffold(
      appBar: AppBar(
        title: Text('Asociado #${widget.asociadoId}'),
        backgroundColor: colorOrange,
      ),
      backgroundColor: colorBackgroundScaffold,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Card resumen con gráfico circular y porcentaje
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorCardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: porcentaje.clamp(0.0, 1.0),
                                  strokeWidth: 10,
                                  color: colorOrange,
                                  backgroundColor: colorWhite.withOpacity(0.12),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${(porcentaje * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorWhite)),
                                  const SizedBox(height: 4),
                                  Text('$done/$total', style: const TextStyle(fontSize: 12, color: colorWhite)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Avance general', style: TextStyle(color: colorWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Progreso de las tareas asignadas', style: TextStyle(color: colorWhite.withOpacity(0.9))),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: porcentaje.clamp(0.0, 1.0), color: colorOrange, backgroundColor: colorWhite.withOpacity(0.12), minHeight: 10),
                              const SizedBox(height: 10),
                              Text('${(porcentaje * 100).toInt()}% completadas', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...pendientes.map(_buildTaskTilePendiente).toList(),
                  const SizedBox(height: 12),

                  const Text('En Progreso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...enpro.map(_buildTaskTileEnProgreso).toList(),
                  const SizedBox(height: 12),

                  const Text('Completadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...completadas.map(_buildTaskTileCompletada).toList(),
                  const SizedBox(height: 20),

                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Tareas sin asignar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._sinAsignar.map(_buildUnassignedTile).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildTaskTilePendiente(Map<String, dynamic> tarea) {
    final id = tarea['id'];
    final ubicacion = tarea['ubicacion_id'] ?? 'N/D';
    return Card(
      child: ListTile(
        title: Text('Bahía: $ubicacion'),
        subtitle: Text('Estado: Pendiente'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text('Desasignar'),
              onPressed: () async {
                final ok = await ControladorItinerarioJefe.desasignarTarea(id as int);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Tarea desasignada' : 'No se puede desasignar')));
                if (ok) await _loadAll();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTileEnProgreso(Map<String, dynamic> tarea) {
    final ubicacion = tarea['ubicacion_id'] ?? 'N/D';
    return Card(
      child: ListTile(
        title: Text('Bahía: $ubicacion'),
        subtitle: Text('Estado: En progreso'),
        trailing: const Text('En progreso'),
      ),
    );
  }

  Widget _buildTaskTileCompletada(Map<String, dynamic> tarea) {
    final id = tarea['id'];
    final ubicacion = tarea['ubicacion_id'] ?? 'N/D';
    return Card(
      child: ListTile(
        title: Text('Bahía: $ubicacion'),
        subtitle: Text('Estado: Completada'),
        trailing: TextButton(
          child: const Text('Evaluar'),
          onPressed: () async {
            final result = await _showEvaluacionDialog(id as int);
            if (result == true) await _loadAll();
          },
        ),
      ),
    );
  }

  Widget _buildUnassignedTile(Map<String, dynamic> tarea) {
    final id = tarea['id'];
    final ubicacion = tarea['ubicacion_id'] ?? 'N/D';
    return Card(
      child: ListTile(
        title: Text('Bahía: $ubicacion'),
        subtitle: const Text('Sin asignar'),
        trailing: TextButton(
          child: const Text('Asignar'),
          onPressed: () async {
            final ok = await ControladorItinerarioJefe.asignarTareaAUsuario(id as int, widget.asociadoId);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Asignada' : 'Error al asignar')));
            if (ok) await _loadAll();
          },
        ),
      ),
    );
  }

  Future<bool> _showEvaluacionDialog(int tareaId) async {
    final TextEditingController comentarioCtrl = TextEditingController();
    double puntaje = 8.0;
    return await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Evaluación de checklist'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: comentarioCtrl, decoration: const InputDecoration(labelText: 'Comentarios')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Puntaje:'),
                      Expanded(
                        child: Slider(
                          value: puntaje,
                          min: 0,
                          max: 10,
                          divisions: 20,
                          onChanged: (v) {
                            setState(() {
                              puntaje = v;
                            });
                          },
                        ),
                      ),
                      Text(puntaje.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    final evaluador = widget.jefeUser != null && widget.jefeUser!['id'] != null ? (widget.jefeUser!['id'] is int ? widget.jefeUser!['id'] as int : int.tryParse('${widget.jefeUser!['id']}') ?? 0) : 0;
                    final ok = await ControladorItinerarioJefe.evaluarTarea(tareaId, evaluador, comentarioCtrl.text, puntaje);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Evaluación registrada' : 'Error al registrar evaluación')));
                    Navigator.pop(context, ok);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }
}
