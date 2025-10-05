// archivo: PaginaPrincipal.dart

import 'package:flutter/material.dart';
import 'package:stockflow/Vista/VistaEscaner.dart';
import 'package:stockflow/Vista/VistaHomeItinerario.dart';
import 'package:stockflow/Vista/VistaPerfil.dart';
// Importa tus vistas (asegúrate de que las rutas sean correctas)

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _selectedIndex = 1; // Inicia con Home/Itinerario seleccionado por defecto

  // --- 1. REORDENAMOS LAS VISTAS ---
  // Ahora el índice 1 (centro) es el Itinerario
  static const List<Widget> _opcionesDeVista = <Widget>[
    VistaEscaner(),         // Índice 0
    VistaHomeItinerario(),  // Índice 1
    VistaPerfil(),          // Índice 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _opcionesDeVista.elementAt(_selectedIndex),
      
      // ==========================================================
      // === NUEVA BARRA DE NAVEGACIÓN ANIMADA ===
      // ==========================================================
      bottomNavigationBar: Container(
        height: 90, // Un poco más de altura para la animación
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              _crearNavItemAnimado(
                icono: Icons.qr_code_scanner, 
                index: 0, 
                posicion: Alignment.centerLeft
              ),
              _crearNavItemAnimado(
                icono: Icons.home, 
                index: 1, 
                posicion: Alignment.center
              ),
              _crearNavItemAnimado(
                icono: Icons.person_outline, 
                index: 2, 
                posicion: Alignment.centerRight
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFEFEFEF),
    );
  }

  // --- WIDGET HELPER PARA CREAR LOS ÍCONOS ANIMADOS ---
  Widget _crearNavItemAnimado({
    required IconData icono, 
    required int index, 
    required Alignment posicion
  }) {
    const Color colorNaranja = Color(0xFFF39C12);
    bool estaSeleccionado = _selectedIndex == index;
    bool esCentral = index == 1;

    // Define las posiciones para la animación de elevación
    double alturaNormal = 15.0;
    double alturaSeleccionado = 30.0;

    return Align(
      alignment: posicion,
      child: AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        bottom: estaSeleccionado ? alturaSeleccionado : alturaNormal,
        child: GestureDetector(
          onTap: () => _onItemTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: esCentral ? 65 : 55,
            height: esCentral ? 65 : 55,
            padding: EdgeInsets.all(esCentral ? 8 : 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // El fondo del ícono central es siempre naranja
              color: esCentral ? colorNaranja : Colors.transparent, 
              // Borde blanco para el ícono central
              border: esCentral ? Border.all(color: Colors.white, width: 4) : null,
              boxShadow: esCentral ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Icon(
              icono,
              size: 32,
              // Color del ícono:
              // - Si es central, siempre es blanco.
              // - Si es lateral, es naranja si está seleccionado, si no, es gris.
              color: esCentral 
                  ? Colors.white 
                  : (estaSeleccionado ? colorNaranja : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}