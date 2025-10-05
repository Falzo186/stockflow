// archivo: vista_escaner.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/Vista/PaginaDetalleProducto.dart';

class VistaEscaner extends StatefulWidget {
  const VistaEscaner({super.key});

  @override
  State<VistaEscaner> createState() => _VistaEscanerState();
}

class _VistaEscanerState extends State<VistaEscaner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _skuController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _codigoEscaneado = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Pedir foco para que el escáner de hardware funcione
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _skuController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- Lógica de Búsqueda ---
  void _buscarSku(String sku) {
    if (sku.isEmpty) return;

    print('SKU procesado: $sku. Navegando a detalles...');

    // Limpiamos los campos
    _skuController.clear();
    _codigoEscaneado = '';

    // Navegamos a la página de detalles, pasándole el SKU
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaginaDetalleProducto(sku: sku),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorNaranja = Color(0xFFF39C12);
    const Color colorContenedor = Color(0xFFD5D8DC);

    return Scaffold(
      backgroundColor: colorFondo,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (_codigoEscaneado.isNotEmpty) {
                _buscarSku(_codigoEscaneado);
              }
            } else if (event.character != null) {
              _codigoEscaneado += event.character!;
            }
          }
        },
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
            child: Column(
              children: [
                // --- Barra de búsqueda superior con botón ---
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          hintText: 'Ingresar SKU manualmente...',
                          prefixIcon: const Icon(Icons.text_fields),
                          filled: true,
                          fillColor: colorContenedor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _buscarSku(_skuController.text),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: colorNaranja,
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Área del Escáner Visual ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorContenedor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // --- Línea de escaneo animada ---
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Positioned(
                                top: _animationController.value *
                                    (MediaQuery.of(context).size.height * 0.5),
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: colorNaranja,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorNaranja.withOpacity(0.8),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // --- Marco del escáner ---
                          CustomPaint(
                            size: const Size(250, 250),
                            painter: ScannerFramePainter(color: colorNaranja),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  final Color color;
  ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double cornerSize = 40;

    // Top-left corner
    canvas.drawArc(
        Rect.fromLTWH(0, 0, cornerSize * 2, cornerSize * 2),
        math.pi,
        math.pi / 2,
        false,
        paint);
    // Top-right
    canvas.drawArc(
        Rect.fromLTWH(size.width - cornerSize * 2, 0, cornerSize * 2, cornerSize * 2),
        3 * math.pi / 2,
        math.pi / 2,
        false,
        paint);
    // Bottom-left
    canvas.drawArc(
        Rect.fromLTWH(0, size.height - cornerSize * 2, cornerSize * 2, cornerSize * 2),
        math.pi / 2,
        math.pi / 2,
        false,
        paint);
    // Bottom-right
    canvas.drawArc(
        Rect.fromLTWH(size.width - cornerSize * 2, size.height - cornerSize * 2, cornerSize * 2, cornerSize * 2),
        0,
        math.pi / 2,
        false,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
