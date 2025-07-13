import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetease2/features/profile/presentation/pages/perfil_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/welcome_screen.dart';
import 'features/auth/presentation/pages/recuperar_contrasena_screen.dart';
import 'features/home/presentation/pages/gastos/detalle_gasto_screen.dart';
import 'features/home/presentation/pages/gastos/agregar_gasto_screen.dart';
import 'features/home/presentation/pages/gastos/gasto_screen.dart';
import 'features/home/presentation/pages/categorias/categorias_screen.dart';
import 'features/home/presentation/pages/categorias/categorias_buscar_screen.dart';
import 'features/home/presentation/pages/metodos_pago/metodo_pago_screen.dart';
import 'features/home/presentation/pages/metodos_pago/agregar_metodo_pago.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/home/presentation/pages/reporte_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), 
      ),
      home: const WelcomeScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/categorias': (context) => const CategoriasScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/detalle_gasto': (context) => const DetalleGastoScreen(),
        '/agregar_gasto': (context) => const AgregarGastoScreen(),
        '/reportes': (context) => const ReportesScreen(),
        '/buscar_categorias': (context) => const CategoriasBuscarScreen(),
        "/gastos": (context) => const GastosScreen(),
        "/recuperar_contrasena": (context) => const RecuperarContrasenaScreen(),
        "/agregar_metodo_pago": (context) => const AgregarMetodoPagoScreen(),
        "/metodos_pago": (context) => const MetodosPagoScreen(),
      },
    );
  }
}


