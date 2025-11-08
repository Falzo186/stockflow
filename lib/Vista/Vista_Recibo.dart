import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorSurtido.dart';

// --- Colores que proporcionaste ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

// --- Modelo de datos para cada producto ---
class ProductoItem {
  final String nombre;
  final String suk; // usaremos esto como producto_id cuando aplique
  // Mantener cantidades por nivel para evitar duplicados (pv/over)
  final Map<String, int> niveles;
  final String ubicacion;
  bool estaSeleccionado; // Para marcar para eliminación
  bool isNew; // si fue agregado localmente

  ProductoItem({
    required this.nombre,
    required this.suk,
    Map<String, int>? niveles,
    required this.ubicacion,
    this.estaSeleccionado = false,
    this.isNew = false,
  }) : niveles = niveles ?? {'pv': 0, 'over': 0};

  int get stockNum => niveles.values.fold(0, (a, b) => a + b);
}

// --- Pantalla de Surtido ---
class ReciboScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const ReciboScreen({super.key, this.user});

  @override
  State<ReciboScreen> createState() => _ReciboScreenState();
}

class _ReciboScreenState extends State<ReciboScreen> {
  // Estado para los botones PV/OVER (no usado actualmente)

  // Lista de productos cargada desde el controlador (initialmente vacía)
  final List<ProductoItem> _productos = [];
  // Lista separada para los productos nuevos agregados en esta sesión
  final List<ProductoItem> _newProducts = [];

  // Controllers y estado adicionales
  final TextEditingController _bayController = TextEditingController();
  final TextEditingController _newProductController = TextEditingController();
  String? _currentBahiaId;

  // Acciones marcadas para productos seleccionados (map producto.suk -> acción)
  final Map<String, String> _markedActions = {};
  // Lista de productos completos a eliminar (suk, cantidad, nivel)
  final List<Map<String, dynamic>> _toDeleteProducts = [];

  /// Lógica principal al tocar un checkbox
  void _onProductoCheck(ProductoItem producto, bool? newValue) {
    setState(() {
      producto.estaSeleccionado = newValue ?? false;
      if (producto.estaSeleccionado == false) {
        _markedActions.remove(producto.suk);
      }
    });
  }

  /// Muestra el diálogo para preguntar el motivo del movimiento
  /// Muestra el diálogo para preguntar el motivo del movimiento y devuelve la opción seleccionada
  Future<String?> _promptActionForProduct() async {
    final res = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Motivo de Movimiento'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Mercancía dañada'),
              child: const Text('Mercancía dañada'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Devolución'),
              child: const Text('Devolución'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Surtido a tienda'),
              child: const Text('Surtido a tienda'),
            ),
            // Opción para cancelar la acción
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: colorBlack)),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ],
        );
      },
    );
    return res;
  }

  /// Función que se llama DESPUÉS de seleccionar un motivo
  // Removed: immediate action setter. Use _promptActionForProduct + Delete button flow instead.

  /// Muestra un diálogo solicitando la cantidad (int) y retorna el valor
  Future<int?> _askQuantityDialog({int initial = 1}) async {
    final TextEditingController c = TextEditingController(text: initial.toString());
    final res = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cantidad'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ingresa cantidad'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar')),
          TextButton(
              onPressed: () {
                final v = int.tryParse(c.text.trim());
                Navigator.of(context).pop(v);
              },
              child: const Text('Aceptar')),
        ],
      ),
    );
    return res;
  }

  Future<void> _fetchProductsForBay(String bayId) async {
    if (bayId.length != 5 || !bayId.startsWith('BT')) return;
    setState(() {
      _productos.clear();
      _currentBahiaId = bayId;
    });

    final controlador = ControladorSurtido();
    final ubicaciones = await controlador.buscarProductosBahia(bayId);

    // Agregar y agregarizar por productoId sumando cantidades por nivel
    final Map<String, ProductoItem> agg = {};
    for (final u in ubicaciones) {
      final pid = u.productoId.toString();
      final qty = u.cantidad ?? 0;
      final nivel = (u.nivel ?? 'over').toString();
      if (!agg.containsKey(pid)) {
        final niveles = {'pv': 0, 'over': 0};
        niveles[nivel] = (niveles[nivel] ?? 0) + qty;
        agg[pid] = ProductoItem(nombre: 'ID $pid', suk: pid, niveles: niveles, ubicacion: u.ubicacionId, isNew: false);
      } else {
        agg[pid]!.niveles[nivel] = (agg[pid]!.niveles[nivel] ?? 0) + qty;
      }
    }

    setState(() {
      _productos.addAll(agg.values);
    });
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
            icon: const Icon(Icons.save),
            onPressed: _onSavePressed,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBayField(),
          _buildNewProductField(),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(color: colorCardBackground, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final toRemove = _productos.where((p) => p.estaSeleccionado).toList();
                if (toRemove.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay productos seleccionados')));
                  return;
                }

                for (final p in toRemove) {
                  final action = await _promptActionForProduct();
                  if (action == null) {
                    // usuario canceló, no procesar este producto
                    continue;
                  }
                  // registrar acción y eliminar localmente
                  _markedActions[p.suk] = action;

                  if (p.isNew) {
                    setState(() {
                      _productos.removeWhere((np) => np.suk == p.suk);
                      _newProducts.removeWhere((np) => np.suk == p.suk);
                    });
                    continue;
                  }

                  // Para productos existentes, pedimos nivel antes de eliminar
                  final nivel = await showDialog<String?>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Selecciona nivel a eliminar'),
                      children: [
                        SimpleDialogOption(onPressed: () => Navigator.of(context).pop('pv'), child: const Text('pv')),
                        SimpleDialogOption(onPressed: () => Navigator.of(context).pop('over'), child: const Text('over')),
                        TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar', style: TextStyle(color: colorBlack))),
                      ],
                    ),
                  );
                  if (nivel == null) continue;

                  final cantidad = p.niveles[nivel] ?? 0;
                  setState(() {
                    _toDeleteProducts.add({'suk': p.suk, 'cantidad': cantidad, 'nivel': nivel});
                    _productos.removeWhere((ap) => ap.suk == p.suk);
                  });
                }
              },
              icon: const Icon(Icons.delete_outline, color: colorWhite),
              label: const Text('Eliminar', style: TextStyle(color: colorWhite)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, fixedSize: const Size(140, 44)),
            ),
            ElevatedButton.icon(
              onPressed: _onSavePressed,
              icon: const Icon(Icons.save, color: colorWhite),
              label: const Text('Guardar', style: TextStyle(color: colorWhite)),
              style: ElevatedButton.styleFrom(backgroundColor: colorOrange, fixedSize: const Size(140, 44)),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para las barras de búsqueda
  Widget _buildBayField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: colorCardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: TextField(
                controller: _bayController,
                style: const TextStyle(color: colorWhite),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Bahía (BTxxx)', hintStyle: TextStyle(color: colorWhite)),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final val = _bayController.text.trim().toUpperCase();
                if (val.length == 5 && val.startsWith('BT')) {
                  await _fetchProductsForBay(val);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bahía cargada: $val')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La ubicación no pertenece a la bodega')));
                }
              },
              icon: const Icon(Icons.search, color: colorOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProductField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: colorCardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newProductController,
                style: const TextStyle(color: colorWhite),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Producto Nuevo (ID)', hintStyle: TextStyle(color: colorWhite)),
              ),
            ),
            IconButton(
              onPressed: () async {
                final pid = _newProductController.text.trim();
                if (pid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce un ID de producto')));
                  return;
                }
                final qty = await _askQuantityDialog(initial: 1);
                if (qty == null || qty <= 0) return;
                // Si ya existe en productos existentes, sumar cantidad por defecto en 'over'
                final existingIndex = _productos.indexWhere((p) => p.suk == pid);
                if (existingIndex != -1 && !_productos[existingIndex].isNew) {
                  setState(() {
                    final p = _productos[existingIndex];
                    p.niveles['over'] = (p.niveles['over'] ?? 0) + qty;
                    _newProductController.clear();
                  });
                } else {
                  // Si existe en newProducts, sumar ahí
                  final inNewIndex = _newProducts.indexWhere((p) => p.suk == pid);
                  if (inNewIndex != -1) {
                    setState(() {
                      final np = _newProducts[inNewIndex];
                      np.niveles['over'] = (np.niveles['over'] ?? 0) + qty;
                      // reflect in display list
                      final dispIndex = _productos.indexWhere((p) => p.suk == pid);
                      if (dispIndex != -1) _productos[dispIndex].niveles['over'] = np.niveles['over']!;
                      _newProductController.clear();
                    });
                  } else {
                    final newEntry = ProductoItem(nombre: pid, suk: pid, niveles: {'pv': 0, 'over': qty}, ubicacion: _currentBahiaId ?? 'BT000', isNew: true);
                    setState(() {
                      _newProducts.add(newEntry);
                      _productos.add(newEntry);
                      _newProductController.clear();
                    });
                  }
                }
              },
              icon: const Icon(Icons.add, color: colorOrange),
            ),
          ],
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
                      'Stock: ${producto.stockNum} u/d (pv:${producto.niveles['pv'] ?? 0} | over:${producto.niveles['over'] ?? 0})',
                      style: const TextStyle(color: colorWhite, fontSize: 13),
                    ),
                ],
              ),
            ),
              // Columna con ubicación y botones +/-
              Column(
                children: [
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Al presionar '-', pedimos cantidad, nivel y motivo -> registrar baja
                          final qty = await _askQuantityDialog(initial: 1);
                          if (qty == null || qty <= 0) return;

                          // Pedir nivel (pv/over)
                          final nivel = await showDialog<String?>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('Selecciona nivel'),
                              children: [
                                SimpleDialogOption(onPressed: () => Navigator.of(context).pop('pv'), child: const Text('pv')),
                                SimpleDialogOption(onPressed: () => Navigator.of(context).pop('over'), child: const Text('over')),
                                TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar', style: TextStyle(color: colorBlack))),
                              ],
                            ),
                          );
                          if (nivel == null) return;

                          // Pedir motivo similar al flujo de eliminación
                          final motivo = await _promptActionForProduct();
                          if (motivo == null) return;

                          // Registrar en bajas locales y ajustar cantidades en la UI
                          setState(() {
                            // agregar registro para ser enviado en el guardado
                            _toDeleteProducts.add({'suk': producto.suk, 'cantidad': qty, 'nivel': nivel, 'motivo': motivo});

                            // ajustar cantidad localmente
                            final current = producto.niveles[nivel] ?? 0;
                            producto.niveles[nivel] = (current - qty) < 0 ? 0 : (current - qty);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrada baja local para ${producto.suk}: $qty en $nivel')));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: colorOrange.withOpacity(0.8),
                          minimumSize: const Size(30, 30),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.remove, color: colorWhite, size: 18),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // incrementar mediante diálogo de cantidad a agregar (elegir nivel)
                          final qty = await _askQuantityDialog(initial: 1);
                          if (qty == null || qty <= 0) return;
                          final nivel = await showDialog<String?>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('Selecciona nivel'),
                              children: [
                                SimpleDialogOption(onPressed: () => Navigator.of(context).pop('pv'), child: const Text('pv')),
                                SimpleDialogOption(onPressed: () => Navigator.of(context).pop('over'), child: const Text('over')),
                                TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancelar', style: TextStyle(color: colorBlack))),
                              ],
                            ),
                          );
                          if (nivel == null) return;
                          setState(() {
                            producto.niveles[nivel] = (producto.niveles[nivel] ?? 0) + qty;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: colorOrange.withOpacity(0.8),
                          minimumSize: const Size(30, 30),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.add, color: colorWhite, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

    /// Guarda las acciones: elimina/actualiza/crea según elementos marcados
    Future<void> _onSavePressed() async {
      if (_currentBahiaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga una bahía válida (BTxxx) antes de guardar')));
        return;
      }

      final controlador = ControladorSurtido();


      // Procesar productos marcados para eliminación: registrar baja en auditoría/DB
      final int usuarioId = (widget.user?['id'] as int?) ?? 0;
      if (usuarioId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Usuario no identificado')));
        return;
      }
      for (final prod in _toDeleteProducts) {
        final String suk = prod['suk']?.toString() ?? '';
        final int productoId = int.tryParse(suk) ?? 0;
        if (productoId == 0) continue;
    final String motivo = (prod['motivo']?.toString().isNotEmpty == true)
      ? prod['motivo'].toString()
      : (_markedActions[suk] ?? 'Sin motivo');
        final String nivel = prod['nivel']?.toString() ?? 'over';
        final int cantidad = (prod['cantidad'] is int) ? prod['cantidad'] as int : int.tryParse('${prod['cantidad']}') ?? 0;

        final ok = await controlador.registrarBajaProducto(
          usuarioId: usuarioId,
          productoId: productoId,
          ubicacionId: _currentBahiaId!,
          nivel: nivel,
          cantidad: cantidad,
          motivo: motivo,
        );

        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error registrando baja producto $suk')));
        }
      }

      // Procesar existentes: actualizar cantidad por nivel (pv y over)
      for (final p in _productos.where((p) => !p.isNew)) {
        final pv = p.niveles['pv'] ?? 0;
        final over = p.niveles['over'] ?? 0;
        await controlador.createOrUpdateLevel(_currentBahiaId!, p.suk, 'pv', pv);
        await controlador.createOrUpdateLevel(_currentBahiaId!, p.suk, 'over', over);
      }

      // Procesar nuevos productos: insertar en la bahía (usamos _newProducts para evitar duplicados)
      for (final p in _newProducts) {
        final pv = p.niveles['pv'] ?? 0;
        final over = p.niveles['over'] ?? 0;
        await controlador.createProductEntries(_currentBahiaId!, p.suk, stockPv: pv, stockOver: over);
      }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operación completada')));
    // Limpiar listas locales y recargar
  _newProducts.clear();
  _toDeleteProducts.clear();
    await _fetchProductsForBay(_currentBahiaId!);
    Navigator.of(context).pop(); // volver a la vista anterior
    }
}