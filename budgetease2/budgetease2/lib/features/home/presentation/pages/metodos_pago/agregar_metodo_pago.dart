import 'package:flutter/material.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/metodo_pago.dart';

class AgregarMetodoPagoScreen extends StatefulWidget {
  const AgregarMetodoPagoScreen({Key? key}) : super(key: key);

  @override
  State<AgregarMetodoPagoScreen> createState() => _AgregarMetodoPagoScreenState();
}

class _AgregarMetodoPagoScreenState extends State<AgregarMetodoPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  // Método para guardar el nuevo método de pago
  Future<void> _guardarMetodoPago() async {
    if (_formKey.currentState!.validate()) {
      final nombreInput = _nombreController.text.trim();
      final nombreNormalizado = nombreInput.toLowerCase();

      final metodoExistente = await DBHelper.getMetodoPagoByNombre(nombreNormalizado);

      if (metodoExistente != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El método de pago ya existe'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
      }

      // Normalizar el nombre del método de pago
      final metodoFormateado = nombreInput[0].toUpperCase() + nombreInput.substring(1).toLowerCase();

      // Crear el nuevo método de pago
      final nuevoMetodo = MetodoPago(
        nombre: metodoFormateado,
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      );

      await DBHelper.insertarMetodoPago(nuevoMetodo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Método de pago guardado')),
        );
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Método de Pago'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del método',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarMetodoPago,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
