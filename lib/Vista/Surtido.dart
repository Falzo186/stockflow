import 'package:flutter/material.dart';

// 🎨 Colores principales
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F); // Gris oscuro con opacidad
const Color colorSearchFieldBackground = Color(0xFFD9D9D9);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorDarkGrayButtons = Color(0xFF736F6F);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);

void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// ## App principal
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Surtido',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: const SurtidoScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧭 Pantalla principal
// -----------------------------------------------------------------------------
class SurtidoScreen extends StatefulWidget {
  const SurtidoScreen({super.key});

  @override
  State<SurtidoScreen> createState() => _SurtidoScreenState();
}

class _SurtidoScreenState extends State<SurtidoScreen> {
  bool isPVSelected = true;
  bool selectAll = false;

  final List<Map<String, dynamic>> products = [
    {
      'name': 'LED Smart Bulb',
      'suk': '202399',
      'stock_pv': '200 u/d',
      'stock_over': '180 u/d',
      'time': 'Hoy, 14:30',
      'selected': false
    },
    {
      'name': 'Aspiradora Portátil',
      'suk': '845233',
      'stock_pv': '100 u/d',
      'stock_over': '90 u/d',
      'time': 'Hoy, 14:30',
      'selected': false
    },
    {
      'name': 'Extensión Eléctrica',
      'suk': '309822',
      'stock_pv': '300 u/d',
      'stock_over': '290 u/d',
      'time': 'Hoy, 14:30',
      'selected': false
    },
    {
      'name': 'Foco LED RGB',
      'suk': '120493',
      'stock_pv': '150 u/d',
      'stock_over': '130 u/d',
      'time': 'Hoy, 14:30',
      'selected': false
    },
  ];

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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductListItem(
                    data: products[index],
                    isPVSelected: isPVSelected,
                    onChanged: (value) {
                      setState(() {
                        products[index]['selected'] = value;
                        selectAll = products.every((p) => p['selected']);
                      });
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

  // ---------------------------------------------------------------------------
  // 🟠 Header superior
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // 🔍 Campos de búsqueda
  // ---------------------------------------------------------------------------
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildSearchField(label: 'Bahía'),
          const SizedBox(height: 10),
          _buildSearchField(label: 'Producto Nuevo'),
        ],
      ),
    );
  }

  Widget _buildSearchField({required String label}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorWhite,
              ),
            ),
            const Spacer(),
            const Icon(Icons.search, color: colorOrange),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔄 Selector PV / OVER (tipo pestañas con ElevatedButton)
  // ---------------------------------------------------------------------------
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
              onPressed: () => setState(() => isPVSelected = true),
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
                  color: isPVSelected
                      ? colorWhite
                      : colorWhite.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () => setState(() => isPVSelected = false),
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
                  color: !isPVSelected
                      ? colorWhite
                      : colorWhite.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⬇️ Botones inferiores
  // ---------------------------------------------------------------------------
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
              products.removeWhere((product) => product['selected'] == true);
              selectAll = false;
            });
          }),
          _buildActionButton('Aceptar', Icons.check_circle_outline, onPressed: () {}),
          _buildActionButton('Guardar', Icons.save_outlined, isPrimary: true, onPressed: () {}),
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

// -----------------------------------------------------------------------------
// 🧾 Item de producto con checkbox y botones + / -
// -----------------------------------------------------------------------------
class ProductListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isPVSelected;
  final ValueChanged<bool?>? onChanged;

  const ProductListItem({
    super.key,
    required this.data,
    required this.isPVSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stockLabel = isPVSelected ? 'Stock: ' : 'Cuarto de Stock: ';
    final stockValue = isPVSelected ? data['stock_pv'] : data['stock_over'];

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
              value: data['selected'],
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
                    data['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                  Text(
                    'SUK: ${data['suk']}',
                    style: const TextStyle(fontSize: 13, color: colorWhite),
                  ),
                  Text(
                    '$stockLabel$stockValue',
                    style: const TextStyle(fontSize: 13, color: colorWhite),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data['time'],
                  style: const TextStyle(fontSize: 12, color: colorWhite),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
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
                      onPressed: () {},
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
