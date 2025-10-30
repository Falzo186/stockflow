import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControladorLogin {
  /// Intenta autenticar con la tabla `usuarios` usando correo y contraseña.
  ///
  /// Retorna un Map<String,dynamic> con los campos del usuario en caso de éxito,
  /// retorna null si las credenciales no coinciden.
  static Future<Map<String, dynamic>?> login(String correo, String contrasena) async {
    final resp = await SupabaseConfig.client
        .from('usuarios')
        .select('id,nombre,apellido,correo,nivel,activo')
        .eq('correo', correo)
        .eq('contrasena', contrasena)
        .maybeSingle();

    if (resp == null) return null;

    return Map<String, dynamic>.from(resp as Map);
  }

  /// Guarda o elimina el correo en SharedPreferences según [remember].
  static Future<void> saveRememberedEmail(bool remember, String correo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (remember) {
        await prefs.setString('saved_email', correo);
      } else {
        await prefs.remove('saved_email');
      }
    } catch (_) {
      // No bloquear la app si SharedPreferences falla.
    }
  }

  /// Recupera el correo guardado (si existe) en SharedPreferences.
  static Future<String?> loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('saved_email');
    } catch (_) {
      return null;
    }
  }
}