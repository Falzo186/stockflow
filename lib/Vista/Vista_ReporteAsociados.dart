import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerarioJefe.dart';
import 'package:stockflow/Vista/Vista_ReporteDetalleAsociado.dart';

// Colores
const Color colorOrange = Color(0xFFF88033);
const Color colorCardBackground = Color(0x7F736F6F);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);
const Color colorBlack = Color(0xFF000000);
const Color colorWhite = Color(0xFFFFFFFF);

class ReporteAsociadosScreen extends StatefulWidget {
  const ReporteAsociadosScreen({super.key});

  @override
  State<ReporteAsociadosScreen> createState() => _ReporteAsociadosScreenState();
}

class _ReporteAsociadosScreenState extends State<ReporteAsociadosScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _asociados = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ControladorItinerarioJefe.obtenerPromedioAsociados();
    if (mounted) {
      setState(() {
        _asociados = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Calcular Promedio General ---
    final promediosValidos = _asociados
        .map((a) => (a['promedio'] is num) ? a['promedio'] as num : null)
        .where((p) => p != null)
        .cast<num>();
    double? promedioGeneral = promediosValidos.isEmpty
        ? null
        : promediosValidos.reduce((a, b) => a + b) / promediosValidos.length;
    // --- Fin del cálculo ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Asociados'),
        backgroundColor: colorOrange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- INICIO: Gráfico Promedio General ---
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorCardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80, // Tamaño más pequeño para la lista
                        height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 10,
                              backgroundColor: colorWhite.withOpacity(0.3),
                              color: colorBackgroundScaffold,
                            ),
                            CircularProgressIndicator(
                              value: (promedioGeneral ?? 0.0) / 10.0, // Normalizar (0-10 a 0-1)
                              strokeWidth: 10,
                              color: colorOrange,
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Text(
                                promedioGeneral != null ? promedioGeneral.toStringAsFixed(1) : 'N/A',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorWhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Promedio General',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorWhite,
                              ),
                            ),
                            Text(
                              'Calificación media de todo el equipo.',
                              style: TextStyle(color: colorWhite),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // --- FIN: Gráfico Promedio General ---

                // --- INICIO: Lista de Asociados ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      itemCount: _asociados.length,
                      itemBuilder: (context, index) {
                        final asociado = _asociados[index];
                        final nombreCompleto = '${asociado['nombre'] ?? ''} ${asociado['apellido'] ?? ''}';
                        final promedioRaw = asociado['promedio'];
                        final double? promedio = (promedioRaw is num) ? promedioRaw.toDouble() : (promedioRaw != null ? double.tryParse(promedioRaw.toString()) : null);
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: colorCardBackground,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorOrange,
                              child: Text(
                                promedio != null ? promedio.toStringAsFixed(1) : 'N/A',
                                style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(nombreCompleto, style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              promedio != null ? 'Promedio de revisiones' : 'Sin tareas revisadas',
                              style: const TextStyle(color: colorWhite),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: colorWhite),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReporteDetalleAsociadoScreen(asociado: asociado),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // --- FIN: Lista de Asociados ---
              ],
            ),
    );
  }
}
