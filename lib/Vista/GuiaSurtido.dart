import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerario.dart';

// --- Definición de Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F); // 736F6F con 50% de opacidad
const Color colorBackgroundScaffold = Color(0xFFE5E5E5); // Fondo del Scaffold
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

// ----------------------------------------------------------------------------
// ## Pantalla Principal de Guía de Surtido
// -----------------------------------------------------------------------------
class GuiaSurtidoScreen extends StatefulWidget {
  final String? ubicacionId;

  const GuiaSurtidoScreen({super.key, this.ubicacionId});

  @override
  State<GuiaSurtidoScreen> createState() => _GuiaSurtidoScreenState();
}

class _GuiaSurtidoScreenState extends State<GuiaSurtidoScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() => _loading = true);
    final ubic = widget.ubicacionId ?? '';
    final prods = await ControladorItinerario.obtenerProductosParaSurtido(ubic);
    setState(() {
      _productos = prods;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorCardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Encabezado ---
              _buildHeader(context),
              const SizedBox(height: 30),

              // --- Título Listado de SKUs ---
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Listado de SKUs en Bahía',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorBlack,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- Lista de SKUs ---
              if (_loading) const Center(child: CircularProgressIndicator())
              else if (_productos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No se encontraron productos para surtido.'),
                )
              else
                Column(
                  children: _productos.map((p) {
                    final nombre = p['nombre'] ?? 'Sin nombre';
                    final sku = p['id']?.toString() ?? '-';
                    final rango = p['rango'] ?? '';
                    final cambio = p['cambio_precio'] == true;
                    return SkuCard(productName: '$nombre (rango $rango${cambio ? ', cambio precio' : ''})', sku: sku);
                  }).toList(),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para el encabezado (Flecha, Título)
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        // Botón de Retroceso Circular
        Container(
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
        const SizedBox(width: 20),
        const Text(
          'Guía de Surtido',
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
// ## Componente: Línea de Tiempo de SKUs
// -----------------------------------------------------------------------------
class SkuListTimeline extends StatelessWidget {
  const SkuListTimeline({super.key});

  // Datos simulados para la lista de SKUs
  final List<Map<String, String>> skus = const [
    {'product': 'Producto A', 'sku': '202399'},
    {'product': 'Producto B', 'sku': '554101'},
    {'product': 'Producto C', 'sku': '809210'},
    {'product': 'Producto D', 'sku': '-------'},
    {'product': 'Producto E', 'sku': '-------'},
    {'product': 'Producto F', 'sku': '-------'},
  ];

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Columna de la Línea de Tiempo (Vertical
          Container(
            width: 30,
            margin: const EdgeInsets.only(left: 5),
            child: Column(
              children: [
                // Círculo naranja grande
                Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: colorOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                // Línea vertical continua
                Expanded(
                  child: Container(
                    width: 3,
                    color: colorOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Columna de las Tarjetas de SKU
          Expanded(
            child: Column(
              children: skus.map((item) {
                return SkuCard(
                  productName: item['product']!,
                  sku: item['sku']!,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Componente: Tarjeta de SKU Individual
// -----------------------------------------------------------------------------
class SkuCard extends StatelessWidget {
  final String productName;
  final String sku;

  const SkuCard({
    super.key,
    required this.productName,
    required this.sku,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Icono y Texto del SKU
          Row(
            children: [
              // Icono del checklist (simulado)
              const Icon(Icons.check_box_outline_blank, color: colorOrange, size: 24),
              const SizedBox(width: 10),
              // Nombre y SKU
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$productName:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                  Text(
                    'SKU $sku',
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Botón de Código de Barras
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Código de barras de $productName seleccionado')),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code, // Ícono de código de barras
                color: colorOrange,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
