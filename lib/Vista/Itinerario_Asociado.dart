import 'package:flutter/material.dart';

// --- Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// App principal
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Itinerario Bahías',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: const ItinerarioBahiasScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// Pantalla Principal
// -----------------------------------------------------------------------------
class ItinerarioBahiasScreen extends StatelessWidget {
  const ItinerarioBahiasScreen({super.key});

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
                    const CircularProgressMeter(
                      percentage: 0.5,
                      completed: 5,
                      total: 10,
                    ),
                    const SizedBox(height: 30),

                    // Lista de Bahías como botones
                    TaskButton(
                        name: 'Bahía 10-00-04', progress: 1.0, status: 'Completada', onTap: () {}),
                    TaskButton(
                        name: 'Bahía 11-00-08', progress: 0.5, status: 'En Progreso', onTap: () {}),
                    TaskButton(
                        name: 'Bahía 10-00-07', progress: 0.0, status: 'Pendiente', onTap: () {}),
                    TaskButton(
                        name: 'Bahía 11-00-05', progress: 0.0, status: 'Pendiente', onTap: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header con botón de retroceso
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: colorWhite,
              side: const BorderSide(color: colorOrange, width: 2),
              minimumSize: const Size(45, 45),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.arrow_back, color: colorOrange),
          ),
        ),
        const Text(
          'Itinerario',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: colorBlack),
        ),
      ],
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
                  backgroundColor: colorCardBackground.withOpacity(0.5)),
            ),
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  Text('${(percentage * 100).toInt()}%',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorBlack)),
                  Text('$completed/$total Bahías', style: const TextStyle(fontSize: 14, color: colorBlack)),
                  const Text('Completadas', style: TextStyle(fontSize: 14, color: colorBlack)),
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
// Botón de Bahía
// -----------------------------------------------------------------------------
class TaskButton extends StatelessWidget {
  final String name;
  final double progress;
  final String status;
  final VoidCallback onTap;

  const TaskButton({
    super.key,
    required this.name,
    required this.progress,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = progress == 1.0 ? colorOrange : colorOrange.withOpacity(0.7);
    final statusColor = progress == 0.0 ? Colors.redAccent : progressColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, color: colorOrange, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorWhite)),
                  const SizedBox(height: 5),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration:
                            BoxDecoration(color: colorWhite.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
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
            Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
          ],
        ),
      ),
    );
  }
}
