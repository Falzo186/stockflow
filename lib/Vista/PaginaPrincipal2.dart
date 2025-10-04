// En tu archivo: lib/Vista/pagina_principal_2.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:stockflow/Vista/PaginaEscaner.dart'; // Necesario para usar 'pi' y 'min'

class PaginaPrincipal2 extends StatelessWidget {
  const PaginaPrincipal2({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores del diseño
    const Color colorFondo = Color(0xFFD3C5C0);
    const Color colorContenedor = Color(0xFFC4D1F3);
    const Color colorBotonCerrarSesion = Color(0xFF659890);
    const Color colorTextoOscuro = Color(0xFF8E7C77);

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _crearContenedorBienvenida(colorContenedor, colorBotonCerrarSesion, colorTextoOscuro),
              const SizedBox(height: 20),
              _crearBotonesSuperiores(context, colorContenedor, colorTextoOscuro),
              const SizedBox(height: 20),
              _crearSeccionAvance(colorContenedor, colorTextoOscuro),
              const SizedBox(height: 20),
              _crearSeccionSurtido(colorContenedor, colorTextoOscuro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearSeccionAvance(Color bgColor, Color textColor) {
    final int avance = 6;
    final int total = 10;
    final double porcentaje = avance / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: textColor, size: 28),
              const SizedBox(width: 10),
              Text(
                'Avance de servicio de bahías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: SemiCirclePainter(
                    progress: porcentaje,
                    progressColor: const Color(0xFFFBC02D),
                    trackColor: Colors.white.withOpacity(0.5), // Color de fondo más claro
                    strokeWidth: 20.0,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(porcentaje * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$avance / $total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }


  // --- Widgets existentes (sin cambios) ---

  Widget _crearContenedorBienvenida(Color bgColor, Color btnColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: bgColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¡Bienvenida!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                const Text('Antonia Gonzalez', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                  label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _crearBotonesSuperiores(BuildContext context, Color bgColor, Color textColor) {
     return Row(
      children: [
        Expanded(
          child: _crearBotonIcono(
            icono: Icons.qr_code_scanner,
            texto: 'Escanear',
            bgColor: bgColor,
            textColor: textColor,
            // --- CAMBIO AQUÍ ---
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaginaEscaner()),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _crearBotonIcono(
            icono: Icons.list_alt,
            texto: 'Itinerario',
            bgColor: bgColor,
            textColor: textColor,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _crearSeccionSurtido(Color bgColor, Color textColor) {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, color: textColor, size: 28),
              const SizedBox(width: 10),
              Text('Surtido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor,),),
            ],
          ),
          const SizedBox(height: 15),
          _crearBotonNavegacion(icono: Icons.shelves, textoPrincipal: 'Over', textoSecundario: 'Anaquel', onPressed: () {},),
          const SizedBox(height: 10),
          _crearBotonNavegacion(icono: Icons.receipt_long, textoPrincipal: 'PV', textoSecundario: 'Punto de Venta', onPressed: () {},),
        ],
      ),
    );
  }

  Widget _crearBotonIcono({ required IconData icono, required String texto, required Color bgColor, required Color textColor, required VoidCallback onPressed, }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(texto, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18,),)
        ],
      ),
    );
  }
  
  Widget _crearBotonNavegacion({ required IconData icono, required String textoPrincipal, required String textoSecundario, required VoidCallback onPressed, }) {
     return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9EB5F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icono, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textoPrincipal, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(textoSecundario, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}


// ==========================================================
// === CLASE ESPECIAL PARA DIBUJAR EL GRÁFICO (CORREGIDA) ===
// ==========================================================
class SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  SemiCirclePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    
    // <-- CAMBIO CLAVE: El radio ahora respeta la altura del contenedor.
    // Usamos la medida más pequeña (la mitad del ancho o la altura completa) 
    // para asegurarnos de que el arco quepa perfectamente.
    // Le restamos la mitad del grosor de la línea para un ajuste perfecto.
    final radius = math.min(size.width / 2, size.height) - strokeWidth / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, 
      math.pi, 
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress, 
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}