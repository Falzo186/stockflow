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
    const Color colorTarjeta = Color(0xFFD5D8DC);

    final stockTotal = listaDeStock.fold<int>(0, (total, stock) => total + stock.cantidad);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black54), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Detalle del producto', style: TextStyle(color: Colors.black54)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _crearTarjetaProducto(producto, colorTarjeta),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Informacion General", [
            "Costos: \$${producto.precio.toStringAsFixed(2)}",
            "Existencia: $stockTotal u/d",
          ], colorTarjeta),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Descripcion", [producto.descripcion], colorTarjeta),
          const SizedBox(height: 16),
          _crearTarjetaUbicaciones(context, colorTarjeta),
        ],
      ),
    );
  }

  Widget _crearTarjetaUbicaciones(BuildContext context, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ubicaciones:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  Text('Producto: ${producto.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('SKU: ${producto.id}'),
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
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ...lineas.map((linea) => Text(linea)).toList(),
          ],
        ),
      ),
    );
  }
}
