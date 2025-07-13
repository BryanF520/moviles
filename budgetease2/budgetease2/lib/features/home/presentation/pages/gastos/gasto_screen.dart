import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/gasto.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

// Estado de la pantalla de gastos
class _GastosScreenState extends State<GastosScreen> {
  List<Gasto> _gastos = [];
  double _total = 0.0;
  String _mesSeleccionado = 'Todos';
  int? _usuarioId;

  // Lista de meses para el dropdown
  final List<String> _meses = [
    'Todos',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // Formato de moneda
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Cargar datos del usuario y gastos
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('usuario_id');
    if (id != null) {
      _usuarioId = id;
      await _cargarGastos();
    }
  }

  // Cargar gastos según el mes seleccionado
  Future<void> _cargarGastos() async {
    if (_usuarioId == null) return;
    List<Gasto> gastos;
    double total;

    if (_mesSeleccionado == 'Todos') {
      gastos = await DBHelper.getGastosByUsuario(_usuarioId!);
      total = await DBHelper.getTotalGastosByUsuario(_usuarioId!);
    } else {
      final mesIndex = _meses.indexOf(_mesSeleccionado);
      final ahora = DateTime.now();
      gastos = await DBHelper.getGastosPorMes(_usuarioId!, ahora.year, mesIndex);
      total = gastos.fold(0.0, (sum, item) => sum + item.monto);
    }

    setState(() {
      _gastos = gastos;
      _total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos los Gastos'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _mesSeleccionado,
              isExpanded: true,
              onChanged: (String? nuevoMes) {
                if (nuevoMes != null) {
                  setState(() {
                    _mesSeleccionado = nuevoMes;
                  });
                  _cargarGastos();
                }
              },
              items: _meses.map((String mes) {
                return DropdownMenuItem<String>(
                  value: mes,
                  child: Text(mes),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total de gastos:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormat.format(_total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _gastos.isEmpty
                  ? const Center(child: Text('No hay gastos registrados'))
                  : ListView.builder(
                      itemCount: _gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = _gastos[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: const Icon(Icons.monetization_on, color: Colors.white),
                            ),
                            title: Text(gasto.titulo),
                            subtitle: Text(
                              '${gasto.categoria} - ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                            ),
                            trailing: Text(
                              currencyFormat.format(gasto.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}