import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerario.dart';

// Colores usados en este archivo
const Color colorOrange = Color(0xFFF88033);
const Color colorBlack = Color(0xFF000000);
const Color colorBackgroundScaffold = Color(0xFFE5E5E5);

// --- Para manejar el estado de cada item ---
enum OpcionChecklist { noSeleccionado, na, no, si }

class ChecklistItem {
  final String id;
  final String titulo;
  final bool tieneNA; // Define si muestra el botón "N/A"
  OpcionChecklist seleccion;

  ChecklistItem({
    required this.id,
    required this.titulo,
    this.tieneNA = false,
    this.seleccion = OpcionChecklist.noSeleccionado,
  });
}

// --- La Pantalla Principal ------------
class ChecklistBahiaScreen extends StatefulWidget {
  final String? ubicacionId;
  final int? tareaId;
  final int? usuarioId;

  const ChecklistBahiaScreen({super.key, this.ubicacionId, this.tareaId, this.usuarioId});

  @override
  State<ChecklistBahiaScreen> createState() => _ChecklistBahiaScreenState();
}

class _ChecklistBahiaScreenState extends State<ChecklistBahiaScreen> {
  // Colores principales de tu app (basado en las imágenes)
  static const Color colorPrimario = Colors.orange; // Naranja oscuro
  static const Color colorGris = Colors.grey;

  // --- 1. Definición del estado: La lista de tareas ---
  List<ChecklistItem> _items = [];

  @override
  void initState() {
    super.initState();
    // Cargamos la lista de items cuando la pantalla se inicia
    _items = [
      ChecklistItem(id: 'planograma', titulo: 'Bahia de acuerdo a planograma:'),
      ChecklistItem(id: 'displays', titulo: 'Displays:', tieneNA: true),
      ChecklistItem(id: 'pop', titulo: 'POP:', tieneNA: true),
      ChecklistItem(id: 'fixture', titulo: 'Fixture:', tieneNA: true),
      ChecklistItem(
          id: 'merca_cruzada',
          titulo: 'Mercaderia Cruzada:',
          tieneNA: true),
      ChecklistItem(id: 'seguridad', titulo: 'Seguridad:'),
      ChecklistItem(
          id: 'overhead',
          titulo: 'Organizacion de Overhead:',
          tieneNA: true),
      ChecklistItem(id: 'packdown', titulo: 'Packdown:'),
      ChecklistItem(id: 'limpieza', titulo: 'Limpieza:'),
      ChecklistItem(id: 'etiquetado', titulo: 'Etiquetado:'),
    ];
  }

  // --- 2. Lógica de Validación ---

  /// Revisa si todos los items de la lista tienen una respuesta
  bool _isChecklistCompleto() {
    // .every() revisa que *todos* los elementos cumplan la condición
    return _items
        .every((item) => item.seleccion != OpcionChecklist.noSeleccionado);
  }

  /// Función principal que se llama al presionar "Finalizar"
  void _finalizarServicio() {
    // Primero, buscamos el item "Packdown"
    final itemPackdown =
        _items.firstWhere((item) => item.id == 'packdown');

    // --- 3. Lógica Condicional ---
    // Si "Packdown" se marcó como "No" (X)
    if (itemPackdown.seleccion == OpcionChecklist.no) {
      // Mostramos el diálogo de motivos
      _mostrarDialogoPackdown();
    } else {
      // Si todo está bien, registramos el servicio
      _registrarServicioCompleto();
    }
  }

  /// Muestra el diálogo para preguntar el motivo
  void _mostrarDialogoPackdown() {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('¿Por qué no se hizo Packdown?'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                _registrarServicioCompleto(motivo: 'Mercancia no encontrada');
              },
              child: const Text('Mercancia no encontrada'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _registrarServicioCompleto(motivo: 'Tiempo');
              },
              child: const Text('Tiempo'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _registrarServicioCompleto(motivo: 'Producto no registrado');
              },
              child: const Text('Producto no registrado'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _registrarServicioCompleto(motivo: 'Sin existencia');
              },
              child: const Text('Sin existencia'),
            ),
            // Botón para cancelar por si se equivocó
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: colorGris)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  /// Función final (simulada) para registrar el servicio
  Map<String, bool> _buildChecklistMap() {
    final Map<String, bool> out = {};
    for (final item in _items) {
      out[item.id] = (item.seleccion == OpcionChecklist.si);
    }
    return out;
  }

  void _registrarServicioCompleto({String? motivo}) async {
    // Construir mapa de checklist
    final checklistMap = _buildChecklistMap();

    final int tareaId = widget.tareaId ?? 0;
    final int usuarioId = widget.usuarioId ?? 0;
    // Validaciones locales para dar feedback más específico
    if (tareaId == 0 || usuarioId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea o usuario inválido'), backgroundColor: Colors.red));
      return;
    }

    // Obtener la tarea actual para validar estado y asignación
    final tarea = await ControladorItinerario.obtenerTareaPorId(tareaId);
    if (tarea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea no encontrada'), backgroundColor: Colors.red));
      return;
    }

    final estado = (tarea['estado'] ?? '').toString();
    final assigned = tarea['usuario_id'] is int ? tarea['usuario_id'] as int : int.tryParse('${tarea['usuario_id']}') ?? 0;

    if (estado != 'en_progreso') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes completar: la tarea no fue iniciada'), backgroundColor: Colors.orange));
      return;
    }

    if (assigned != usuarioId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes completar: no eres el usuario asignado a esta tarea'), backgroundColor: Colors.orange));
      return;
    }

    // Llamar al controlador para persistir (actualiza tarea, inserta checklist_servicio y actualiza control_bahias)
    final ok = await ControladorItinerario.completarTareaConChecklist(tareaId, Map<String, dynamic>.from(checklistMap), usuarioId);

    if (ok) {
      String mensaje = "Servicio registrado correctamente.";
      if (motivo != null) mensaje = "Servicio registrado. Motivo Packdown: $motivo";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: Colors.green[700]));
      // Devolver true para indicar éxito
      if (Navigator.of(context).canPop()) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Error al registrar servicio'), backgroundColor: Colors.red[700]));
      if (Navigator.of(context).canPop()) Navigator.of(context).pop(false);
    }
  }

  // --- 4. Construcción de la UI ---
  @override
  Widget build(BuildContext context) {
    // Revisa el estado actual para el botón
    final bool estaCompleto = _isChecklistCompleto();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68.0),
        child: SafeArea(child: _buildHeader(context)),
      ),
      backgroundColor: colorBackgroundScaffold,

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // El título principal
          const Text(
            '¿La bahía cumple con los siguientes requerimientos?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Construimos la lista de items
          ..._items.asMap().entries.map((entry) {
            int idx = entry.key;
            ChecklistItem item = entry.value;
            return _buildChecklistItem(item, idx);
          }),
        ],
      ),

      // --- 5. Botón Fijo Inferior ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        // Sombra para que se distinga del fondo
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          // La magia está aquí:
          // Si está completo, llama a _finalizarServicio
          // Si no, `onPressed` es null, y el botón se deshabilita solo
          onPressed: estaCompleto ? _finalizarServicio : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: estaCompleto
                ? colorPrimario
                : colorGris, // Color dinámico
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Finalizar Servicio'),
        ),
      ),
    );
  }

  /// Construye la fila de opciones para un item (N/A, X, ✓) usando botones
  /// individuales para permitir colores base diferentes por opción.
  Widget _buildOptionRow(ChecklistItem item, int itemIndex) {
    const Color colorGreen = Color(0xFF2E7D32);
    const Color colorRed = Color(0xFFD32F2F);
    const Color colorBlue = Color(0xFF1976D2);

    // Indices para isSelected
    final List<bool> isSelected = item.tieneNA
        ? [item.seleccion == OpcionChecklist.na, item.seleccion == OpcionChecklist.no, item.seleccion == OpcionChecklist.si]
        : [item.seleccion == OpcionChecklist.no, item.seleccion == OpcionChecklist.si];

    Widget buildOption({required Widget child, required bool selected, required Color selColor, required VoidCallback onPressed}) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: OutlinedButton(
            style: ButtonStyle(
              // When selected show a solid color background, otherwise a very light tint
              backgroundColor: MaterialStateProperty.all(selected ? selColor : selColor.withOpacity(0.06)),
              side: MaterialStateProperty.all(BorderSide(color: selColor)),
              // Force icons/text to be black by default
              foregroundColor: MaterialStateProperty.all(Colors.black),
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
            ),
            onPressed: onPressed,
            child: child,
          ),
        ),
      );
    }

    final List<Widget> options = [];
    if (item.tieneNA) {
      options.add(buildOption(
        child: Text('N/A', style: TextStyle(color: Colors.black, fontWeight: isSelected[0] ? FontWeight.w700 : FontWeight.w500)),
        selected: isSelected[0],
        selColor: colorBlue,
        onPressed: () {
          setState(() {
            final nueva = OpcionChecklist.na;
            if (_items[itemIndex].seleccion == nueva) _items[itemIndex].seleccion = OpcionChecklist.noSeleccionado;
            else _items[itemIndex].seleccion = nueva;
          });
        },
      ));
    }

    // X button (No)
    final int idxNo = item.tieneNA ? 1 : 0;
    options.add(buildOption(
      child: const Icon(Icons.close),
      selected: isSelected[idxNo],
      selColor: colorRed,
      onPressed: () {
        setState(() {
          final nueva = OpcionChecklist.no;
          if (_items[itemIndex].seleccion == nueva) _items[itemIndex].seleccion = OpcionChecklist.noSeleccionado;
          else _items[itemIndex].seleccion = nueva;
        });
      },
    ));

    // Check button (Si)
    final int idxSi = item.tieneNA ? 2 : 1;
    options.add(buildOption(
      child: const Icon(Icons.check),
      selected: isSelected[idxSi],
      selColor: colorGreen,
      onPressed: () {
        setState(() {
          final nueva = OpcionChecklist.si;
          if (_items[itemIndex].seleccion == nueva) _items[itemIndex].seleccion = OpcionChecklist.noSeleccionado;
          else _items[itemIndex].seleccion = nueva;
        });
      },
    ));

    return Row(mainAxisSize: MainAxisSize.max, children: options);
  }

  /// Widget que construye cada tarjeta de la checklist
  Widget _buildChecklistItem(ChecklistItem item, int itemIndex) {
    // (removed previous ToggleButtons helpers -- now we render per-option buttons)

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del item (ej. "Packdown:")
            Text(
              item.titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Fila de botones con colores base por opción
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: _buildOptionRow(item, itemIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: colorOrange,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                shape: const CircleBorder(),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Finalizar Mercadeo | D10943...',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

  }
}