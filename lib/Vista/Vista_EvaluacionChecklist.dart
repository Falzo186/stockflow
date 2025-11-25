import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stockflow/Controlador/ControladorItinerario.dart';
import 'package:stockflow/Vista/Vista_CheckListBahia.dart';

/// Pantalla para que un evaluador (jefe) revise la checklist de una tarea
/// y registre su propia evaluación.
class EvaluacionChecklistScreen extends StatefulWidget {
  final int tareaId;
  final Map<String, dynamic> evaluadorUser;

  const EvaluacionChecklistScreen({Key? key, required this.tareaId, required this.evaluadorUser}) : super(key: key);

  @override
  State<EvaluacionChecklistScreen> createState() => _EvaluacionChecklistScreenState();
}

class _EvaluacionChecklistScreenState extends State<EvaluacionChecklistScreen> {
  List<ChecklistItem> _itemsAsociado = [];
  List<ChecklistItem> _itemsEvaluador = [];

  final _comentariosController = TextEditingController();
  double _puntaje = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Inicializar los items igual que en ChecklistBahiaScreen
    final template = [
      ChecklistItem(id: 'planograma', titulo: 'Bahia de acuerdo a planograma:'),
      ChecklistItem(id: 'displays', titulo: 'Displays:', tieneNA: true),
      ChecklistItem(id: 'pop', titulo: 'POP:', tieneNA: true),
      ChecklistItem(id: 'fixture', titulo: 'Fixture:', tieneNA: true),
      ChecklistItem(id: 'merca_cruzada', titulo: 'Mercaderia Cruzada:', tieneNA: true),
      ChecklistItem(id: 'seguridad', titulo: 'Seguridad:'),
      ChecklistItem(id: 'overhead', titulo: 'Organizacion de Overhead:', tieneNA: true),
      ChecklistItem(id: 'packdown', titulo: 'Packdown:'),
      ChecklistItem(id: 'limpieza', titulo: 'Limpieza:'),
      ChecklistItem(id: 'etiquetado', titulo: 'Etiquetado:'),
    ];

    // Crear copias para asociado y evaluador
    _itemsAsociado = template.map((t) => ChecklistItem(id: t.id, titulo: t.titulo, tieneNA: t.tieneNA)).toList();
    _itemsEvaluador = template.map((t) => ChecklistItem(id: t.id, titulo: t.titulo, tieneNA: t.tieneNA)).toList();

    _loadData();
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final tareaData = await ControladorItinerario.obtenerTareaConChecklist(widget.tareaId);
      if (tareaData != null && tareaData.containsKey('checklist')) {
        final raw = tareaData['checklist'];
        Map<String, dynamic> checklistJson = {};
        if (raw == null) {
          checklistJson = {};
        } else if (raw is String) {
          try {
            checklistJson = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            checklistJson = {};
          }
        } else if (raw is Map) {
          checklistJson = Map<String, dynamic>.from(raw);
        }

        // Actualizar _itemsAsociado en base al JSON
        for (final item in _itemsAsociado) {
          final v = checklistJson[item.id];
          if (v == true || v == 't' || v == 1) {
            item.seleccion = OpcionChecklist.si;
          } else {
            // mantener comportamiento pedido: si no es true, considerarlo NO
            item.seleccion = OpcionChecklist.no;
          }
        }
      }
    } catch (e) {
      print('Error cargando datos de evaluación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isEvaluadorCompleto() {
    return _itemsEvaluador.every((it) => it.seleccion != OpcionChecklist.noSeleccionado);
  }

  String _seleccionToReadable(OpcionChecklist s) {
    switch (s) {
      case OpcionChecklist.si:
        return 'Si';
      case OpcionChecklist.no:
        return 'No';
      case OpcionChecklist.na:
        return 'N/A';
      case OpcionChecklist.noSeleccionado:
        return 'Sin respuesta';
    }
  }

  String _seleccionToSaveString(OpcionChecklist s) {
    switch (s) {
      case OpcionChecklist.si:
        return 'si';
      case OpcionChecklist.no:
        return 'no';
      case OpcionChecklist.na:
        return 'na';
      case OpcionChecklist.noSeleccionado:
        return 'no';
    }
  }

  Widget _buildOptionRowForEvaluador(ChecklistItem item, int index) {
    const Color colorGreen = Color(0xFF2E7D32);
    const Color colorRed = Color(0xFFD32F2F);
    const Color colorBlue = Color(0xFF1976D2);

    final List<bool> isSelected = item.tieneNA
        ? [item.seleccion == OpcionChecklist.na, item.seleccion == OpcionChecklist.no, item.seleccion == OpcionChecklist.si]
        : [item.seleccion == OpcionChecklist.no, item.seleccion == OpcionChecklist.si];

    Widget buildOption({required Widget child, required bool selected, required Color selColor, required VoidCallback onPressed}) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(selected ? selColor : selColor.withOpacity(0.06)),
              side: MaterialStateProperty.all(BorderSide(color: selColor)),
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
            if (_itemsEvaluador[index].seleccion == nueva) _itemsEvaluador[index].seleccion = OpcionChecklist.noSeleccionado;
            else _itemsEvaluador[index].seleccion = nueva;
          });
        },
      ));
    }

    // No (X)
    final int idxNo = item.tieneNA ? 1 : 0;
    options.add(buildOption(
      child: const Icon(Icons.close),
      selected: isSelected[idxNo],
      selColor: colorRed,
      onPressed: () {
        setState(() {
          final nueva = OpcionChecklist.no;
          if (_itemsEvaluador[index].seleccion == nueva) _itemsEvaluador[index].seleccion = OpcionChecklist.noSeleccionado;
          else _itemsEvaluador[index].seleccion = nueva;
        });
      },
    ));

    // Si (check)
    final int idxSi = item.tieneNA ? 2 : 1;
    options.add(buildOption(
      child: const Icon(Icons.check),
      selected: isSelected[idxSi],
      selColor: colorGreen,
      onPressed: () {
        setState(() {
          final nueva = OpcionChecklist.si;
          if (_itemsEvaluador[index].seleccion == nueva) _itemsEvaluador[index].seleccion = OpcionChecklist.noSeleccionado;
          else _itemsEvaluador[index].seleccion = nueva;
        });
      },
    ));

    return Row(mainAxisSize: MainAxisSize.max, children: options);
  }

  Widget _buildEvaluacionItem(ChecklistItem itemEvaluador, ChecklistItem itemAsociado, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemEvaluador.titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            // Respuesta del asociado (estática)
            Chip(
              label: Text('Asociado: ${_seleccionToReadable(itemAsociado.seleccion)}'),
              backgroundColor: colorOrange.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            // Opciones para el evaluador
            _buildOptionRowForEvaluador(itemEvaluador, index),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarEvaluacion() async {
    // Construir mapa de respuestas del evaluador
    final Map<String, dynamic> out = {};
    for (final item in _itemsEvaluador) {
      out[item.id] = _seleccionToSaveString(item.seleccion);
    }

    final ok = await ControladorItinerario.guardarEvaluacion(
      tareaId: widget.tareaId,
      evaluadorId: widget.evaluadorUser['id'] is int ? widget.evaluadorUser['id'] as int : int.tryParse('${widget.evaluadorUser['id']}') ?? 0,
      puntaje: _puntaje,
      comentarios: _comentariosController.text,
      checklistEvaluador: out,
    );

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evaluación guardada'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error guardando evaluación'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68.0),
        child: SafeArea(
          child: Container(
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
                    const Expanded(
                      child: Text(
                        'Evaluar Bahía',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ..._itemsEvaluador.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final itemEval = entry.value;
                  final itemAsoc = _itemsAsociado[idx];
                  return _buildEvaluacionItem(itemEval, itemAsoc, idx);
                }),

                const SizedBox(height: 8),
                Text('Calificación (0-10): ${_puntaje.toStringAsFixed(1)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Slider(min: 0, max: 10, divisions: 20, value: _puntaje, onChanged: (val) => setState(() => _puntaje = val)),
                const SizedBox(height: 8),
                TextField(
                  controller: _comentariosController,
                  decoration: const InputDecoration(labelText: 'Comentarios'),
                  maxLines: 3,
                ),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: (_isEvaluadorCompleto() && _puntaje > 0) ? _guardarEvaluacion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: (_isEvaluadorCompleto() && _puntaje > 0) ? colorOrange : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Guardar Evaluación'),
        ),
      ),
    );
  }
}
