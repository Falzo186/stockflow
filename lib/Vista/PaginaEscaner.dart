import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/Controlador/ControladorEscaner.dart';

import 'PaginaDetalleProducto.dart'; // Importa tu controlador

class PaginaEscaner extends StatefulWidget {
  const PaginaEscaner({super.key});

  @override
  State<PaginaEscaner> createState() => _PaginaEscanerState();
}

class _PaginaEscanerState extends State<PaginaEscaner> {
  bool _modoManual = false;
  final TextEditingController _skuController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _codigoEscaneado = '';
  final controladorEscaner = ControladorEscaner();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _buscarSku(String sku) async {
    if (sku.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El SKU no puede estar vacío.'),
          backgroundColor: Color(0xFFF39C12),
        ),
      );
      return;
    }

    try {
      final producto = await controladorEscaner.obtenerProductoPorSku(sku.trim());

      if (producto != null) {
        final listaDeStock = await controladorEscaner.obtenerProductoUbicacionesPorId(producto.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto encontrado: ${producto.nombre}. Abriendo detalles...'),
            backgroundColor: const Color(0xFF5A9E8B),
          ),
        );

        _skuController.clear();
        _codigoEscaneado = '';

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaginaDetalleProducto(producto: producto, listaDeStock: listaDeStock),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró ningún producto con el SKU "$sku".'),
            backgroundColor: const Color(0xFFF39C12),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar el producto: ${e.toString()}'),
          backgroundColor: const Color(0xFFF39C12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorNaranja = Color(0xFFF39C12);
    const Color colorContenedor = Color(0xFFD5D8DC);
    const Color colorBotonPrimario = Color(0xFFEB984E);
    const Color colorBotonSecundario = Color(0xFFFAD7A0);
    const Color colorSecundarioTexto = Color(0xFF7B7D7D);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Escaner', style: TextStyle(color: Colors.white)),
        backgroundColor: colorBotonPrimario,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _modoManual
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _modoManual = false;
                  });
                  FocusScope.of(context).requestFocus(_focusNode);
                },
              )
            : null,
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (_codigoEscaneado.isNotEmpty) {
                _buscarSku(_codigoEscaneado);
              }
            } else {
              if (event.character != null && event.character != '') {
                _codigoEscaneado += event.character!;
              }
            }
          }
        },
        child: _modoManual
            ? _construirVistaManual(colorContenedor, colorBotonPrimario, colorSecundarioTexto)
            : _construirVistaEscaner(colorContenedor, colorNaranja, colorSecundarioTexto),
      ),
    );
  }

  Widget _construirVistaManual(Color bgColor, Color btnColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _skuController,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Ingresa SKU',
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              onSubmitted: _buscarSku,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _buscarSku(_skuController.text),
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVistaEscaner(Color bgColor, Color btnColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: const Icon(
              Icons.barcode_reader,
              size: 150,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Apunta la herramienta de escaneo al código',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _modoManual = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Ingresar SKU manualmente'),
          ),
        ],
      ),
    );
  }
}
