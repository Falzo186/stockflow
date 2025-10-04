import 'package:flutter/material.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _selectedIndex = 0; // Índice del ícono seleccionado en el BottomNavigationBar

  // Lista de widgets (páginas) que se mostrarán en el body
  // Puedes reemplazar estos Text con tus vistas reales para cada sección.
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Contenido de Inicio', style: TextStyle(fontSize: 24))),
    Center(child: Text('Contenido de Escanear', style: TextStyle(fontSize: 24))),
    Center(child: Text('Contenido de Perfil', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar se ha quitado para simular el diseño de la imagen que no lo muestra
      // Puedes agregarlo si lo necesitas para otras secciones.
      // appBar: AppBar(
      //   title: const Text('Menú Principal'),
      //   backgroundColor: const Color(0xFF212121),
      //   foregroundColor: Colors.white,
      //   automaticallyImplyLeading: false, 
      // ),
      body: _widgetOptions.elementAt(_selectedIndex), // Muestra el widget correspondiente al índice seleccionado
      
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter, // Asegura que los elementos se alineen abajo
        children: [
          // Fondo redondeado de la barra de navegación
          Container(
            height: 80, // Altura total de la barra de navegación
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco de la barra
              borderRadius: BorderRadius.circular(30), // Bordes redondeados
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Sombra para darle profundidad
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(Icons.home_outlined, 0, 'Inicio'),
                // El ícono del centro lo manejaremos por separado
                const SizedBox(width: 80), // Espacio para el botón flotante
                _buildNavItem(Icons.person_outline, 2, 'Perfil'),
              ],
            ),
          ),
          // Botón flotante central "Escanear"
          Positioned(
            bottom: 30, // Ajusta la posición vertical del botón
            child: GestureDetector(
              onTap: () => _onItemTapped(1), // Cuando se toca, selecciona el índice 1 (Escanear)
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE89359), // Color naranja del botón central
                  shape: BoxShape.circle, // Forma circular
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.qr_code_scanner, // Icono de escáner para el centro
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0E0E0), // Fondo gris claro para el body
    );
  }

  // Helper para construir los ítems de navegación (Inicio y Perfil)
  Widget _buildNavItem(IconData icon, int index, String label) {
    return Expanded(
      child: Material(
        color: Colors.transparent, // Necesario para que el splash effect no tenga fondo
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: _selectedIndex == index ? const Color(0xFFE89359) : Colors.grey[700], // Color naranja si está seleccionado
              ),
              // Puedes añadir un Text para el label si lo deseas
              // Text(
              //   label,
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: _selectedIndex == index ? const Color(0xFFE89359) : Colors.grey[700],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}