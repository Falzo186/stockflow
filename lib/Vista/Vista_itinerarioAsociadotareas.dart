import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';
import 'package:stockflow/Controlador/ControladorBahias.dart';
import 'package:stockflow/Vista/Vista_EvaluacionChecklist.dart';

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
  // --- AÑADIR ESTAS LÍNEAS ---
  int _controlTotalBahias = 0;
  int _controlCompletadasBahias = 0;
  // --- FIN ---

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final tareas = await ControladorItinerarioJefe.obtenerTareasPorUsuario(widget.asociadoId);
    final sinAsignar = await ControladorItinerarioJefe.listarTareasSinAsignar();
    // --- AÑADIR ESTO ---
    // Usamos el controlador de Bahias para traer el resumen
    final controlData = await ControladorBahias.obtenerUltimoControlUsuario(widget.asociadoId);
    if (mounted) setState(() {
      _tareas = tareas;
      _sinAsignar = sinAsignar;
      // --- AÑADIR ESTA LÓGICA ---
      if (controlData != null) {
        // Usamos 'total_bahias' y 'completadas' de la tabla control_bahias
        _controlTotalBahias = (controlData['total_bahias'] is num)
            ? (controlData['total_bahias'] as num).toInt()
            : 0;
        _controlCompletadasBahias = (controlData['completadas'] is num)
            ? (controlData['completadas'] as num).toInt()
            : 0;
      } else {
        // Si no hay registro, lo dejamos en 0
        _controlTotalBahias = 0;
        _controlCompletadasBahias = 0;
      }
      // --- FIN ---
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _groupByEstado(String estado) {
    return _tareas.where((t) => (t['estado'] ?? '') == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Agrupaciones necesarias para construir las listas
    final pendientes = _groupByEstado('pendiente');
    final enpro = _groupByEstado('en_progreso');
    // Considerar 'revisada' como completada a efectos de avance
    final completadas = _tareas.where((t) => ((t['estado'] ?? '') == 'completada') || ((t['estado'] ?? '') == 'revisada')).toList();
    // Usamos los datos de control_bahias para el gráfico de avance
    final int total = _controlTotalBahias;
    final int done = _controlCompletadasBahias;
    final double porcentaje = (total == 0) ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Scaffold(

      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68.0),
        child: SafeArea(child: _buildHeader(context)),
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
                  const SizedBox(height: 12),

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
            // Navegamos a la nueva pantalla de evaluación completa
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EvaluacionChecklistScreen(
                  tareaId: id as int,
                  evaluadorUser: widget.jefeUser ?? {}, // Pasamos el usuario jefe
                ),
              ),
            );
            // Si la evaluación se guardó (pop(true)), recargamos la lista
            if (result == true) {
              await _loadAll();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskTileRevisada(Map<String, dynamic> tarea) {
    final ubicacion = tarea['ubicacion_id'] ?? 'N/D';
    // Obtener la calificación de forma segura
    final calificacionRaw = tarea['calificacion'];
    final double calificacion = (calificacionRaw is num)
        ? calificacionRaw.toDouble()
        : double.tryParse(calificacionRaw.toString()) ?? 0.0;
    return Card(
      color: colorWhite,
      child: ListTile(
        title: Text('Bahía: $ubicacion'),
        subtitle: Text('Estado: Revisada'),
        trailing: Chip(
          label: Text(
            'Cal: ${calificacion.toStringAsFixed(1)}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorOrange,
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

  

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
          Expanded(
            child: Text(
              'Asociado #${widget.asociadoId}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colorBlack,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

  }
}
