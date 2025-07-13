import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/gasto.dart';
import 'package:budgetease2/features/home/domain/entities/metodo_pago.dart';

class AgregarGastoScreen extends StatefulWidget {
  const AgregarGastoScreen({super.key});

  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _categoria = 'General'; 
  List<String> _categorias = [];

  List<MetodoPago> _metodosPago = []; 
  int? _metodoPagoSeleccionado; 

  // Método para cargar categorías y métodos de pago desde la base de datos
  @override
  void initState() {
    super.initState();
    _cargarMetodosPago();  
    _cargarCategorias(); 
  }

    // Método para cargar los métodos de pago  
    Future<void> _cargarMetodosPago() async {
    final metodos = await DBHelper.getMetodosPago();
    setState(() {
      _metodosPago = metodos;
      if (_metodosPago.isNotEmpty) {
        _metodoPagoSeleccionado = _metodosPago.first.id;
      }
    });
  }

  // Método para cargar las categorías desde la base de datos
  Future<void> _cargarCategorias() async {
  final categoriasDB = await DBHelper.getCategorias();
  setState(() {
    _categorias = categoriasDB.map((c) => c.nombre).toList();
    if (_categorias.isNotEmpty && !_categorias.contains(_categoria)) {
      _categoria = _categorias.first;
    }
  });
}

  // Método para guardar el nuevo gasto
  Future<void> _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuario_id');

      if (usuarioId != null) {
        final gasto = Gasto(
          titulo: _tituloController.text,
          monto: double.parse(_montoController.text),
          categoria: _categoria, 
          fecha: DateTime.now(),
          descripcion: _descripcionController.text, 
          idUsuario: usuarioId,
          metodoPagoId: _metodoPagoSeleccionado, 
        );

        await DBHelper.insertarGasto(gasto, usuarioId, _metodoPagoSeleccionado);

        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no identificado')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
        backgroundColor: Colors.teal,
        elevation: 0,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese un título' : null,
              ),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el monto' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoria = newValue!;
                  });
                },
                items: _categorias.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _metodoPagoSeleccionado,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                onChanged: (int? newValue) {
                  setState(() {
                    _metodoPagoSeleccionado = newValue;
                  });
                },
                items: _metodosPago.map((metodo) {
                  return DropdownMenuItem<int>(
                    value: metodo.id,
                    child: Text(metodo.nombre),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarGasto,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
