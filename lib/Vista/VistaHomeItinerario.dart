// archivo: vista_home_itinerario.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class VistaHomeItinerario extends StatelessWidget {
  const VistaHomeItinerario({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorNaranja = Color(0xFFF39C12);
    const Color colorTarjeta = Color(0xFFD5D8DC);
    const Color colorTextoGris = Color(0xFF566573);
    const FontStyle estiloFuenteTitulo = FontStyle.italic;

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // --- Barra Superior ---
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.white,
                    elevation: 4,
                  ),
                  child: const Icon(Icons.menu, color: Colors.black54),
                ),
                const SizedBox(width: 15),
                const Text(
                  'Itinerario',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorTextoGris,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Progreso de Tareas ---
            const Text(
              'Progreso de Tareas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorTextoGris),
            ),
            const Text(
              '(Asociados Generales)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorTextoGris),
            ),
            const SizedBox(height: 15),

            // --- Gráfico de Progreso ---
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 125),
                    painter: SemiCirclePainter(
                      progress: 0.5, // 50%
                      progressColor: colorNaranja,
                      trackColor: Colors.grey.shade300,
                      strokeWidth: 20,
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    child: Column(
                      children: [
                        Text(
                          '50%',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: colorNaranja,
                          ),
                        ),
                        const Text(
                          '25/50 Bahias\nCompletadas',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: colorTextoGris),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Lista de Asociados ---
            _crearTarjetaAsociado('Elena Martin', 'Gerente', 1.0, colorTarjeta, colorNaranja, colorTextoGris),
            _crearTarjetaAsociado('Ema Gonzales', 'Almacén', 0.4, colorTarjeta, colorNaranja, colorTextoGris),
            _crearTarjetaAsociado('Emili Hernandez', 'Ventas', 1.0, colorTarjeta, colorNaranja, colorTextoGris),
            _crearTarjetaAsociado('Elena Martin', 'Gerente', 1.0, colorTarjeta, colorNaranja, colorTextoGris),

          ],
        ),
      ),
    );
  }

  Widget _crearTarjetaAsociado(String nombre, String cargo, double progreso, Color bgColor, Color progressColor, Color textColor) {
    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asociad@: $nombre', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Text('Cargo: Asociad@ $cargo', style: TextStyle(color: textColor.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progreso,
                    backgroundColor: Colors.grey.shade400,
                    color: progressColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  Text('${(progreso * 100).toInt()}%', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  SemiCirclePainter({required this.progress, required this.progressColor, required this.trackColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    final Paint progressPaint = Paint()..color = progressColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}