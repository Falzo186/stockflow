class ChecklistServicio {
  final int id;
  final int tareaId;
  final int? usuarioId;
  final bool? planograma;
  final bool? displays;
  final bool? pop;
  final bool? fixture;
  final bool? mercaCruzada;
  final bool? seguridad;
  final bool? overhead;
  final bool? packdown;
  final bool? limpieza;
  final bool? etiquetado;
  final DateTime fecha;

  ChecklistServicio({
    required this.id,
    required this.tareaId,
    this.usuarioId,
    this.planograma,
    this.displays,
    this.pop,
    this.fixture,
    this.mercaCruzada,
    this.seguridad,
    this.overhead,
    this.packdown,
    this.limpieza,
    this.etiquetado,
    required this.fecha,
  });

  factory ChecklistServicio.fromMap(Map<String, dynamic> map) {
    return ChecklistServicio(
      id: map['id'],
      tareaId: map['tarea_id'],
      usuarioId: map['usuario_id'],
      planograma: map['planograma'],
      displays: map['displays'],
      pop: map['pop'],
      fixture: map['fixture'],
      mercaCruzada: map['merca_cruzada'],
      seguridad: map['seguridad'],
      overhead: map['overhead'],
      packdown: map['packdown'],
      limpieza: map['limpieza'],
      etiquetado: map['etiquetado'],
      fecha: DateTime.parse(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarea_id': tareaId,
      'usuario_id': usuarioId,
      'planograma': planograma,
      'displays': displays,
      'pop': pop,
      'fixture': fixture,
      'merca_cruzada': mercaCruzada,
      'seguridad': seguridad,
      'overhead': overhead,
      'packdown': packdown,
      'limpieza': limpieza,
      'etiquetado': etiquetado,
      'fecha': fecha.toIso8601String(),
    };
  }
}
