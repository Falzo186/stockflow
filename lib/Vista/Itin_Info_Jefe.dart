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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Itinerario Detalle Asociado',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: const AsociadoItinerarioScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// Pantalla Principal
// -----------------------------------------------------------------------------
class AsociadoItinerarioScreen extends StatelessWidget {
  const AsociadoItinerarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // Nombre y Cargo
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Asociad@: Ema Gonzales',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorBlack),
                      ),
                      Text(
                        'Cargo: Asociad@ Almacén',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: colorBlack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Medidor de Progreso
                  const CircularProgressMeter(
                    percentage: 0.5,
                    completed: 5,
                    total: 10,
                    label: 'Bahias',
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Bahias asignadas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorBlack),
                  ),
                  const SizedBox(height: 10),

                  // Lista de bahías como botones
                  const AssignedTasksTimeline(),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Botón flotante
            Positioned(
              bottom: 20,
              right: MediaQuery.of(context).size.width / 2 - 30,
              child: AddButton(onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botón + presionado')),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: colorWhite,
                shape: BoxShape.circle,
                border: Border.all(color: colorOrange, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: colorOrange),
            ),
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
// Medidor de Progreso
// -----------------------------------------------------------------------------
class CircularProgressMeter extends StatelessWidget {
  final double percentage;
  final int completed;
  final int total;
  final String label;

  const CircularProgressMeter({
    super.key,
    required this.percentage,
    required this.completed,
    required this.total,
    required this.label,
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
                  Text('${(percentage * 100).toInt()}%',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorBlack)),
                  Text('$completed/$total $label', style: const TextStyle(fontSize: 14, color: colorBlack)),
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

  _SemiCircleProgressPainter({required this.progress, required this.progressColor, required this.backgroundColor});

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
// Lista de bahías
// -----------------------------------------------------------------------------
class AssignedTasksTimeline extends StatelessWidget {
  const AssignedTasksTimeline({super.key});

  final List<Map<String, dynamic>> tasks = const [
    {'name': 'Bahia 10-00-04', 'progress': 1.0, 'status': 'Completada'},
    {'name': 'Bahia 10-00-05', 'progress': 0.5, 'status': 'En Progreso'},
    {'name': 'Bahia 11-00-08', 'progress': 0.0, 'status': 'Pendiente'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks.map((task) {
        return TaskCard(
          name: task['name']!,
          progress: task['progress'] as double,
          status: task['status']!,
          isCompleted: task['progress'] == 1.0,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Seleccionaste ${task['name']}')),
            );
          },
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Tarjeta de bahía como botón
// -----------------------------------------------------------------------------
class TaskCard extends StatelessWidget {
  final String name;
  final double progress;
  final String status;
  final bool isCompleted;
  final VoidCallback onPressed;

  const TaskCard({
    super.key,
    required this.name,
    required this.progress,
    required this.status,
    required this.isCompleted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = isCompleted ? colorOrange : colorOrange.withOpacity(0.7);
    final statusColor = progress == 0.0 ? Colors.redAccent : progressColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Material(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: colorWhite,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorWhite)),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(color: colorWhite.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Botón flotante +
class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: colorWhite,
      elevation: 5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(width: 60, height: 60, child: Icon(Icons.add, color: colorOrange, size: 40)),
      ),
    );
  }
}
