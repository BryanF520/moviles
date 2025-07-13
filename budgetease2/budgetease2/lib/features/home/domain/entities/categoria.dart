class Categoria {
  final int? id;
  final String nombre;
  final int cantidadGastos;

  Categoria({
    this.id,
    required this.nombre,
    this.cantidadGastos = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidadGastos': cantidadGastos,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      cantidadGastos: map['cantidadGastos'],
    );
  }
}