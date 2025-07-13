import 'package:flutter/material.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/metodo_pago.dart';

class MetodosPagoScreen extends StatefulWidget {
  const MetodosPagoScreen({Key? key}) : super(key: key);

  @override
  State<MetodosPagoScreen> createState() => _MetodosPagoScreenState();
}

class _MetodosPagoScreenState extends State<MetodosPagoScreen> {
  List<MetodoPago> _metodos = [];

  @override
  void initState() {
    super.initState();
    _cargarMetodos();
  }

  // Carga los métodos de pago desde la base de datos
  Future<void> _cargarMetodos() async {
    final metodos = await DBHelper.getMetodosPago();
    setState(() => _metodos = metodos);
  }

  // Elimina un método de pago por su ID
  Future<void> _eliminarMetodo(int id) async {
    final db = await DBHelper.db;
    await db.delete('metodos_pago', where: 'id = ?', whereArgs: [id]);
    _cargarMetodos();
  }

  // Muestra un formulario para añadir o editar un método de pago
void _mostrarFormulario({MetodoPago? metodo}) {
  final nombreController =
      TextEditingController(text: metodo?.nombre ?? '');
  final descripcionController =
      TextEditingController(text: metodo?.descripcion ?? '');

// Muestra un diálogo con el formulario
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(metodo == null ? 'Nuevo Método de Pago' : 'Editar Método'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final inputNombre = nombreController.text.trim();
            final nombreNormalizado = inputNombre.toLowerCase();

            final metodoExistente =
                await DBHelper.getMetodoPagoByNombre(nombreNormalizado);

            final esEdicion = metodo != null;

            // Si existe otro método con el mismo nombre y no es el que estamos editando
            if (metodoExistente != null &&
                (!esEdicion || metodoExistente.id != metodo.id)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ya existe un método de pago con ese nombre'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            // Formatear con mayúscula inicial
            final nombreFormateado =
                inputNombre[0].toUpperCase() + inputNombre.substring(1).toLowerCase();

            final nuevo = MetodoPago(
              id: metodo?.id,
              nombre: nombreFormateado,
              descripcion: descripcionController.text.trim(),
            );

            if (!esEdicion) {
              await DBHelper.insertarMetodoPago(nuevo);
            } else {
              final db = await DBHelper.db;
              await db.update(
                'metodos_pago',
                nuevo.toMap(),
                where: 'id = ?',
                whereArgs: [metodo.id],
              );
            }

            if (mounted) {
              Navigator.pop(context);
              _cargarMetodos();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
        backgroundColor: Colors.teal,
        actions: [
        IconButton(                        // ← botón "+" arriba
          icon: const Icon(Icons.add),
          tooltip: 'Añadir método de pago',
          onPressed: () => _mostrarFormulario(),
        ),
      ],
    ),
      body: ListView.builder(
        itemCount: _metodos.length,
        itemBuilder: (context, index) {
          final metodo = _metodos[index];
          return ListTile(
            leading: const Icon(Icons.payment),
            title: Text(metodo.nombre),
            subtitle: metodo.descripcion != null
                ? Text(metodo.descripcion!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _mostrarFormulario(metodo: metodo),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarMetodo(metodo.id!),
                  ),
                ],
              ),      
            );
          },
        ),
      );
    }              
  }