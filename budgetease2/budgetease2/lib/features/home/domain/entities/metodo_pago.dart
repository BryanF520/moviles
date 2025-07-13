class MetodoPago {
  final int? id;
  final String nombre;
  final String? descripcion;

  MetodoPago({
    this.id,
    required this.nombre,
    this.descripcion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory MetodoPago.fromMap(Map<String, dynamic> map) {
    return MetodoPago(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
    );
  }
}