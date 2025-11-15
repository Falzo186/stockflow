import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorHorarios.dart';

const Color colorOrange = Color(0xFFF88033);
const Color colorBlack = Color(0xFF000000);
const Color colorWhite = Color(0xFFFFFFFF);

class ReporteHorariosScreen extends StatefulWidget {
  final int adminId;
  const ReporteHorariosScreen({super.key, required this.adminId});

  @override
  State<ReporteHorariosScreen> createState() => _ReporteHorariosScreenState();
}

class _ReporteHorariosScreenState extends State<ReporteHorariosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Horarios'),
        backgroundColor: colorOrange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
            Tab(icon: Icon(Icons.people), text: 'Equipo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SolicitudesPendientesTab(adminId: widget.adminId),
          const HorariosEquipoTab(),
        ],
      ),
    );
  }
}

// --- WIDGET PARA LA PESTAÑA 1 ---
class SolicitudesPendientesTab extends StatefulWidget {
  final int adminId;
  const SolicitudesPendientesTab({super.key, required this.adminId});

  @override
  State<SolicitudesPendientesTab> createState() => _SolicitudesPendientesTabState();
}

class _SolicitudesPendientesTabState extends State<SolicitudesPendientesTab> {
  late Future<List<Map<String, dynamic>>> _solicitudes;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _solicitudes = ControladorHorarios.obtenerSolicitudesPendientes();
    setState(() {});
  }

  void _aprobar(int solicitudId) async {
    final ok = await ControladorHorarios.aprobarSolicitud(solicitudId, widget.adminId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud Aprobada'), backgroundColor: Colors.green));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al aprobar'), backgroundColor: Colors.red));
    }
  }

  void _rechazar(int solicitudId) async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo de Rechazo'),
        content: TextField(
          controller: motivoController,
          decoration: const InputDecoration(hintText: 'Escribe un comentario...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, motivoController.text), child: const Text('Rechazar')),
        ],
      ),
    );

    if (motivo != null && motivo.isNotEmpty) {
      final ok = await ControladorHorarios.rechazarSolicitud(solicitudId, widget.adminId, motivo);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud Rechazada'), backgroundColor: Colors.blueGrey));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al rechazar'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _solicitudes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar solicitudes'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(child: Text('No hay solicitudes pendientes.'));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final solicitud = data[index];
            final usuario = solicitud['usuarios'] ?? {};
            final nombre = '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Pide descansar: ${solicitud['dias_solicitados'] ?? ''}'),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _rechazar(solicitud['id'] as int),
                        child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        onPressed: () => _aprobar(solicitud['id'] as int),
                        style: ElevatedButton.styleFrom(backgroundColor: colorOrange),
                        child: const Text('Aprobar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET PARA LA PESTAÑA 2 ---
class HorariosEquipoTab extends StatefulWidget {
  const HorariosEquipoTab({super.key});

  @override
  State<HorariosEquipoTab> createState() => _HorariosEquipoTabState();
}

class _HorariosEquipoTabState extends State<HorariosEquipoTab> {
  late Future<List<Map<String, dynamic>>> _equipo;

  @override
  void initState() {
    super.initState();
    _equipo = ControladorHorarios.obtenerHorariosEquipo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _equipo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar el equipo'));
        }
        final data = snapshot.data ?? [];

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final usuario = data[index];
            final horario = usuario['horarios'];
            final nombre = '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}';
            final nivel = (usuario['nivel'] == 1) ? 'Asociado' : 'Jefatura';
            String descanso = usuario['descanso_personalizado'] ?? (horario is Map ? (horario['descanso'] ?? 'N/A') : 'N/A');
            bool esPersonalizado = usuario['descanso_personalizado'] != null;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon((usuario['nivel'] == 1) ? Icons.person : Icons.supervisor_account),
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$nivel | Turno: ${horario is Map ? (horario['nombre'] ?? 'N/A') : 'N/A'}'),
                trailing: Chip(
                  label: Text('Descansa: $descanso'),
                  backgroundColor: esPersonalizado ? colorOrange.withOpacity(0.3) : Colors.grey[200],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
