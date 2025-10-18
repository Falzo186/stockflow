// archivo: pagina_ubicaciones.dart

import 'package:flutter/material.dart';
import '../Modelo/Producto.dart';
import '../Modelo/ProductoUbicacion.dart';

class PaginaUbicaciones extends StatelessWidget {
  final Producto producto;
  final List<ProductoUbicacion> listaDeStock;

  PaginaUbicaciones({super.key, required this.producto, required this.listaDeStock});

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorTarjeta = Color(0xFFD5D8DC);
    const Color colorHeader = Color(0xFFB0B0B0);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black54), onPressed: () => Navigator.of(context).pop()),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: colorHeader, borderRadius: BorderRadius.circular(10)),
          child: Text(producto.nombre, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ubicaciones:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                color: colorTarjeta,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: listaDeStock.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white54),
                  itemBuilder: (context, index) {
                    final stockItem = listaDeStock[index];

                    return ListTile(
                      title: Text(
                        'Ubicacion: ${stockItem.ubicacionId} - Nivel: ${stockItem.nivel}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Cantidad: ${stockItem.cantidad}',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}