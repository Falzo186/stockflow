// En tu archivo: lib/Vista/pagina_escaner.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/Vista/PaginaInfoProducto.dart';

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

 void _buscarSku(String sku) {
    if (sku.isEmpty) return;

    print('Buscando información para el SKU: $sku');
    
    // Mostramos una notificación de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SKU "$sku" encontrado. Abriendo detalles...'),
        backgroundColor: const Color(0xFF5A9E8B),
      ),
    );

    // Limpiamos los campos para la próxima vez
    _skuController.clear();
    _codigoEscaneado = '';

    // 2. NAVEGAMOS A LA PÁGINA DE INFORMACIÓN DEL PRODUCTO
    // Usamos 'push' para que el usuario pueda regresar al escáner
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaginaInfoProducto(sku: sku), // Le pasamos el SKU
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // === USANDO LA MISMA PALETA DE COLORES DE LA PÁGINA PRINCIPAL ===
    // ==========================================================
    const Color colorFondo = Color(0xFFEAE6E3);
    const Color colorContenedor = Color(0xFFD6D3E0);
    const Color colorBotonPrimario = Color.fromARGB(255, 132, 141, 201); // para acciones principales
    const Color colorBotonSecundario = Color(0xFFB4B9D9); // Azul/púrpura claro
    const Color colorSecundarioTexto = Color(0xFF6E6E6E);


    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Escaner', style: TextStyle(color: Colors.white)),
        backgroundColor: colorBotonPrimario, // Color verde principal
        iconTheme: const IconThemeData(color: Colors.white), // Flecha de regreso blanca
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
              if(event.character != null && event.character != '') {
                _codigoEscaneado += event.character!;
              }
            }
          }
        },
        child: _modoManual 
            ? _construirVistaManual(colorContenedor, colorBotonPrimario, colorSecundarioTexto) 
            : _construirVistaEscaner(colorContenedor, colorBotonSecundario, colorSecundarioTexto),
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
                  borderSide: BorderSide.none, // Sin borde
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