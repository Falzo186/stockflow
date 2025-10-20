import 'package:flutter/material.dart';

// --- Colores que proporcionaste ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

// --- Modelo de datos para cada producto ---
class ProductoItem {
  final String nombre;
  final String suk;
  final String stock;
  final String ubicacion;
  bool estaSeleccionado; // Para manejar el estado del checkbox

  ProductoItem({
    required this.nombre,
    required this.suk,
    required this.stock,
    required this.ubicacion,
    this.estaSeleccionado = false,
  });
}

// --- Pantalla de Surtido ---
class ReciboScreen extends StatefulWidget {
  const ReciboScreen({super.key});

  @override
  State<ReciboScreen> createState() => _ReciboScreenState();
}

class _ReciboScreenState extends State<ReciboScreen> {
  // Estado para los botones PV/OVER
  int _selectedView = 0; // 0 = PV, 1 = OVER

  // Lista de productos (ejemplo)
  final List<ProductoItem> _productos = [
    ProductoItem(
        nombre: 'LED Smart Bulb',
        suk: '202399',
        stock: '200 u/d',
        ubicacion: 'BT001'),
    ProductoItem(
        nombre: 'Aspiradora Portátil',
        suk: '845233',
        stock: '100 u/d',
        ubicacion: 'BT002'),
    ProductoItem(
        nombre: 'Extensión Eléctrica',
        suk: '309822',
        stock: '300 u/d',
        ubicacion: 'BT003'),
    ProductoItem(
        nombre: 'Foco LED RGB',
        suk: '120493',
        stock: '150 u/d',
        ubicacion: 'BT004'),
  ];

  /// Lógica principal al tocar un checkbox
  void _onProductoCheck(ProductoItem producto, bool? newValue) {
    if (newValue == true) {
      // Si se está SELECCIONANDO, solo actualiza el estado
      setState(() {
        producto.estaSeleccionado = true;
      });
    } else {
      // Si se está DES-SELECCIONANDO, muestra el diálogo de motivo
      _mostrarDialogoMotivo(producto);
    }
  }

  /// Muestra el diálogo para preguntar el motivo del movimiento
  void _mostrarDialogoMotivo(ProductoItem producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Motivo de Movimiento'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                _actualizarEstadoProducto(producto, "Mercancía dañada");
              },
              child: const Text('Mercancía dañada'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _actualizarEstadoProducto(producto, "Venta inmediata");
              },
              child: const Text('Venta inmediata'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _actualizarEstadoProducto(producto, "Surtido a tienda");
              },
              child: const Text('Surtido a tienda'),
            ),
            // Opción para cancelar la acción
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: colorBlack)),
              onPressed: () {
                Navigator.of(context).pop();
                // No hacemos nada, el checkbox sigue marcado
              },
            ),
          ],
        );
      },
    );
  }

  /// Función que se llama DESPUÉS de seleccionar un motivo
  void _actualizarEstadoProducto(ProductoItem producto, String motivo) {
    Navigator.of(context).pop(); // Cierra el diálogo
    setState(() {
      producto.estaSeleccionado = false; // Ahora sí lo desmarca
    });

    // Muestra una confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} movido. Motivo: $motivo'),
        backgroundColor: colorOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackgroundScaffold,
      appBar: AppBar(
        title: const Text('Surtido', style: TextStyle(color: colorBlack)),
        backgroundColor: colorWhite,
        elevation: 1,
        iconTheme: const IconThemeData(color: colorBlack),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_box_outline_blank), // Icono de la derecha
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar("Bahía"),
          _buildSearchBar("Producto Nuevo"),
          _buildToggleButtons(),
          const SizedBox(height: 10),
          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                return _buildProductoCard(_productos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para las barras de búsqueda
  Widget _buildSearchBar(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: colorCardBackground.withOpacity(0.5), // Un poco más sólido
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextField(
          style: const TextStyle(color: colorBlack),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: colorBlack.withOpacity(0.7)),
            icon: Icon(Icons.search, color: colorBlack.withOpacity(0.7)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  /// Widget para los botones PV/OVER
  Widget _buildToggleButtons() {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        'Bodega de Tienda',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colorBlack,
        ),
      ),
    );
  }

  /// Widget para cada tarjeta de producto
  Widget _buildProductoCard(ProductoItem producto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colorCardBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: producto.estaSeleccionado,
              onChanged: (bool? newValue) {
                _onProductoCheck(producto, newValue);
              },
              activeColor: colorOrange,
              checkColor: colorWhite,
              side: const BorderSide(color: colorWhite, width: 2),
            ),
            // Icono
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: colorWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline, color: colorOrange),
            ),
            const SizedBox(width: 12.0),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      color: colorWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SUK: ${producto.suk}',
                    style: const TextStyle(color: colorWhite, fontSize: 13),
                  ),
                  Text(
                    'Stock: ${producto.stock}',
                    style: const TextStyle(color: colorWhite, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Ubicación (en lugar de la hora y botones +/-)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                producto.ubicacion,
                style: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}