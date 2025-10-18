// archivo: pagina_detalle_producto.dart

import 'package:flutter/material.dart';
import 'package:stockflow/Modelo/ProductoUbicacion.dart';
import 'package:stockflow/Vista/PaginaUbicaciones.dart';
import '../Modelo/Producto.dart';

class PaginaDetalleProducto extends StatelessWidget {
  final Producto producto;
  final List<ProductoUbicacion> listaDeStock;

  PaginaDetalleProducto({super.key, required this.producto, required this.listaDeStock});

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorNaranja = Color(0xFFF39C12);
    const Color colorContenedor = Color(0xFFD5D8DC);
    const Color colorBotonPrimario = Color(0xFFEB984E);
    const Color colorBotonSecundario = Color(0xFFFAD7A0);
    const Color colorSecundarioTexto = Color(0xFF7B7D7D);

    final stockTotal = listaDeStock.fold<int>(0, (total, stock) => total + stock.cantidad);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorNaranja,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorSecundarioTexto),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle del producto',
          style: TextStyle(color: colorSecundarioTexto),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _crearTarjetaProducto(producto, colorContenedor),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Información General", [
            "Costos: \$${producto.precio.toStringAsFixed(2)}",
            "Existencia: $stockTotal u/d",
          ], colorContenedor),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Descripción", [producto.descripcion], colorContenedor),
          const SizedBox(height: 16),
          _crearTarjetaUbicaciones(context, colorContenedor, colorBotonPrimario),
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
}
