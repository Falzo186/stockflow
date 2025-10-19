import 'package:flutter/material.dart';

// --- Colores ---
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF000000);
const Color colorDarkGrayButtons = Color(0x7F736F6F);
const Color colorSelectorBackground = Color(0xFFD9D9D9);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asignar Bahías',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: const AssignBaysScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// Pantalla Principal
// -----------------------------------------------------------------------------
class AssignBaysScreen extends StatefulWidget {
  const AssignBaysScreen({super.key});

  @override
  State<AssignBaysScreen> createState() => _AssignBaysScreenState();
}

enum BayView { assigned, available }

class _AssignBaysScreenState extends State<AssignBaysScreen> {
  BayView currentView = BayView.assigned;

  final List<Map<String, dynamic>> assignedBays = const [
    {'name': 'Bahía 10-00-04', 'area': 'Iluminación'},
    {'name': 'Bahía 11-00-08', 'area': 'Iluminación'},
    {'name': 'Bahía 10-00-07', 'area': 'Iluminación'},
    {'name': 'Bahía 11-00-05', 'area': 'Iluminación'},
    {'name': 'Bahía 10-00-01', 'area': 'Iluminación'},
    {'name': 'Bahía 10-00-13', 'area': 'Iluminación'},
    {'name': 'Bahía 10-01-20', 'area': 'Iluminación'},
  ];

  final List<Map<String, dynamic>> availableBays = const [
    {'name': 'Bahía 11-00-03', 'area': 'Iluminación'},
    {'name': 'Bahía 11-00-15', 'area': 'Iluminación'},
    {'name': 'Bahía 09-00-02', 'area': 'Pinturas'},
    {'name': 'Bahía 09-00-05', 'area': 'Pinturas'},
    {'name': 'Bahía 09-00-14', 'area': 'Pinturas'},
    {'name': 'Bahía 15-00-03', 'area': 'Plomería'},
    {'name': 'Bahía 15-00-17', 'area': 'Plomería'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isAssigned = currentView == BayView.assigned;
    final List<Map<String, dynamic>> currentList = isAssigned ? assignedBays : availableBays;
    final String title = isAssigned ? 'Bahías Asignadas' : 'Bahías Disponibles';
    final IconData actionIcon = isAssigned ? Icons.close : Icons.check;
    final Color actionColor = isAssigned ? Colors.redAccent : colorOrange;

    return Scaffold(
      backgroundColor: colorBackgroundScaffold,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 30),
            _buildViewSelector(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  return BayAssignmentItem(
                    name: currentList[index]['name']!,
                    area: currentList[index]['area']!,
                    actionIcon: actionIcon,
                    actionColor: actionColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Seleccionaste ${currentList[index]['name']}')),
                      );
                    },
                  );
                },
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colorWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorOrange, width: 2),
                ),
                child: const Icon(Icons.arrow_back, color: colorOrange),
              ),
            ),
          ),
          const Text(
            'Asignar Bahías',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: colorBlack,
            ),
          ),
        ],
      ),
    );
  }

  // Campo de búsqueda
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colorCardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Icon(Icons.search, color: colorOrange),
              SizedBox(width: 10),
              Text('Buscar...', style: TextStyle(color: colorWhite)),
            ],
          ),
        ),
      ),
    );
  }

  // Selector de vista
  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => currentView = BayView.assigned),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: currentView == BayView.assigned
                      ? colorSelectorBackground
                      : colorCardBackground,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  border: Border.all(color: colorCardBackground),
                ),
                child: Center(
                  child: Text(
                    'Asignadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: currentView == BayView.assigned ? colorBlack : colorWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => currentView = BayView.available),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: currentView == BayView.available
                      ? colorSelectorBackground
                      : colorCardBackground,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                  border: Border.all(color: colorCardBackground),
                ),
                child: Center(
                  child: Text(
                    'Disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: currentView == BayView.available ? colorBlack : colorWhite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón Guardar
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Material(
        color: colorDarkGrayButtons,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guardado exitosamente')),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            width: double.infinity,
            height: 40,
            child: Center(
              child: Text(
                'Guardar',
                style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Ítem de bahía como botón
// -----------------------------------------------------------------------------
class BayAssignmentItem extends StatelessWidget {
  final String name;
  final String area;
  final IconData actionIcon;
  final Color actionColor;
  final VoidCallback onTap;

  const BayAssignmentItem({
    super.key,
    required this.name,
    required this.area,
    required this.actionIcon,
    required this.actionColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorCardBackground,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: colorOrange, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_box_outline_blank, color: colorOrange, size: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$name (Área de $area)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorWhite),
                  ),
                ),
                Icon(actionIcon, color: actionColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
