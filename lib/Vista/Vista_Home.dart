// Archivo: lib/Vista/HomeScreen.dart (o como se llame tu primer archivo)

import 'package:flutter/material.dart';
import 'package:stockflow/Vista/Vista_ItinerarioAsociado.dart';
import 'package:stockflow/Vista/Vista_Itinerario_Jefe.dart';
import 'package:stockflow/Vista/PaginaEscaner.dart' show PaginaEscaner;
import 'package:stockflow/Vista/Surtido.dart';
import 'dart:math' as math;

import 'package:stockflow/Vista/Vista_Recibo.dart'; // Necesario para el gráfico
import 'package:stockflow/Controlador/ControladorBahias.dart';
import 'package:stockflow/Controlador/ControladorLogin.dart';
import 'package:stockflow/Vista/Login.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';

// 🎨 Definición de Colores
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: PaginaPrincipal2(user: user),
    );
  }
}

class PaginaPrincipal2 extends StatefulWidget {
  final Map<String, dynamic>? user;

  const PaginaPrincipal2({super.key, this.user});

  @override
  State<PaginaPrincipal2> createState() => _PaginaPrincipal2State();
}

class _PaginaPrincipal2State extends State<PaginaPrincipal2> {
  int _avance = 0;
  int _total = 0;
  double _porcentajeDb = 0.0; // si viene como 60.0 (porcentaje), lo normalizamos
  bool _loadingControl = true;
  // jefe summary
  bool _isJefe = false;
  int _jefeTotal = 0;
  int _jefeCompletadas = 0;

  @override
  void initState() {
    super.initState();
    _loadControlData();
  }

  Future<void> _loadControlData() async {
    setState(() {
      _loadingControl = true;
    });
    try {
      if (widget.user != null && widget.user!['id'] != null) {
        final idRaw = widget.user!['id'];
        final int userId = (idRaw is int) ? idRaw : (idRaw is num ? idRaw.toInt() : int.tryParse(idRaw.toString()) ?? 0);
        if (userId > 0) {
          final registro = await ControladorBahias.obtenerUltimoControlUsuario(userId);
          if (registro != null) {
            _total = (registro['total_bahias'] is num) ? (registro['total_bahias'] as num).toInt() : int.tryParse('${registro['total_bahias']}') ?? 0;
            _avance = (registro['completadas'] is num) ? (registro['completadas'] as num).toInt() : int.tryParse('${registro['completadas']}') ?? 0;
            _porcentajeDb = (registro['porcentaje'] is num) ? (registro['porcentaje'] as num).toDouble() : double.tryParse('${registro['porcentaje']}') ?? 0.0;
          }
            // Si el usuario es jefe (nivel > 1), cargamos resumen global de tareas
          if (widget.user != null && widget.user!['nivel'] != null) {
            final rawNivel = widget.user!['nivel'];
            final int nivel = (rawNivel is int) ? rawNivel : int.tryParse(rawNivel.toString()) ?? 0;
            if (nivel > 1) {
              _isJefe = true;
              final resumen = await ControladorItinerarioJefe.obtenerResumenTareasGlobal();
              _jefeTotal = resumen['total'] ?? 0;
              _jefeCompletadas = resumen['completadas'] ?? 0;
            }
          }
        }
      }
    } catch (_) {
      // en fallo dejamos defaults
    } finally {
      if (mounted) setState(() => _loadingControl = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _crearContenedorBienvenida(
                  colorCardBackground, colorOrange, colorBlack),
              const SizedBox(height: 20),
              _crearBotonesSuperiores(context, colorCardBackground, colorBlack),
              const SizedBox(height: 20),
              _crearSeccionAvance(colorCardBackground, colorBlack),
              const SizedBox(height: 20),
              _crearSeccionSurtido(context, colorCardBackground, colorBlack),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearSeccionAvance(Color bgColor, Color textColor) {
    if (_loadingControl) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
        ),
        height: 150,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Normalizar porcentaje: si BD guardó 60.0 (0-100) convertimos a 0.6
    double progress;
    if (_porcentajeDb > 1.0) {
      progress = (_porcentajeDb / 100.0).clamp(0.0, 1.0);
    } else if (_total > 0) {
      progress = (_avance / _total).clamp(0.0, 1.0);
    } else {
      progress = 0.0;
    }

    // Si es jefe, mostramos el resumen global
    if (_isJefe) {
      final progress = (_jefeTotal > 0) ? (_jefeCompletadas / _jefeTotal).clamp(0.0, 1.0) : 0.0;
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
                  'Resumen global de tareas',
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
                      progress: progress,
                      progressColor: colorOrange,
                      trackColor: colorWhite.withOpacity(0.5),
                      strokeWidth: 20.0,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: colorOrange,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$_jefeCompletadas / $_jefeTotal',
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
                    progress: progress,
                    progressColor: colorOrange,
                    trackColor: colorWhite.withOpacity(0.5),
                    strokeWidth: 20.0,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colorOrange,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_avance / $_total',
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

  Widget _crearContenedorBienvenida(
      Color bgColor, Color btnColor, Color textColor) {
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
                backgroundColor: colorWhite,
                child: Icon(Icons.person, size: 70, color: colorBlack),
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
                const Text(
                  '¡Bienvenida!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  // Mostrar nombre del usuario si está disponible
                  widget.user != null
                      ? '${widget.user!['nombre'] ?? ''} ${widget.user!['apellido'] ?? ''}'
                      : 'Antonia Gonzalez',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Cerrar sesión: limpiar preferencias y volver a Login
                    await ControladorLogin.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage(clearRemembered: true)));
                  },
                  icon: const Icon(Icons.logout, size: 18, color: colorWhite),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(color: colorWhite)),
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

  Widget _crearBotonesSuperiores(
      BuildContext context, Color bgColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _crearBotonIcono(
            icono: Icons.qr_code_scanner,
            texto: 'Escanear',
            bgColor: bgColor,
            textColor: textColor,
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
            onPressed: () {
                // Navegación condicional según nivel: nivel > 1 -> vista de jefe
                int nivel = 0;
                if (widget.user != null && widget.user!['nivel'] != null) {
                  final raw = widget.user!['nivel'];
                  if (raw is int) nivel = raw;
                  else if (raw is String) nivel = int.tryParse(raw) ?? 0;
                }
                if (nivel > 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItinerarioProgresoScreen(user: widget.user),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItinerarioBahiasScreen(user: widget.user),
                    ),
                  );
                }
            },
          ),
        ),
      ],
    );
  }

  Widget _crearSeccionSurtido(
      BuildContext context, Color bgColor, Color textColor) {
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
              Text(
                'Surtido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _crearBotonNavegacion(
            icono: Icons.shelves,
            textoPrincipal: 'Ubicaciones',
            textoSecundario: 'En Tienda',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurtidoScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _crearBotonNavegacion(
            icono: Icons.receipt_long,
            textoPrincipal: 'Recibos',
            textoSecundario: 'Bodega De Tienda',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReciboScreen(),
                ),
              );


              
            },
          ),
        ],
      ),
    );
  }

  Widget _crearBotonIcono({
    required IconData icono,
    required String texto,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
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
          Icon(icono, size: 50, color: colorWhite),
          const SizedBox(height: 10),
          Text(
            texto,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget _crearBotonNavegacion({
    required IconData icono,
    required String textoPrincipal,
    required String textoSecundario,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icono, color: colorWhite, size: 40),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textoPrincipal,
                  style: const TextStyle(
                      color: colorWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(textoSecundario,
                  style: const TextStyle(color: colorWhite, fontSize: 16)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: colorWhite, size: 20),
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
