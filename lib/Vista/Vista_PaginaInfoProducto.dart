// En tu archivo: lib/Vista/pagina_info_producto.dart

import 'package:flutter/material.dart';

// --- Clases para simular los datos (Modelos) ---
class Ubicacion {
  final String zona;
  final String pasillo;
  final String cama;
  final String cara;
  final int cantidad;

  Ubicacion({
    required this.zona,
    required this.pasillo,
    required this.cama,
    required this.cara,
    required this.cantidad,
  });
}

class Producto {
  final String sku;
  final String nombre;
  final double costo;
  final int existenciaTotal;
  final String urlImagen;
  final List<Ubicacion> ubicaciones;

  Producto({
    required this.sku,
    required this.nombre,
    required this.costo,
    required this.existenciaTotal,
    required this.urlImagen,
    required this.ubicaciones,
  });
}

// --- Vista Principal ---
class PaginaInfoProducto extends StatelessWidget {
  final String sku;

  const PaginaInfoProducto({super.key, required this.sku});

  // --- Función para simular la búsqueda de datos ---
  Producto _obtenerDatosDelProducto(String skuBuscado) {
    // En una app real, aquí harías una llamada a tu base de datos o API.
    // Por ahora, devolvemos datos de ejemplo.
    return Producto(
      sku: skuBuscado,
      nombre: 'Foco LED Inteligente 10W',
      costo: 250.50,
      existenciaTotal: 18,
      urlImagen: '', // Puedes poner una URL de una imagen aquí si quieres
      ubicaciones: [
        Ubicacion(zona: 'Iluminación', pasillo: 'A', cama: '1', cara: '2', cantidad: 5),
        Ubicacion(zona: 'Bodega', pasillo: 'B', cama: '3', cara: '1', cantidad: 10),
        Ubicacion(zona: 'Exhibición', pasillo: 'F', cama: '5', cara: '2', cantidad: 3),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final producto = _obtenerDatosDelProducto(sku);

    // Paleta de colores consistente
    const Color colorFondo = Color(0xFFEAE6E3);
    const Color colorContenedor = Color(0xFFD6D3E0);
    const Color colorBotonInterno = Color(0xFFB4B9D9);
    const Color colorPrimarioTexto = Color(0xFF3A3A3A);
    const Color colorSecundarioTexto = Color(0xFF6E6E6E);
    
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: Text(producto.nombre, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5A9E8B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // --- Tarjeta de Información General (Costo, Existencia) ---
          _crearTarjetaInfoGeneral(producto, colorContenedor, colorPrimarioTexto, colorSecundarioTexto),
          const SizedBox(height: 20),

          // --- Tarjeta de Ubicaciones ---
          _crearTarjetaUbicaciones(producto, colorContenedor, colorBotonInterno, colorPrimarioTexto),
        ],
      ),
    );
  }

  // Widget para la tarjeta de información general
  Widget _crearTarjetaInfoGeneral(Producto producto, Color bgColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder para la imagen
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.image_outlined, size: 50, color: subTextColor),
          ),
          const SizedBox(width: 15),
          // Columna con la información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${producto.sku}', style: TextStyle(color: subTextColor, fontSize: 16)),
                const SizedBox(height: 8),
                _crearFilaInfo('Costo:', '\$${producto.costo.toStringAsFixed(2)}', textColor),
                const SizedBox(height: 8),
                _crearFilaInfo('Existencia Total:', '${producto.existenciaTotal} pzs', textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para la tarjeta de ubicaciones
  Widget _crearTarjetaUbicaciones(Producto producto, Color bgColor, Color itemColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: textColor.withOpacity(0.8)),
              const SizedBox(width: 10),
              Text(
                'Ubicaciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Construimos la lista de ubicaciones
          ...producto.ubicaciones.map((ubicacion) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _crearItemUbicacion(ubicacion, itemColor),
          )).toList(),
          
          // Botón "Más ubicaciones" (opcional)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Más ubicaciones...'),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS DE AYUDA REUTILIZABLES ---

  // Crea una fila con etiqueta y valor (ej. "Costo: $250.50")
  Widget _crearFilaInfo(String etiqueta, String valor, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: TextStyle(fontSize: 16, color: color.withOpacity(0.7))),
        Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
  
  // Crea el item visual para cada ubicación, como en tu boceto
  Widget _crearItemUbicacion(Ubicacion ubicacion, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Placeholder para el grid visual
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0x80673AB7), // Púrpura semitransparente
              borderRadius: BorderRadius.circular(15)
            ),
            child: const Icon(Icons.grid_on, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ubicacion.zona, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'P: ${ubicacion.pasillo} - C: ${ubicacion.cama} - F: ${ubicacion.cara}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${ubicacion.cantidad} pzs',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}