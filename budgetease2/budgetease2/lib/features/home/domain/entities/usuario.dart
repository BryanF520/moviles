class Usuario {
  final int? id;
  final String nombre;
  final String correo;
  final String usuario;
  final String contrasena;
  final String? fotoPerfil;

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.usuario,
    required this.contrasena,
    this.fotoPerfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'usuario': usuario,
      'contrasena': contrasena,
      'fotoPerfil': fotoPerfil,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      usuario: map['usuario'] ?? '',
      contrasena: map['contrasena'] ?? '',
      fotoPerfil: map['fotoPerfil'],
    );
  }
}
