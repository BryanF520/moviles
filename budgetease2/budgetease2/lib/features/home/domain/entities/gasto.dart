class Gasto {
  final int? id;
  final String titulo;
  final double monto;
  final String categoria;
  final DateTime fecha;
  final String? descripcion;
  final int idUsuario;
  final int? metodoPagoId;
  final String? metodoPagoNombre;

  Gasto({
    this.id,
    required this.titulo,
    required this.monto,
    required this.categoria,
    required this.fecha,
    this.descripcion,
    required this.idUsuario,
    this.metodoPagoId,
    this.metodoPagoNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha.toString().split('.')[0],
      'descripcion': descripcion,
      "usuario_id": idUsuario,
      'metodo_pago_id': metodoPagoId,
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      titulo: map['titulo'],
      monto: map['monto'],
      categoria: map['categoria'],
      fecha: DateTime.parse(map['fecha']),
      descripcion: map['descripcion'],
      idUsuario: map['usuario_id'],
      metodoPagoId: map['metodo_pago_id'],
      metodoPagoNombre: map['metodo_pago_nombre'],
    );
  }
}