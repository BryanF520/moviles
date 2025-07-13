import 'package:flutter/material.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/categoria.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> _categorias = [];

  // Inicializar la base de datos y cargar las categorías al iniciar la pantalla
  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  // Método para cargar las categorías desde la base de datos
  Future<void> _cargarCategorias() async {
    final categorias = await DBHelper.getCategorias();
    setState(() {
      _categorias = categorias;
    });
  }

  // Método para mostrar el diálogo de agregar categoría
Future<void> _mostrarDialogoAgregarCategoria() async {
  final nombreController = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Nueva categoría'),
      content: TextField(
        controller: nombreController,
        decoration: const InputDecoration(
          labelText: 'Nombre de la categoría',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final nombreInput = nombreController.text.trim();

            if (nombreInput.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El nombre no puede estar vacío.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // Capitalizar el nombre y verificar si ya existe
            final nombre = nombreInput[0].toUpperCase() + nombreInput.substring(1).toLowerCase();

            // Verificar si la categoría ya existe
            final categoriaExistente = await DBHelper.getCategoriaByNombre(nombre);

            if (categoriaExistente != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La categoría ya existe.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              final nuevaCategoria = Categoria(nombre: nombre, cantidadGastos: 0);
              await DBHelper.insertarCategoria(nuevaCategoria);
              Navigator.pop(context);
              _cargarCategorias();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

  // Método para eliminar una categoría
  Future<void> _eliminarCategoria(int id) async {
    await DBHelper.db.then((db) async {
      await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
    });
    _cargarCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Añadir categoría',
            onPressed: _mostrarDialogoAgregarCategoria,
          ),
        ],
      ),
      body: _categorias.isEmpty
          ? const Center(child: Text('No hay categorías registradas.'))
          : ListView.builder(
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(categoria.nombre),
                    subtitle: Text(
                        'Gastos asociados: ${categoria.cantidadGastos}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarCategoria(categoria.id!),
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
