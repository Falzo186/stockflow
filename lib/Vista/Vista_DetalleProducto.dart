// archivo: pagina_detalle_producto.dart

import 'package:flutter/material.dart';
import 'package:stockflow/Modelo/ProductoUbicacion.dart';
import 'package:stockflow/Vista/Vista_Ubicaciones.dart';
import '../Modelo/Producto.dart';

// Colores del proyecto (reutilizables)
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

class PaginaDetalleProducto extends StatelessWidget {
  final Producto producto;
  final List<ProductoUbicacion> listaDeStock;

  PaginaDetalleProducto({super.key, required this.producto, required this.listaDeStock});

  @override
  Widget build(BuildContext context) {
  // use file-level color constants

    final stockTotal = listaDeStock.fold<int>(0, (total, stock) => total + stock.cantidad);

    return Scaffold(
      backgroundColor: colorBackgroundScaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68.0),
        child: SafeArea(child: _buildHeader(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _crearTarjetaProducto(producto, Color.fromARGB(80, 115, 111, 111)),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Información General", [
            "Costos: \$${producto.precio.toStringAsFixed(2)}",
            "Existencia: $stockTotal u/d",
          ], Color.fromARGB(80, 115, 111, 111)),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Descripción", [producto.descripcion], Color.fromARGB(80, 115, 111, 111)),
          const SizedBox(height: 16),
          _crearTarjetaUbicaciones(context, Color.fromARGB(80, 115, 111, 111), const Color.fromARGB(188, 245, 140, 75)),
        ],
      ),
    );
  }
Widget _crearTarjetaUbicaciones(BuildContext context, Color color, Color colorBoton) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ubicaciones:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...listaDeStock.take(2).map((listaDeStock) {
              return Text(
                'Ubicación: ${listaDeStock.ubicacionId} - Nivel: ${listaDeStock.nivel} (${listaDeStock.cantidad} pzs)',
              );
            }).toList(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorBoton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PaginaUbicaciones(producto: producto, listaDeStock: listaDeStock),
                  ));
                },
                child: const Text('Ver Más...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearTarjetaProducto(Producto producto, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto: ${producto.nombre}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('SKU: ${producto.id}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Categoría: ${producto.categoria}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Proveedor: ${producto.proveedor}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearTarjetaInfo(Producto producto, String titulo, List<String> lineas, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...lineas.map((linea) => Text(linea)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color.fromARGB(193, 250, 199, 167),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
            Expanded(
              child: Text(
                'Detalle del producto',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
