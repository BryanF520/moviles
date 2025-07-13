import 'package:flutter/material.dart';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/categoria.dart';

class CategoriasBuscarScreen extends StatefulWidget {
  const CategoriasBuscarScreen({super.key});

  @override
  State<CategoriasBuscarScreen> createState() => _CategoriasBuscarScreenState();
}

class _CategoriasBuscarScreenState extends State<CategoriasBuscarScreen> {
  List<Categoria> _categorias = [];
  List<Categoria> _filtradas = [];
  final _buscarController = TextEditingController();

  // Inicializa el estado y carga las categorías
  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _buscarController.addListener(_filtrarCategorias);
  }

  // Carga las categorías desde la base de datos
  Future<void> _cargarCategorias() async {
    final cats = await DBHelper.getCategorias();
    setState(() {
      _categorias = cats;
      _filtradas = cats;
    });
  }

  // Filtra las categorías según el texto ingresado
  void _filtrarCategorias() {
    final query = _buscarController.text.toLowerCase();
    setState(() {
      _filtradas = _categorias
          .where((c) => c.nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Categoría')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscarController,
              decoration: const InputDecoration(
                labelText: 'Buscar categoría',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtradas.length,
              itemBuilder: (context, index) {
                final categoria = _filtradas[index];
                return ListTile(
                  title: Text(categoria.nombre),
                  onTap: () {
                    Navigator.pop(context, categoria);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
