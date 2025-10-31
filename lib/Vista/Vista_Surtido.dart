import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorSurtido.dart';
// Ajusta la ruta según donde tengas el modelo
import 'package:stockflow/Modelo/ProductoUbicacion.dart';

// 🎨 Colores principales
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorSearchFieldBackground = Color(0xFFD9D9D9);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorDarkGrayButtons = Color(0xFF736F6F);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

class SurtidoScreen extends StatefulWidget {
  const SurtidoScreen({super.key});

  @override
  State<SurtidoScreen> createState() => _SurtidoScreenState();
}

class _SurtidoScreenState extends State<SurtidoScreen> {
  bool isPVSelected = true;
  bool selectAll = false;

  final TextEditingController _bayController = TextEditingController();
  bool _isLoading = false;

  // Lista de productos agregados (solo id y stocks)
  // 'products' contiene la lista FILTRADA para la UI (según PV/OVER)
  List<Map<String, dynamic>> products = [];

  // Lista completa con stocks numéricos; se usa como fuente para filtrar
  List<Map<String, dynamic>> _allProducts = [];
  
  // Controlador para el campo de "Producto Nuevo"
  final TextEditingController _newProductController = TextEditingController();

  // Productos que se agregan localmente hasta presionar Guardar
  List<Map<String, dynamic>> _newProducts = [];

  // Bahía actualmente cargada (para usar en Guardar)
  String? _currentBahiaId;

  // IDs marcados para borrar en la base de datos al guardar
  final Set<String> _toDeleteIds = {};

  @override
  void dispose() {
    _bayController.dispose();
    _newProductController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    if (_currentBahiaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione/obtenga una bahía antes de guardar')));
      return;
    }

    setState(() => _isLoading = true);
    final controlador = ControladorSurtido();
    final String bahia = _currentBahiaId!;

    final List<String> errors = [];

    // 1) Borrar productos marcados
    for (final pid in _toDeleteIds) {
      final ok = await controlador.deleteProduct(bahia, pid);
      if (!ok) errors.add('Eliminar $pid');
    }

    // 2) Actualizar productos existentes si hubo cambios
    for (final p in _allProducts) {
      final pid = p['product_id'].toString();
      final num stockPv = p['stock_pv'] ?? 0;
      final num stockOver = p['stock_over'] ?? 0;
      final num origPv = p['orig_stock_pv'] ?? 0;
      final num origOver = p['orig_stock_over'] ?? 0;

      // PV
      if (stockPv != origPv) {
        if (origPv == 0 && stockPv > 0) {
          final ok = await controlador.insertProductLevel(bahia, pid, 'pv', stockPv.toInt());
          if (!ok) errors.add('Insert PV $pid');
        } else {
          final ok = await controlador.updateProductLevelQuantity(bahia, pid, 'pv', stockPv.toInt());
          if (!ok) errors.add('Update PV $pid');
        }
      }

      // OVER
      if (stockOver != origOver) {
        if (origOver == 0 && stockOver > 0) {
          final ok = await controlador.insertProductLevel(bahia, pid, 'over', stockOver.toInt());
          if (!ok) errors.add('Insert OVER $pid');
        } else {
          final ok = await controlador.updateProductLevelQuantity(bahia, pid, 'over', stockOver.toInt());
          if (!ok) errors.add('Update OVER $pid');
        }
      }
    }

    // 3) Crear nuevos productos
    for (final p in _newProducts) {
      final pid = p['product_id'].toString();
      final int stockPv = (p['stock_pv'] as num?)?.toInt() ?? 0;
      final int stockOver = (p['stock_over'] as num?)?.toInt() ?? 0;
      final ok = await controlador.createProductEntries(bahia, pid, stockPv: stockPv, stockOver: stockOver);
      if (!ok) errors.add('Crear $pid');
    }

    setState(() => _isLoading = false);

    if (errors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sincronización completada')));
      // Limpiar y recargar
      _newProducts.clear();
      _toDeleteIds.clear();
      await _fetchProductsForBay(bahia);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Algunos errores: ${errors.join(', ')}')));
    }
  }

  Future<void> _fetchProductsForBay(String bayId) async {
    if (bayId.length != 5) return;
    setState(() => _isLoading = true);

    try {
      final List<ProductoUbicacion> ubicaciones =
          await ControladorSurtido().buscarProductosBahia(bayId);

      final Map<String, Map<String, dynamic>> aggregated = {};

      for (var u in ubicaciones) {
        final String pid = u.productoId.toString();
        aggregated.putIfAbsent(pid, () {
          return {
            'product_id': pid,
            // guardamos como números para poder filtrar/sumar
            'stock_pv': 0,
            'stock_over': 0,
            // originales para detectar cambios
            'orig_stock_pv': 0,
            'orig_stock_over': 0,
            'selected': false,
            'isNew': false,
          };
        });

        final nivel = u.nivel.toString().toLowerCase();
        final cantidadRaw = u.cantidad;

        // Normalizar cantidad a num (int/double) usando toString + tryParse
        final num cantidadNum = num.tryParse(cantidadRaw.toString()) ?? 0;

        // Sumamos cantidades si hay múltiples ubicaciones del mismo producto
        if (cantidadNum > 0) {
          if (nivel == 'pv') {
            final sum = (aggregated[pid]!['stock_pv'] as num) + cantidadNum;
            aggregated[pid]!['stock_pv'] = sum;
            aggregated[pid]!['orig_stock_pv'] = sum;
          } else {
            final sum = (aggregated[pid]!['stock_over'] as num) + cantidadNum;
            aggregated[pid]!['stock_over'] = sum;
            aggregated[pid]!['orig_stock_over'] = sum;
          }
        }
      }

      setState(() {
        // Guardamos completa y luego filtramos según la vista
        _allProducts = aggregated.values.toList();
        // Guardar la bahía actual
        _currentBahiaId = bayId;
        _applyFilter();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener productos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Filtra `_allProducts` y actualiza `products` según `isPVSelected`.
  void _applyFilter() {
    setState(() {
      final List<Map<String, dynamic>> filtered = [];
      if (isPVSelected) {
        filtered.addAll(_allProducts.where((product) {
          final num stock = product['stock_pv'] ?? 0;
          return stock > 0;
        }));

        // Incluir nuevos productos que tengan stock en PV
        filtered.addAll(_newProducts.where((product) {
          final num stock = product['stock_pv'] ?? 0;
          return stock > 0;
        }));
      } else {
        filtered.addAll(_allProducts.where((product) {
          final num stock = product['stock_over'] ?? 0;
          return stock > 0;
        }));

        // Incluir nuevos productos que tengan stock en OVER
        filtered.addAll(_newProducts.where((product) {
          final num stock = product['stock_over'] ?? 0;
          return stock > 0;
        }));
      }

      products = filtered;
      selectAll = false;
    });
  }

  /// Cambia la cantidad (delta puede ser +1 o -1) para el producto indicado
  void _changeQuantity(String productId, int delta, bool pvSelected) {
    setState(() {
      // Buscar en nuevos primero
      final ni = _newProducts.indexWhere((p) => p['product_id'] == productId);
      if (ni != -1) {
        final key = pvSelected ? 'stock_pv' : 'stock_over';
        final current = (_newProducts[ni][key] as num?) ?? 0;
        final newVal = (current + delta) < 0 ? 0 : (current + delta);
        _newProducts[ni][key] = newVal;
        _applyFilter();
        return;
      }

      // Buscar en allProducts
      final ai = _allProducts.indexWhere((p) => p['product_id'] == productId);
      if (ai != -1) {
        final key = pvSelected ? 'stock_pv' : 'stock_over';
        final current = (_allProducts[ai][key] as num?) ?? 0;
        final newVal = (current + delta) < 0 ? 0 : (current + delta);
        _allProducts[ai][key] = newVal;
        // No cambiamos orig_* aquí; los usamos en el guardado para detectar diffs
        _applyFilter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 10),
            _buildSearchSection(),
            const SizedBox(height: 15),
            _buildTabToggle(),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final item = products[index];
                                return ProductListItem(
                                  data: item,
                                  isPVSelected: isPVSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      products[index]['selected'] = value ?? false;
                                      final pid = item['product_id'];
                                      final ai = _allProducts.indexWhere((p) => p['product_id'] == pid);
                                      if (ai != -1) {
                                        _allProducts[ai]['selected'] = value ?? false;
                                      } else {
                                        final ni = _newProducts.indexWhere((p) => p['product_id'] == pid);
                                        if (ni != -1) _newProducts[ni]['selected'] = value ?? false;
                                      }
                                      selectAll = products.every((p) => p['selected'] == true);
                                    });
                                  },
                                  onIncrement: () {
                                    final pid = item['product_id'];
                                    _changeQuantity(pid, 1, isPVSelected);
                                  },
                                  onDecrement: () {
                                    final pid = item['product_id'];
                                    _changeQuantity(pid, -1, isPVSelected);
                                  },
                                );
                              },
                    ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
          const Text(
            'Surtido',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorBlack,
            ),
          ),
          const Spacer(),
          Checkbox(
            value: selectAll,
            onChanged: (value) {
              setState(() {
                selectAll = value ?? false;
                for (var product in products) {
                  product['selected'] = selectAll;
                }
              });
            },
            activeColor: colorOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildBayField(),
          const SizedBox(height: 10),
          _buildSearchField(label: 'Producto Nuevo'),
        ],
      ),
    );
  }

  Widget _buildBayField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _bayController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Bahía (5 dígitos)',
                  hintStyle: TextStyle(color: colorWhite),
                ),
                style:
                    const TextStyle(color: colorWhite, fontWeight: FontWeight.w600),
                onChanged: (value) {
                  if (value.length == 5) {
                    _fetchProductsForBay(value);
                  }
                },
                onSubmitted: (value) {
                  if (value.length == 5) _fetchProductsForBay(value);
                },
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                final val = _bayController.text.trim();
                if (val.length == 5) {
                  _fetchProductsForBay(val);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Introduce un ID de bahía de 5 dígitos')),
                  );
                }
              },
              icon: const Icon(Icons.search, color: colorOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({required String label}) {
    // Campo para agregar nuevo producto (ID) y botón de agregar
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newProductController,
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: const TextStyle(color: colorWhite),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: colorWhite, fontWeight: FontWeight.w600),
                onSubmitted: (_) => _addNewProductFromField(),
              ),
            ),
            IconButton(
              onPressed: _addNewProductFromField,
              icon: const Icon(Icons.add, color: colorOrange),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewProductFromField() {
    final pid = _newProductController.text.trim();
    if (pid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce un ID de producto')));
      return;
    }

    // Evitar duplicados
    final existsInAll = _allProducts.any((p) => p['product_id'] == pid);
    final existsInNew = _newProducts.any((p) => p['product_id'] == pid);
    if (existsInAll || existsInNew) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto ya agregado')));
      _newProductController.clear();
      return;
    }

    final newEntry = {
      'product_id': pid,
      'stock_pv': isPVSelected ? 1 : 0,
      'stock_over': isPVSelected ? 0 : 1,
      'selected': false,
      'isNew': true,
    };

    setState(() {
      _newProducts.add(newEntry);
      _newProductController.clear();
      _applyFilter();
    });
  }

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: colorCardBackground,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() => isPVSelected = true);
                _applyFilter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPVSelected ? colorOrange : Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
                ),
              ),
              child: Text(
                'PV',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPVSelected ? colorWhite : colorWhite.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() => isPVSelected = false);
                _applyFilter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isPVSelected ? colorOrange : Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
                ),
              ),
              child: Text(
                'OVER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: !isPVSelected ? colorWhite : colorWhite.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton('Eliminar', Icons.delete_outline, onPressed: () {
            setState(() {
              // Para cada producto seleccionado, si es nuevo lo quitamos de _newProducts,
              // si es existente lo marcamos para borrar y lo quitamos de _allProducts.
              final toRemove = products.where((p) => p['selected'] == true).toList();
              for (final p in toRemove) {
                final pid = p['product_id'];
                if (p['isNew'] == true) {
                  _newProducts.removeWhere((np) => np['product_id'] == pid);
                } else {
                  _toDeleteIds.add(pid.toString());
                  _allProducts.removeWhere((ap) => ap['product_id'] == pid);
                }
              }
              _applyFilter();
              selectAll = false;
            });
          }),
          _buildActionButton('Aceptar', Icons.check_circle_outline, onPressed: () {}),
          _buildActionButton('Guardar', Icons.save_outlined, isPrimary: true, onPressed: () {
            _onSavePressed();
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon,
      {bool isPrimary = false, VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: colorWhite),
      label: Text(
        text,
        style: const TextStyle(
          color: colorWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? colorOrange : colorDarkGrayButtons,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        fixedSize: const Size(100, 40),
        elevation: 4,
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isPVSelected;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductListItem({
    super.key,
    required this.data,
    required this.isPVSelected,
    this.onChanged,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
  final stockLabel = isPVSelected ? 'Stock: ' : 'Cuarto de Stock: ';
  final num? stockNum = isPVSelected
    ? (data['stock_pv'] is num ? data['stock_pv'] as num : num.tryParse(data['stock_pv']?.toString() ?? '0'))
    : (data['stock_over'] is num ? data['stock_over'] as num : num.tryParse(data['stock_over']?.toString() ?? '0'));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Row(
          children: [
            Checkbox(
              value: (data['selected'] as bool?) ?? false,
              onChanged: onChanged,
              activeColor: colorOrange,
              checkColor: colorWhite,
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb_outline, color: colorOrange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${data['product_id']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                  if (stockNum != null && stockNum > 0)
                    Text(
                      '$stockLabel${stockNum} u/d',
                      style: const TextStyle(fontSize: 13, color: colorWhite),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onDecrement,
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
                      onPressed: onIncrement,
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
}
