class Ubicacion {
  final String id;
  final String area;

  Ubicacion({ required this.id, required this.area });

  // Los getters para "traducir" el ID se mantienen igual
  String get pasillo => id.substring(0, 2);
  bool get esCabecera => id.substring(2, 4).toUpperCase() == 'CA';
  String get nivel {
    if (esCabecera) return 'Cabecera';
    switch (id.substring(2, 3)) {
      case '0': return 'Punto de Venta';
      case '1': return 'Over Anaquel';
      default: return 'N/A';
    }
  }
  String get bahia => esCabecera ? '--' : id.substring(3, 5);
  String get cara => esCabecera ? id.substring(4, 5) : '--';
  String get descripcionCompleta {
    if (esCabecera) {
      return 'Pasillo: $pasillo, Nivel: $nivel, Cara: $cara';
    } else {
      return 'Pasillo: $pasillo, Nivel: $nivel, Bahía: $bahia';
    }
  }
}