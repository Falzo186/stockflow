import 'package:flutter/material.dart';
import 'package:stockflow/Vista/GuiaSurtido.dart';
import 'package:stockflow/Vista/Vista_CheckListBahia.dart';

// --- Definición de Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F); // Fondo botones y tarjetas
const Color colorBackgroundScaffold = Color(0xFFE5E5E5); // Fondo general
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

// -----------------------------------------------------------------------------
// Pantalla Principal de Información de Bahía
// -----------------------------------------------------------------------------
class BayInformationScreen extends StatelessWidget {
  const BayInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Bahía 11-00-08 (Área de Iluminación)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorBlack,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressMeter(
                      percentage: 0.5,
                      timeRange: 'Hoy, 8:00AM - 12:00PM',
                    ),
                    const SizedBox(height: 40),
                    const LastServiceInfo(
                      date: '16/Oct/2025',
                      time: '10:30 AM',
                      timeAgo: 'Hace 22 horas',
                    ),
                    const SizedBox(height: 40),
                    ProgressListButton(
                      title: 'Guía de Surtido',
                      icon: Icons.book,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GuiaSurtidoScreen()),
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
                          MaterialPageRoute(builder: (context) => const ChecklistBahiaScreen()),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: colorWhite,
              shape: BoxShape.circle,
              border: Border.all(color: colorOrange, width: 2),
            ),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: colorOrange),
            ),
          ),
        ),
        const Text(
          'Informacion',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: colorBlack,
          ),
        ),
      ],
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
