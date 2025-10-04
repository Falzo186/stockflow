import 'dart:async';
import 'package:flutter/material.dart';
import 'paginaprincipal.dart'; // Importamos la página del menú principal

class PaginaCarga extends StatefulWidget {
  const PaginaCarga({super.key});

  @override
  State<PaginaCarga> createState() => _PaginaCargaState();
}

class _PaginaCargaState extends State<PaginaCarga> {

  @override
  void initState() {
    super.initState();
    // Inicia un temporizador de 2 segundos
    Timer(const Duration(seconds: 2), () {
      // Usamos pushReplacement para que el usuario no pueda "volver" a la pantalla de carga
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE89359), 
      body: Center(
        child: Icon(
          Icons.local_shipping,
          color: Colors.black,
          size: 150.0,
        ),
      ),
    );
  }
}