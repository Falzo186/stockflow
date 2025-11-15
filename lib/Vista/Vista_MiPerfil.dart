import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/Controlador/ControladorHorarios.dart';
import 'package:table_calendar/table_calendar.dart';

const Color colorOrange = Color(0xFFF88033);
const Color colorBlack = Color(0xFF000000);
const Color colorWhite = Color(0xFFFFFFFF);

class MiPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const MiPerfilScreen({super.key, required this.user});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profileData;
  Set<DateTime> _selectedDays = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ControladorHorarios.obtenerHorarioUsuario(widget.user['id']);
    if (mounted) {
      setState(() {
        _profileData = data;
        _loading = false;
      });
    }
  }

  String _getDescanso() {
    // REGLA: Usamos los datos frescos de _profileData
    if (_profileData?['descanso_personalizado'] != null && _profileData!['descanso_personalizado'].toString().isNotEmpty) {
      return _profileData!['descanso_personalizado'].toString();
    }
    // Si no, usamos el del turno
    final horarioMap = (_profileData != null && _profileData!['horarios'] is Map) ? (_profileData!['horarios'] as Map<String, dynamic>) : null;
    return horarioMap != null ? (horarioMap['descanso'] ?? 'No asignado') : 'No asignado';
  }

  String _formatTime(dynamic value) {
    if (value == null) return '';
    try {
      if (value is DateTime) return DateFormat('HH:mm').format(value);
      if (value is String) {
        // Intentar parsear como DateTime completo
        try {
          final dt = DateTime.parse(value);
          return DateFormat('HH:mm').format(dt);
        } catch (_) {
          // Si es cadena tipo '08:00:00' o '08:00', tomar horas y minutos
          final parts = value.split(':');
          if (parts.length >= 2) {
            final hh = parts[0].padLeft(2, '0');
            final mm = parts[1].padLeft(2, '0');
            return '$hh:$mm';
          }
          return value;
        }
      }
      if (value is int) {
        // asumir epoch ms
        final dt = DateTime.fromMillisecondsSinceEpoch(value);
        return DateFormat('HH:mm').format(dt);
      }
      if (value is double) {
        final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        return DateFormat('HH:mm').format(dt);
      }
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Normalizar a fecha sin hora
      final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      if (_selectedDays.any((x) => isSameDay(x, d))) {
        _selectedDays.removeWhere((x) => isSameDay(x, d));
      } else if (_selectedDays.length < 2) {
        _selectedDays.add(d);
      } else {
        // Reemplazar el primero
        final first = _selectedDays.first;
        _selectedDays.remove(first);
        _selectedDays.add(d);
      }
    });
  }

  Future<void> _enviarSolicitud() async {
    if (_selectedDays.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes seleccionar exactamente 2 días.')));
      return;
    }

    List<String> dias = _selectedDays.map((d) => DateFormat('EEEE', 'es_MX').format(d)).toList();
    dias.sort();
    final String diasSolicitados = dias.join(', ');

    final ok = await ControladorHorarios.crearSolicitudDescanso(
      usuarioId: widget.user['id'],
      diasSolicitados: diasSolicitados,
    );

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada.'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar solicitud.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
  final nombreCompleto = '${_profileData?['nombre'] ?? widget.user['nombre'] ?? ''} ${_profileData?['apellido'] ?? widget.user['apellido'] ?? ''}';
  final horarioMap = (_profileData != null && _profileData!['horarios'] is Map) ? (_profileData!['horarios'] as Map<String, dynamic>) : <String, dynamic>{};
  final String turno = horarioMap['nombre'] ?? 'Sin turno';
  final String horario = '${_formatTime(horarioMap['hora_entrada'])} - ${_formatTime(horarioMap['hora_salida'])}';
  final String descanso = _getDescanso();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil y Horario'), backgroundColor: colorOrange),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(nombreCompleto, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(_profileData?['correo'] ?? widget.user['correo'] ?? '', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const Divider(height: 30),
                Text('Mi Horario Actual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorOrange)),
                ListTile(title: const Text('Turno:'), subtitle: Text(turno, style: const TextStyle(fontSize: 18))),
                ListTile(title: const Text('Horario:'), subtitle: Text(horario, style: const TextStyle(fontSize: 18))),
                ListTile(title: const Text('Días de Descanso:'), subtitle: Text(descanso, style: const TextStyle(fontSize: 18))),
                const Divider(height: 30),
                Text('Solicitar Cambio de Descanso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorOrange)),
                const Text('Selecciona 2 días en el calendario:'),
                const SizedBox(height: 10),
                Card(
                  child: TableCalendar(
                    locale: 'es_MX',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => _selectedDays.any((d) => isSameDay(d, day)),
                    onDaySelected: (selected, focused) => _onDaySelected(selected, focused),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(color: colorOrange, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: colorOrange.withOpacity(0.5), shape: BoxShape.circle),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: colorOrange, foregroundColor: colorWhite),
                  onPressed: _selectedDays.length == 2 ? _enviarSolicitud : null,
                  child: const Text('Enviar Solicitud de Cambio'),
                ),
              ],
            ),
    );
  }
}
