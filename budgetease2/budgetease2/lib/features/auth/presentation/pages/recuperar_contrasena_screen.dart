import 'package:flutter/material.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/usuario.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState
    extends State<RecuperarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();

  bool _exito = false;
  bool _obscure = true;

  Future<void> _cambiarContrasena() async {
    if (_formKey.currentState!.validate()) {
      final usuario =
          await DBHelper.getUsuarioByNombre(_usuarioController.text.trim());
      if (usuario != null) {
        final actualizado = Usuario(
          id: usuario.id,
          nombre: usuario.nombre,
          correo: usuario.correo,
          usuario: usuario.usuario,
          contrasena: _nuevaContrasenaController.text,
          fotoPerfil: usuario.fotoPerfil,
        );

        await DBHelper.updateUsuario(actualizado);

        setState(() => _exito = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña actualizada con éxito')),
          );
          Navigator.pop(context); // Regresa al login
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado')),
        );
      }
    }
  }

  // Método para crear el borde del campo de texto
  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.teal),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_exito)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '¡Contraseña actualizada con éxito!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // ---------- usuario ----------
              TextFormField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: const Icon(Icons.person),
                  border: _border(),
                  enabledBorder: _border(),
                  focusedBorder: _border(),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese su nombre de usuario' : null,
              ),
              const SizedBox(height: 20),

              // -------- nueva contraseña -----
              TextFormField(
                controller: _nuevaContrasenaController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: _border(),
                  enabledBorder: _border(),
                  focusedBorder: _border(),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                ),
                validator: (v) =>
                    (v == null || v.length < 4) ? 'Debe tener al menos 4 caracteres' : null,
              ),
              const SizedBox(height: 30),

              // ------------- botón ------------
              ElevatedButton.icon(
                  onPressed: _cambiarContrasena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 99, 156, 202), 
                    foregroundColor: Colors.white,                            
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text(
                  'Actualizar contraseña',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
