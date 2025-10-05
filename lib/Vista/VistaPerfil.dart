// archivo: vista_perfil.dart

import 'package:flutter/material.dart';

class VistaPerfil extends StatelessWidget {
  const VistaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorFondo = Color(0xFFEFEFEF);
    const Color colorNaranja = Color(0xFFF5CBA7); // Un naranja más suave para el perfil
    const Color colorTextoGris = Color(0xFF566573);

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Botón de Menú ---
              Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.white,
                    elevation: 4,
                  ),
                  child: const Icon(Icons.menu, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 30),

              // --- Información del Perfil ---
              const CircleAvatar(
                radius: 80,
                backgroundColor: colorNaranja,
                child: Icon(Icons.person_outline, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Elena Martin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorTextoGris,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cargo: Asociado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: colorTextoGris),
              ),
              Text(
                'ID: 12345',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: colorTextoGris),
              ),
              const SizedBox(height: 30),

              // --- Chip de Correo ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: colorNaranja,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'Correo: ElenaMartin@empresa.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}