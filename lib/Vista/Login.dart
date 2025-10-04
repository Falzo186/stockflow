import 'package:flutter/material.dart';
import 'package:stockflow/Vista/PaginaCarga.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos de texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  // --- MÉTODOS PARA LA LÓGICA ---

  void _login() {
    // Aquí irá la lógica de validación e inicio de sesión
    String username = _userController.text;
    String password = _passwordController.text;
    print('Intentando iniciar sesión con Usuario: $username, Contraseña: $password, Recordarme: $_rememberMe');

    // <-- COMPORTAMIENTO: LÍNEA AGREGADA PARA NAVEGAR A LA PANTALLA DE CARGA
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PaginaCarga()));
  }

  void _forgotPassword() {
    // Aquí irá la lógica para la recuperación de contraseña
    print('Botón de Olvidé mi Contraseña presionado');
  }

  void _onRememberMeChanged(bool? newValue) {
    // Lógica al cambiar el estado del checkbox
    setState(() {
      _rememberMe = newValue ?? false;
    });
    print('Recordarme cambiado a: $_rememberMe');
  }
  
  // Liberar recursos de los controladores cuando el widget se deseche
  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo curvo de color naranja
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: CustomBackgroundClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                color: const Color(0xFFE89359),
              ),
            ),
          ),
          // Contenido principal centrado
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'StockFlow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Serif', // Una fuente con serifa similar a la imagen
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 5, 5, 5),
                    ),
                  ),
                  const SizedBox(height: 120),
                  _buildTextField(
                    controller: _userController,
                    hintText: 'Usuario',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 25),
                  _buildOptionsRow(),
                  const SizedBox(height: 60),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        prefixIcon: Icon(icon, color: Color(0xFF757575)),
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: _onRememberMeChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Colors.black, width: 2),
              checkColor: Colors.white,
              activeColor: Colors.black,
            ),
            const Text(
              'Recordarme',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        TextButton(
          onPressed: _forgotPassword,
          child: const Text(
            '¿Olvidaste tu Contraseña?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD9D9D9),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5,
      ),
      child: const Text(
        'Iniciar',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget para crear la curva en el fondo
class CustomBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height * 0.25,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}