import 'package:flutter/material.dart';
import 'package:stockflow/Vista/Vista_CheckListBahia.dart';
import 'package:stockflow/Controlador/ControladorItinerario.dart';

// --- Para formateo de fechas
import 'package:intl/intl.dart' as intl;
import 'package:stockflow/Vista/Vista_GuiaSurtido.dart';

// --- Definición de Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F); // Fondo botones y tarjetas
const Color colorBackgroundScaffold = Color(0xFFE5E5E5); // Fondo general
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

// -----------------------------------------------------------------------------
// Pantalla Principal de Información de Bahía
// -----------------------------------------------------------------------------
class BayInformationScreen extends StatefulWidget {
  final String ubicacionId;

  const BayInformationScreen({super.key, required this.ubicacionId});

  @override
  State<BayInformationScreen> createState() => _BayInformationScreenState();
}

class _BayInformationScreenState extends State<BayInformationScreen> {
  bool _loading = true;
  Map<String, dynamic>? _info;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() => _loading = true);
    final info = await ControladorItinerario.obtenerInfoUbicacion(widget.ubicacionId);
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ubicId = widget.ubicacionId;
    final descripcion = _info != null ? (_info!['descripcion'] ?? '') : '';
    final area = _info != null ? (_info!['area'] ?? '') : '';
    final progress = _info != null ? ((_info!['progress'] ?? 0) as int) : 0;
    final lastTask = _info != null ? _info!['last_task'] as Map<String, dynamic>? : null;
    final lastService = _info != null ? (_info!['ultimo_servicio'] ?? null) : null;

    String timeRange = 'Sin rango';
    if (lastService != null) {
      try {
        final dt = DateTime.parse(lastService.toString());
        timeRange = intl.DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        timeRange = lastService.toString();
      }
    }

    return Scaffold(
      backgroundColor: colorBackgroundScaffold,
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
                    const SizedBox(height: 30),

                    // Título dinámico
                    Text(
                      'Bahía $ubicId ${descripcion.isNotEmpty ? '($descripcion)' : ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (area.isNotEmpty) Text('Área: $area', style: const TextStyle(color: colorBlack)),
                    const SizedBox(height: 20),

                    // Medidor de Progreso
                    CircularProgressMeter(
                      percentage: (progress / 100.0),
                      timeRange: lastTask != null ? (lastTask['fecha_realizacion'] ?? timeRange).toString() : timeRange,
                    ),
                    const SizedBox(height: 20),

                    // Último servicio
                    LastServiceInfo(
                      date: lastService != null ? timeRange : 'N/A',
                      time: lastTask != null ? (lastTask['fecha_realizacion'] ?? '-') : '-',
                      timeAgo: lastTask != null ? 'verificado' : '-',
                    ),

                    const SizedBox(height: 30),

                    ProgressListButton(
                      title: 'Guía de Surtido',
                      icon: Icons.book,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GuiaSurtidoScreen(ubicacionId: ubicId)),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ProgressListButton(
                      title: 'Proceso y Cumplimiento',
                      icon: Icons.checklist_rtl,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChecklistBahiaScreen(ubicacionId: ubicId)),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                    ProgressListButton(title: 'Confirmar', icon: Icons.done),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Encabezado con flecha y texto centrado
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
          'Informacion',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorBlack,
          ),
        ),
      ],
      )
    );
  }
}

// -----------------------------------------------------------------------------
// Componente: Medidor de Progreso Circular
// -----------------------------------------------------------------------------
class CircularProgressMeter extends StatelessWidget {
  final double percentage;
  final String timeRange;

  const CircularProgressMeter({
    super.key,
    required this.percentage,
    required this.timeRange,
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
              bottom: 20,
              child: Column(
                children: [
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: colorBlack,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timeRange,
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorBlack,
                    ),
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

// CustomPainter para el arco semicircular
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

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// -----------------------------------------------------------------------------
// Último Servicio
// -----------------------------------------------------------------------------
class LastServiceInfo extends StatelessWidget {
  final String date;
  final String time;
  final String timeAgo;

  const LastServiceInfo({
    super.key,
    required this.date,
    required this.time,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            'Último Servicio Registrado:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorWhite,
            ),
          ),
          Text(
            '$date - $time ($timeAgo)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Botón estilo "ProgressListButton" (igual a Itinerario Progreso)
// -----------------------------------------------------------------------------
class ProgressListButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;

  const ProgressListButton({super.key, required this.title, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ??
          () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$title presionado')));
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorCardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: colorOrange, size: 24),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: colorWhite),
          ),
        ],
      ),
    );
  }
}
