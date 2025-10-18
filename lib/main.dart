import 'package:flutter/material.dart';
import 'package:stockflow/BaseDeDatosLocal/SupabaseConfig.dart';
import 'package:stockflow/Vista/Login.dart' show LoginPage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init(); // Inicializamos Supabase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StockFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
