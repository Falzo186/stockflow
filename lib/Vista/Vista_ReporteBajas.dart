import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/Controlador/ControladorSurtido.dart';

const Color colorOrange = Color(0xFFF88033);

class ReporteBajasScreen extends StatefulWidget {
  const ReporteBajasScreen({super.key});
  @override
  State<ReporteBajasScreen> createState() => _ReporteBajasScreenState();
}

class _ReporteBajasScreenState extends State<ReporteBajasScreen> {
  late Future<List<Map<String, dynamic>>> _reporte;

  @override
  void initState() {
    super.initState();
    _reporte = ControladorSurtido.obtenerReporteBajas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Bajas'),
        backgroundColor: colorOrange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reporte,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el reporte'));
          }
          final bajas = snapshot.data ?? [];
          if (bajas.isEmpty) {
            return const Center(child: Text('No se han registrado bajas.'));
          }
          return ListView.builder(
            itemCount: bajas.length,
            itemBuilder: (context, index) {
              final baja = bajas[index];
              final String fecha = (baja['fecha'] != null)
                  ? DateFormat('dd/MM/yyyy hh:mm a', 'es_MX').format(DateTime.parse(baja['fecha'].toString()))
                  : 'N/A';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(baja['nombre_producto'] ?? 'Producto no encontrado'),
                  subtitle: Text('Motivo: ${baja['motivo'] ?? 'N/A'}\nPor: ${baja['nombre_usuario'] ?? 'N/A'} - $fecha'),
                  trailing: Chip(
                    label: Text('-${baja['cantidad'] ?? 0} (Rango ${baja['rango_producto'] ?? '?'})'),
                    backgroundColor: Colors.red[100],
                    labelStyle: TextStyle(color: Colors.red[800]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
