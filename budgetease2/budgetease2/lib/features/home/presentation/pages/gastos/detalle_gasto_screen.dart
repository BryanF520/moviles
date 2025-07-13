import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetease2/features/home/domain/entities/gasto.dart';
import 'package:budgetease2/features/home/presentation/pages/gastos/editar_gasto_screen.dart';

class DetalleGastoScreen extends StatelessWidget {
  const DetalleGastoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gasto = ModalRoute.of(context)!.settings.arguments as Gasto;
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarGastoScreen(gasto: gasto),
                ),
              ).then((actualizado) {
                if (actualizado == true) {
                  // Aquí puedes recargar datos o realizar alguna acción
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gasto actualizado con éxito')),
                  );
                }
              });
            },
          ),
        ],
      ),
      // Mostrar detalles del gasto
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${gasto.titulo}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Método de Pago: ${gasto.metodoPagoNombre ?? "No especificado"}'),
            const SizedBox(height: 10),
            Text('Monto: ${currencyFormat.format(gasto.monto)}'),
            const SizedBox(height: 10),
            Text('Categoría: ${gasto.categoria}'),
            const SizedBox(height: 10),
            Text('Descripción: ${gasto.descripcion ?? "Sin descripción"}'),
            const SizedBox(height: 10),
            Text('Fecha: ${gasto.fecha.toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}
