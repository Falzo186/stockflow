import 'package:flutter/material.dart';

// 🎨 Definición de Colores
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorButtonBackground = Color(0xFFD9D9D9);
const Color colorOrange = Color(0xFFF88033);
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
      title: 'StockFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: colorBackgroundScaffold,
        useMaterial3: true,
      ),
      home: const DeliveryTrackingScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Pantalla principal: Seguimiento de Entrega
// -----------------------------------------------------------------------------
class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ItineraryCard(),
              SizedBox(height: 20),
              Icon(Icons.local_shipping, size: 100, color: colorCardBackground),
              SizedBox(height: 20),
              StockCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Tarjeta de Itinerario
// -----------------------------------------------------------------------------
class ItineraryCard extends StatelessWidget {
  const ItineraryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinerario',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: colorWhite),
            ),
            const SizedBox(height: 15),
            const ItineraryItem(
              title: 'Bahia 10-00-04',
              status: 'Completada',
              progress: 1.0,
              iconAsset: 'assets/CardChecklist.png',
            ),
            const SizedBox(height: 10),
            const ItineraryItem(
              title: 'Bahia 11-00-08',
              status: 'En Progreso',
              progress: 0.5,
              iconAsset: 'assets/CardChecklist.png',
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ver más pulsado')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorButtonBackground,
                  foregroundColor: colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  fixedSize: const Size(106, 37),
                  elevation: 0,
                ),
                child: const Text(
                  'Ver Mas...',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Elemento de Itinerario
// -----------------------------------------------------------------------------
class ItineraryItem extends StatelessWidget {
  final String title;
  final String status;
  final double progress;
  final String iconAsset;

  const ItineraryItem({
    super.key,
    required this.title,
    required this.status,
    required this.progress,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.task_alt, color: colorOrange, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorWhite),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: colorWhite.withOpacity(0.3),
                      color: colorOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${(progress * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorOrange)),
                Text(status,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorWhite)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Tarjeta de Surtido
// -----------------------------------------------------------------------------
class StockCard extends StatelessWidget {
  const StockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Surtido',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorWhite)),
            const SizedBox(height: 25),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStockButton(
                  context: context,
                  icon: Icons.upload_file,
                  text: 'OVER',
                  width: 180,
                ),
                const SizedBox(height: 20),
                _buildStockButton(
                  context: context,
                  icon: Icons.store_mall_directory,
                  text: 'PV (Punto de Venta)',
                  width: 220,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    double width = 117,
  }) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$text pulsado')));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorCardBackground.withOpacity(0.5),
        foregroundColor: colorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        fixedSize: Size(width, 50),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorOrange, size: 22),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ## Barra de Navegación Inferior
// -----------------------------------------------------------------------------
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: colorCardBackground,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavBarItem(icon: Icons.home, isPrimary: true),
          NavBarItem(icon: Icons.qr_code_scanner, isScanner: true),
          NavBarItem(icon: Icons.person),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final bool isScanner;

  const NavBarItem(
      {super.key, required this.icon, this.isPrimary = false, this.isScanner = false});

  @override
  Widget build(BuildContext context) {
    if (isScanner) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: colorOrange, width: 2),
        ),
        child: const Icon(Icons.qr_code_scanner, color: colorOrange, size: 30),
      );
    }

    return Icon(icon,
        color: isPrimary ? colorOrange : colorOrange.withOpacity(0.7), size: 34);
  }
}
