import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/usuario.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  final TextEditingController _nombreController = TextEditingController();
  File? _imagenPerfil;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  // Carga el usuario desde SharedPreferences y la base de datos
  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id');
    if (usuarioId != null) {
      final usuario = await DBHelper.getUsuarioById(usuarioId);
      if (usuario != null) {
        setState(() {
          _usuario = usuario;
          _nombreController.text = usuario.nombre;
          if (usuario.fotoPerfil != null) {
            _imagenPerfil = File(usuario.fotoPerfil!);
          }
        });
      }
    }
  }

  // Guarda los cambios del perfil en la base de datos
  Future<void> _guardarCambios() async {
    if (_usuario != null) {
      final nuevoUsuario = Usuario(
        id: _usuario!.id,
        nombre: _nombreController.text,
        correo: _usuario!.correo,
        usuario: _usuario!.usuario,
        contrasena: _usuario!.contrasena,
        fotoPerfil: _imagenPerfil?.path,
      );

      await DBHelper.updateUsuario(nuevoUsuario);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
        Navigator.pop(context); // Regresa al HomeScreen
      }
    }
  }

  // Permite al usuario seleccionar una imagen de perfil desde la galería
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile != null) {
      setState(() {
        _imagenPerfil = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
                child: _imagenPerfil == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
