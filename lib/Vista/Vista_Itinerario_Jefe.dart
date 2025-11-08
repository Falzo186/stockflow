import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';
import 'package:stockflow/Vista/AsociadoItinerarioScreen.dart';

// --- Definición de Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F); // 50% opacidad
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);
// -----------------------------------------------------------------------------
// Pantalla Principal
// -----------------------------------------------------------------------------
class ItinerarioProgresoScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const ItinerarioProgresoScreen({super.key, this.user});

  @override
  State<ItinerarioProgresoScreen> createState() => _ItinerarioProgresoScreenState();
}

class _ItinerarioProgresoScreenState extends State<ItinerarioProgresoScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _asociados = [];

  @override
  void initState() {
    super.initState();
    _loadAsociados();
  }

  Future<void> _loadAsociados() async {
    setState(() => _loading = true);
    final list = await ControladorItinerarioJefe.obtenerAsociadosConProgreso();
    if (mounted) setState(() {
      _asociados = list;
      _loading = false;
    });
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
                    // Encabezado
                    _buildHeader(context),
                    const SizedBox(height: 20),

                    const Text(
                      'Progreso de Tareas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorBlack,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '(Asociados)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: colorBlack,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Loading
                    if (_loading) const Center(child: CircularProgressIndicator()),

                    // Resumen global calculado a partir de asociados
                    if (!_loading) ...[
                      (() {
                        final int totalAssigned = _asociados.fold<int>(0, (s, e) => s + ((e['total_tareas'] is int) ? (e['total_tareas'] as int) : int.tryParse('${e['total_tareas']}') ?? 0));
                        final int totalDone = _asociados.fold<int>(0, (s, e) => s + ((e['completadas'] is int) ? (e['completadas'] as int) : int.tryParse('${e['completadas']}') ?? 0));
                        final double pct = totalAssigned == 0 ? 0.0 : (totalDone / totalAssigned).clamp(0.0, 1.0);
                        return Column(
                          children: [
                            CircularProgressMeter(percentage: pct, completed: totalDone, total: totalAssigned),
                            const SizedBox(height: 20),
                          ],
                        );
                      }()),
                    ],

                    // Lista dinámica de asociados
                    if (!_loading)
                      ..._asociados.map((a) {
                        final nombre = a['nombre'] ?? 'N/D';
                        final cargo = 'Asociado';
                        final porcentaje = (a['porcentaje'] is num) ? (a['porcentaje'] as num) / 100.0 : (a['porcentaje'] is double ? a['porcentaje'] as double : 0.0);
                        return ProgressListButton(
                          name: nombre.toString(),
                          cargo: cargo,
                          progress: porcentaje.clamp(0.0, 1.0),
                          onPressed: () {
                            // navegar al detalle del asociado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AsociadoItinerarioScreen(
                                  asociadoId: (a['id'] is int) ? a['id'] as int : int.tryParse('${a['id']}') ?? 0,
                                  jefeUser: widget.user,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorBlack,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Medidor de Progreso Circular
// -----------------------------------------------------------------------------
class CircularProgressMeter extends StatelessWidget {
  final double percentage;
  final int completed;
  final int total;

  const CircularProgressMeter({
    super.key,
    required this.percentage,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(250, 125),
              painter: _SemiCircleProgressPainter(
                progress: percentage,
                progressColor: colorOrange,
                backgroundColor: colorCardBackground.withOpacity(0.5),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorBlack),
                  ),
                  Text(
                    '$completed/$total Bahías',
                    style: const TextStyle(fontSize: 14, color: colorBlack),
                  ),
                  const Text(
                    'Completadas',
                    style: TextStyle(fontSize: 14, color: colorBlack),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _SemiCircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 15.0;
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = 3.14159;
    const sweepAngle = 3.14159;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// -----------------------------------------------------------------------------
// Barra de búsqueda (solo visual)
// -----------------------------------------------------------------------------
class SearchBarField extends StatelessWidget {
  const SearchBarField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: const [
          Icon(Icons.search, color: colorOrange),
          SizedBox(width: 8),
          Text('Buscar...', style: TextStyle(color: colorWhite, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Item de la Lista de Progreso como Botón
// -----------------------------------------------------------------------------
class ProgressListButton extends StatelessWidget {
  final String name;
  final String cargo;
  final double progress;
  final VoidCallback? onPressed;

  const ProgressListButton({super.key, required this.name, required this.cargo, required this.progress, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final progressColor = progress == 1.0 ? colorOrange : colorOrange.withOpacity(0.7);
    final percentageText = '${(progress * 100).toInt()}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: onPressed ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Presionaste a $name')));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(12),
          elevation: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, color: colorOrange, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: $name',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorWhite)),
                  Text('Cargo: $cargo', style: const TextStyle(fontSize: 14, color: colorWhite)),
                  const SizedBox(height: 5),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(color: colorWhite.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(percentageText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: progressColor)),
          ],
        ),
      ),
    );
  }
}
