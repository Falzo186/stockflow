// archivo: pagina_detalle_producto.dart

import 'package:flutter/material.dart';
import 'package:stockflow/BaseDeDatosLocal/BaseDatos.dart';
import 'package:stockflow/Vista/PaginaUbicaciones.dart';
import '../Modelo/Producto.dart';
import '../Modelo/StockUbicacion.dart';

class PaginaDetalleProducto extends StatelessWidget {
  final String sku;
  
  // Creamos una instancia de nuestra "base de datos"
  final BaseDeDatosSimulada db = BaseDeDatosSimulada();

  PaginaDetalleProducto({super.key, required this.sku});

  @override
  Widget build(BuildContext context) {
    // --- REALIZAMOS LAS CONSULTAS A LA "BASE DE DATOS" ---
    final producto = db.buscarProductoPorSku(sku);
    final stockTotal = db.calcularExistenciaTotal(sku);
    final listaDeStock = db.obtenerStockParaProducto(sku);

    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorTarjeta = Color(0xFFD5D8DC);

    // Manejo por si el producto no se encuentra
    if (producto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Producto no encontrado")),
      );
    }

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
            "Costos: \$${producto.costo.toStringAsFixed(2)}",
            "Existencia: $stockTotal u/d", // Usamos el total calculado
          ], colorTarjeta),
          const SizedBox(height: 16),
          _crearTarjetaInfo(producto, "Descripcion", [producto.descripcion], colorTarjeta),
          const SizedBox(height: 16),
          // Le pasamos la lista de stock a la tarjeta de ubicaciones
          _crearTarjetaUbicaciones(context, producto, listaDeStock, colorTarjeta),
        ],
      ),
    );
  }

  Widget _crearTarjetaUbicaciones(BuildContext context, Producto producto, List<StockUbicacion> stocks, Color color) {
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
            // Mostramos un resumen de las ubicaciones y sus cantidades
            ...stocks.take(2).map((stock) {
              final ubicacion = db.buscarUbicacionPorId(stock.idUbicacion);
              if (ubicacion == null) return const SizedBox.shrink();
              return Text('${ubicacion.descripcionCompleta} (${stock.cantidad} pzs)');
            }).toList(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    // Le pasamos a la siguiente página la info que ya tenemos
                    builder: (context) => PaginaUbicaciones(producto: producto, listaDeStock: stocks),
                  ));
                },
                child: const Text('Ver Mas...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // El resto de widgets no necesitan cambios significativos
 Widget _crearTarjetaProducto(Producto producto, Color color) { /* ...código sin cambios... */ 
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                image: producto.urlImagen.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(producto.urlImagen), fit: BoxFit.cover)
                  : null,
              ),
              child: producto.urlImagen.isEmpty ? const Icon(Icons.lightbulb_outline, size: 40) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Producto: ${producto.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('SKU: ${producto.sku}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _crearTarjetaInfo(Producto producto, String titulo, List<String> lineas, Color color) { /* ...código sin cambios... */ 
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
