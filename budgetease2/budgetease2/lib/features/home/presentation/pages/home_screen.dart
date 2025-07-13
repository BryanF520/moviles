import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:budgetease2/features/home/data/datasources/db_helper.dart';
import 'package:budgetease2/features/home/domain/entities/usuario.dart';
import 'package:budgetease2/features/home/domain/entities/gasto.dart';

/// Pantalla principal de la aplicación que muestra el resumen de gastos del usuario,
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// Clase que maneja el estado de la pantalla principal.
class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Gasto>> _gastosFuture;
  late Future<double> _totalGastosFuture;
  late Future<Usuario?> _usuarioFuture;
  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    customPattern: '\u00A4#,##0.00',
  );
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    _gastosFuture = Future.value([]);
    _totalGastosFuture = Future.value(0.0);
    _usuarioFuture = Future.value(null);
    _cargarUsuarioId();
  }

  /// Carga el ID del usuario desde SharedPreferences y obtiene los datos del usuario y sus gastos.
  Future<void> _cargarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    _usuarioId = prefs.getInt('usuario_id');
    
    if (_usuarioId != null) {
      _usuarioFuture = DBHelper.getUsuarioById(_usuarioId!);
      _cargarGastos();
      setState(() {});;
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// Carga los gastos del usuario desde la base de datos.
  Future<void> _cargarGastos() async {
    if (_usuarioId != null) {
      _gastosFuture = DBHelper.getGastosByUsuario(_usuarioId!);
      _totalGastosFuture = DBHelper.getTotalGastosByUsuario(_usuarioId!);
      setState(() {}); // Solo actualiza el estado si los datos han cambiado
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuarioId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('BudgetEase'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('usuario_id');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/perfil').then((_) {
                _cargarUsuarioId(); // Recarga el usuario después de editar el perfil
            });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _cargarGastos();
          return;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              FutureBuilder<Usuario?>(
                future: _usuarioFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No se pudo cargar el usuario.'));
                  } else {
                    final usuario = snapshot.data!;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: usuario.fotoPerfil != null
                                  ? FileImage(File(usuario.fotoPerfil!))
                                  : null,
                              child: usuario.fotoPerfil == null
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Hola, ${usuario.nombre}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    '¡Bienvenido a BudgetEase!',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<double>(
                future: _totalGastosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final total = snapshot.data ?? 0.0; 
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Total de Gastos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(total),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimos gastos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/gastos').then((_) {
                          if (mounted) {
                            _cargarGastos();
                          }
                        }).catchError((error) {
                          print('Error al navegar: $error');
                        });
                      },
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: Colors.blue
                        ),
                    ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Gasto>>(
                future: _gastosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No hay gastos registrados. ¡Añade tu primer gasto!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    final gastos = snapshot.data!;
                    final mostrarGastos = gastos.length > 2 ? gastos.sublist(0, 2) : gastos;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mostrarGastos.length,
                      itemBuilder: (context, index) {
                        final gasto = mostrarGastos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.shopping_cart, color: Colors.white),
                            ),
                            title: Text(gasto.titulo),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(gasto.fecha),
                            ),
                            trailing: Text(
                              currencyFormat.format(gasto.monto),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detalle_gasto',
                                arguments: gasto,
                              ).then((_) => _cargarGastos());
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/categorias')
                          .then((_) => _cargarGastos());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 30),
                          SizedBox(width: 16),
                          Text(
                            'Administrar categorías',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/metodos_pago')
                          .then((_) => _cargarGastos());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, size: 30),
                          SizedBox(width: 16),
                          Text(
                            'Administrar métodos de pago',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn1', // Necesario para evitar conflictos entre botones
            onPressed: () {
              Navigator.pushNamed(context, '/agregar_gasto')
                  .then((_) => _cargarGastos());
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Gasto'),
            backgroundColor: const Color.fromARGB(255, 130, 190, 238),
          ),
          const SizedBox(width: 10), 
          FloatingActionButton.extended(
            heroTag: 'btn2', 
            onPressed: () {
              Navigator.pushNamed(context, '/agregar_metodo_pago');
            },
            icon: const Icon(Icons.credit_card),
            label: const Text('Método de Pago'),
            backgroundColor: const Color.fromARGB(255, 130, 190, 238),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueAccent,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/reportes');
              break;
            case 2:
              Navigator.pushNamed(context, ''); 
              break;
            case 3:
              Navigator.pushNamed(context, ''); 
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}