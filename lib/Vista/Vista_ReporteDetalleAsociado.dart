import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';

// Colores de la App
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

class ReporteDetalleAsociadoScreen extends StatefulWidget {
  // Recibimos el mapa completo del asociado desde la pantalla anterior
  final Map<String, dynamic> asociado;

  const ReporteDetalleAsociadoScreen({Key? key, required this.asociado}) : super(key: key);

  @override
  State<ReporteDetalleAsociadoScreen> createState() => _ReporteDetalleAsociadoScreenState();
}

class _ReporteDetalleAsociadoScreenState extends State<ReporteDetalleAsociadoScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tareasCompletadas = [];
  List<Map<String, dynamic>> _tareasRevisadas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final int asociadoId = widget.asociado['id'] is int ? widget.asociado['id'] as int : int.tryParse('${widget.asociado['id']}') ?? 0;
    final tareas = await ControladorItinerarioJefe.obtenerTareasDetalleAsociado(asociadoId);
    if (mounted) {
      setState(() {
        _tareasCompletadas = tareas.where((t) => (t['estado'] ?? '') == 'completada').toList();
        _tareasRevisadas = tareas.where((t) => (t['estado'] ?? '') == 'revisada').toList();
        _loading = false;
      });
    }
  }

  // Helper "inteligente" para convertir puntaje en texto
  String _getDesempeno(double? calif) {
    if (calif == null) return 'Sin Calificación';
    if (calif < 5.0) return 'Bajo Desempeño';
    if (calif < 8.0) return 'Desempeño Regular';
    return 'Alto Desempeño'; // 8.0 a 10.0
  }

  // Diálogo que muestra el comentario y la lógica "inteligente"
  void _showComentarioDialog(Map<String, dynamic> tarea) {
    final califRaw = tarea['calificacion'];
    final double? calif = (califRaw is num) ? califRaw.toDouble() : (califRaw != null ? double.tryParse(califRaw.toString()) : null);

    final String desempeno = _getDesempeno(calif);
    final String comentario = (tarea['comentarios'] as String?) ?? (tarea['comentario'] as String?) ?? 'Sin comentarios.';
    final String puntaje = calif?.toStringAsFixed(1) ?? 'N/A';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle de Evaluación ($desempeno)'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Bahía: ${tarea['ubicacion_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Calificación: $puntaje / 10.0'),
              const SizedBox(height: 10),
              const Text('Comentario del Evaluador:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(comentario),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombreCompleto = '${widget.asociado['nombre'] ?? ''} ${widget.asociado['apellido'] ?? ''}'.trim();
    final promedioRaw = widget.asociado['promedio'];
    final double? promedio = (promedioRaw is num) ? promedioRaw.toDouble() : (promedioRaw != null ? double.tryParse(promedioRaw.toString()) : null);

    return Scaffold(
      backgroundColor: colorBackgroundScaffold,
      appBar: AppBar(
        title: Text(nombreCompleto.isNotEmpty ? nombreCompleto : 'Asociado'),
        backgroundColor: colorOrange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN DEL GRÁFICO ---
                  const Text(
                    'Promedio General de Revisiones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorBlack),
                  ),
                  const SizedBox(height: 16),
                  _buildAverageChart(promedio),
                  const SizedBox(height: 24),
                  // --- LISTA DE TAREAS REVISADAS ---
                  Text(
                    'Tareas Revisadas (${_tareasRevisadas.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorBlack),
                  ),
                  const SizedBox(height: 8),
                  ..._tareasRevisadas.map((tarea) {
                    final califRaw = tarea['calificacion'];
                    final double? calif = (califRaw is num) ? califRaw.toDouble() : (califRaw != null ? double.tryParse(califRaw.toString()) : null);
                    return Card(
                      color: colorWhite,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Bahía: ${tarea['ubicacion_id'] ?? 'N/D'}'),
                        leading: CircleAvatar(
                          backgroundColor: colorOrange,
                          child: Text(
                            calif?.toStringAsFixed(1) ?? '?',
                            style: const TextStyle(color: colorWhite, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: const Icon(Icons.comment),
                        onTap: () => _showComentarioDialog(tarea),
                      ),
                    );
                  }),
                  if (_tareasRevisadas.isEmpty && !_loading)
                    const Text('No hay tareas revisadas.', style: TextStyle(color: colorBlack)),
                  const SizedBox(height: 24),
                  // --- LISTA DE TAREAS COMPLETADAS (POR REVISAR) ---
                  Text(
                    'Tareas por Revisar (${_tareasCompletadas.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorBlack),
                  ),
                  const SizedBox(height: 8),
                  ..._tareasCompletadas.map((tarea) {
                    return Card(
                      color: colorWhite.withOpacity(0.8),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Bahía: ${tarea['ubicacion_id'] ?? 'N/D'}'),
                        leading: const Icon(Icons.hourglass_top, color: colorBlack),
                        subtitle: const Text('Pendiente de evaluación'),
                      ),
                    );
                  }),
                  if (_tareasCompletadas.isEmpty && !_loading)
                    const Text('No hay tareas pendientes de revisión.', style: TextStyle(color: colorBlack)),
                ],
              ),
            ),
    );
  }

  // Widget para construir el gráfico circular
  Widget _buildAverageChart(double? promedio) {
    // Normalizamos el promedio (de 0-10 a 0.0-1.0) para el indicador final
    double progressValue = (promedio ?? 0.0) / 10.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fondo gris del círculo
                CircularProgressIndicator(
                  value: 1.0, // Círculo completo
                  strokeWidth: 12,
                  backgroundColor: colorWhite.withOpacity(0.3),
                  color: colorBackgroundScaffold,
                ),
                // Progreso naranja
                CircularProgressIndicator(
                  value: progressValue.clamp(0.0, 1.0),
                  strokeWidth: 12,
                  color: colorOrange,
                  strokeCap: StrokeCap.round, // Bordes redondeados
                ),
                // Texto en el centro
                Center(
                  child: Text(
                    promedio != null ? promedio.toStringAsFixed(1) : 'N/A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDesempeno(promedio), // Usamos el helper inteligente
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                const Text(
                  'Rendimiento promedio basado en tareas revisadas.',
                  style: TextStyle(color: colorWhite),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
