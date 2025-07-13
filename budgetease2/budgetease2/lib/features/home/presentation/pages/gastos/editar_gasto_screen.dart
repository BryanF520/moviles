import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/gasto.dart';
import 'package:budgetease2/features/home/domain/entities/metodo_pago.dart';


class EditarGastoScreen extends StatefulWidget {
  final Gasto gasto;

  const EditarGastoScreen({super.key, required this.gasto});

  @override
  State<EditarGastoScreen> createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<String> _categorias = [];
  List<MetodoPago> _metodosPago = [];

  String? _categoriaSeleccionada;
  int? _metodoPagoSeleccionado;

  // Inicializar los controladores y cargar datos
  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.gasto.titulo;
    _montoController.text = widget.gasto.monto.toString();
    _descripcionController.text = widget.gasto.descripcion ?? '';
    _categoriaSeleccionada = widget.gasto.categoria;
    _metodoPagoSeleccionado = widget.gasto.metodoPagoId;

    _cargarCategoriasYMetodos();
  }

  // Cargar categorías y métodos de pago desde la base de datos
  Future<void> _cargarCategoriasYMetodos() async {
    final categorias = await DBHelper.getCategorias();
    final metodos = await DBHelper.getMetodosPago();

    setState(() {
      _categorias = categorias.map((c) => c.nombre).toSet().toList();
      _metodosPago = metodos;
    });

    // Validar valor actual
    if (!_categorias.contains(_categoriaSeleccionada)) {
      _categoriaSeleccionada = _categorias.isNotEmpty ? _categorias.first : null;
    }
  }

  // Guardar cambios en el gasto editado
  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuario_id');

      if (usuarioId != null) {
        final gastoActualizado = Gasto(
          id: widget.gasto.id,
          titulo: _tituloController.text.trim(),
          monto: double.parse(_montoController.text),
          categoria: _categoriaSeleccionada!,
          fecha: widget.gasto.fecha,
          descripcion: _descripcionController.text.trim(),
          idUsuario: usuarioId,
          metodoPagoId: _metodoPagoSeleccionado,
        );

        await DBHelper.updateGasto(gastoActualizado);

        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto'),
        backgroundColor: Colors.teal,
      ),
      body: _categorias.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese un título' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _montoController,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese el monto' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _categoriaSeleccionada,
                      decoration:
                          const InputDecoration(labelText: 'Categoría'),
                      onChanged: (value) =>
                          setState(() => _categoriaSeleccionada = value),
                      items: _categorias
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _metodoPagoSeleccionado,
                      decoration: const InputDecoration(
                          labelText: 'Método de Pago'),
                      onChanged: (value) =>
                          setState(() => _metodoPagoSeleccionado = value),
                      items: _metodosPago
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.nombre),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descripcionController,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _guardarCambios,
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
