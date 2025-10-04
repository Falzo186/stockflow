// En tu archivo: lib/Vista/pagina_login_2.dart

import 'package:flutter/material.dart';
import 'package:stockflow/Vista/PaginaPrincipal2.dart';
// 1. IMPORTANTE: Importa la nueva página principal

class PaginaLogin2 extends StatefulWidget {
  const PaginaLogin2({super.key});

  @override
  State<PaginaLogin2> createState() => _PaginaLogin2State();
}

class _PaginaLogin2State extends State<PaginaLogin2> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  // --- Método ACTUALIZADO ---
  void _acceder() {
    final String usuario = _usuarioController.text;
    final String contrasena = _contrasenaController.text;
    print('Accediendo con Usuario: $usuario, Contraseña: $contrasena');
    
    // 2. NAVEGACIÓN A LA NUEVA PÁGINA PRINCIPAL
    // Usamos pushReplacement para que el usuario no pueda "volver" a la pantalla de login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PaginaPrincipal2()),
    );
  }

  void _olvideContrasena() {
    print('Botón "Olvidé mi contraseña" presionado');
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... el resto de tu código de build de PaginaLogin2 no cambia ...
    const Color colorFondo = Color(0xFFD3C5C0);
    const Color colorContenedor = Color(0xFFC4D1F3);
    const Color colorCampos = Color(0xFF90C8C3);
    const Color colorBotonAcceder = Color(0xFF659890);
    const Color colorTextoBotones = Color(0xFF8E7C77);

    return Scaffold(
      backgroundColor: colorFondo,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorCampos,
                    shape: const StadiumBorder(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  ),
                  child: const Text('Login', style: TextStyle(color: colorTextoBotones, fontSize: 22, fontWeight: FontWeight.bold,),),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: colorContenedor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 30),
                      _crearCampoDeTexto(
                        controller: _usuarioController,
                        pista: 'Usuario',
                        icono: Icons.person_outline,
                        color: colorCampos,
                      ),
                      const SizedBox(height: 20),
                      _crearCampoDeTexto(
                        controller: _contrasenaController,
                        pista: 'Contraseña',
                        icono: Icons.lock_outline,
                        esContrasena: true,
                        color: colorCampos,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _acceder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorBotonAcceder,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 18),
                        ),
                        child: const Text('Acceder', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _olvideContrasena,
                  child: const Text('¿Olvidaste la contraseña?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500,),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   Widget _crearCampoDeTexto({
    required TextEditingController controller,
    required String pista,
    required IconData icono,
    required Color color,
    bool esContrasena = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: esContrasena,
      decoration: InputDecoration(
        hintText: pista,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icono, color: Colors.white),
        filled: true,
        fillColor: color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
      textAlignVertical: TextAlignVertical.center,
    );
  }
}