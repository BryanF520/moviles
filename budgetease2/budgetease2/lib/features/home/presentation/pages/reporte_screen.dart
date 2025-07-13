import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';


class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  double total = 0.0;
  String mesSeleccionado = 'Todos';

  final List<String> meses = [
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
  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    customPattern: '\u00A4#,##0.00', 
  );

  @override
  void initState() {
    super.initState();
    _cargarTotal();
  }


  // Cargar el total de gastos según el mes seleccionado
  Future<void> _cargarTotal({String mes = 'Todos'}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('usuario_id');
    if (id != null) {
      double totalG;
      if (mes == 'Todos') {
        totalG = await DBHelper.getTotalGastosByUsuario(id);
      } else {
        final mesIndex = meses.indexOf(mes);
        final now = DateTime.now();
        totalG = await DBHelper.getTotalGastosPorMes(id, now.year, mesIndex);
      }
      setState(() => total = totalG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecciona un mes',
                    border: InputBorder.none,
                  ),
                  value: mesSeleccionado,
                  onChanged: (String? nuevoMes) {
                    if (nuevoMes != null) {
                      setState(() {
                        mesSeleccionado = nuevoMes;
                      });
                      _cargarTotal(mes: nuevoMes);
                    }
                  },
                  items: meses.map((String mes) {
                    return DropdownMenuItem<String>(
                      value: mes,
                      child: Text(mes),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Total de Gastos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currencyFormat.format(total), 
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}