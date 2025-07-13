import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/gasto.dart';
import '../../domain/entities/metodo_pago.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'budgetease.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {

        // Tabla de usuarios
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            correo TEXT,
            usuario TEXT,
            contrasena TEXT,
            fotoPerfil TEXT
          )
        ''');

        // Tabla de categorías
        await db.execute('''
          CREATE TABLE categorias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT UNIQUE,
            cantidadGastos INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Tabla de métodos de pago
        await db.execute('''
          CREATE TABLE metodos_pago (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            descripcion TEXT
          )
        ''');

        // Tabla de gastos
        await db.execute('''
          CREATE TABLE gastos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            monto REAL NOT NULL,
            categoria TEXT NOT NULL,
            fecha TEXT NOT NULL,
            descripcion TEXT,
            usuario_id INTEGER NOT NULL,
            metodo_pago_id INTEGER,
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
            FOREIGN KEY (metodo_pago_id) REFERENCES metodos_pago (id)
          )
        ''');

        // Insertar categorías por defecto
        await db.insert('categorias', {'nombre': 'Comida', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Ropa', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Vivienda', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Transporte', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Entretenimiento', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Salud', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Educación', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Familia', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Mascota', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Zapatos', 'cantidadGastos': 0});
        await db.insert('categorias', {'nombre': 'Recibos', 'cantidadGastos': 0});

        // Insertar métodos de pago por defecto
        await db.insert('metodos_pago', {'nombre': 'Efectivo', 'descripcion': 'Pago en efectivo'});
        await db.insert('metodos_pago', {'nombre': 'Tarjeta de Crédito', 'descripcion': 'Pago con tarjeta de crédito'});
        await db.insert('metodos_pago', {'nombre': 'Tarjeta de Débito', 'descripcion': 'Pago con tarjeta de débito'});
        await db.insert('metodos_pago', {'nombre': 'Transferencia Bancaria', 'descripcion': 'Pago por transferencia bancaria'});

        
      },
    );
  }

  // CRUD para Usuario
  static Future<int> insertarUsuario(Usuario usuario) async {
    final dbClient = await db;
    return await dbClient.insert('usuarios', usuario.toMap());
  }

  // Verifica si el usuario ya existe por nombre de usuario
  static Future<Usuario?> getUsuario(String usuario, String contrasena) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'usuarios',
      where: 'usuario = ? AND contrasena = ?',
      whereArgs: [usuario, contrasena],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Obtiene un usuario por ID
  static Future<Usuario?> getUsuarioById(int id) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  // Obtiene un usuario por nombre de usuario
  static Future<Usuario?> getUsuarioByNombre(String nombreUsuario) async {
    final dbClient = await db;

    // Consulta para buscar el usuario por nombre
    final result = await dbClient.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [nombreUsuario],
    );

    // Si se encuentra un resultado, conviértelo en un objeto Usuario
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }

    // Si no se encuentra, devuelve null
    return null;
  }

  // Actualiza un usuario existente
  static Future<int> updateUsuario(Usuario usuario) async {
    final dbClient = await db;
    return await dbClient.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // CRUD para Categoría
  static Future<int> insertarCategoria(Categoria categoria) async {
    final dbClient = await db;
    return await dbClient.insert('categorias', categoria.toMap());
  }

  // Obtiene todas las categorías
  static Future<List<Categoria>> getCategorias() async {
    final dbClient = await db;
    final result = await dbClient.query('categorias');
    return result.map((map) => Categoria.fromMap(map)).toList();
  }

  // Obtiene una categoría por nombre
  static Future<Categoria?> getCategoriaByNombre(String nombre) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'categorias',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );

    if (maps.isNotEmpty) {
      return Categoria.fromMap(maps.first);
    }
    return null;
  }

  // Actualiza una categoría existente
  static Future<int> updateCategoria(Categoria categoria) async {
    final dbClient = await db;
    return await dbClient.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  // CRUD para Método de Pago
  static Future<int> insertarMetodoPago(MetodoPago metodoPago) async {
    final dbClient = await db;
    return await dbClient.insert('metodos_pago', metodoPago.toMap());
  }

  // Obtiene todos los métodos de pago
  static Future<List<MetodoPago>> getMetodosPago() async {
    final dbClient = await db;
    final result = await dbClient.query('metodos_pago');
    return result.map((map) => MetodoPago.fromMap(map)).toList();
  }

  // Obtiene un método de pago por nombre
  static Future<MetodoPago?> getMetodoPagoByNombre(String nombre) async {
  final dbClient = await db;
  final result = await dbClient.query(
    'metodos_pago',
    where: 'LOWER(nombre) = ?',
    whereArgs: [nombre.toLowerCase()],
  );
  if (result.isNotEmpty) {
    return MetodoPago.fromMap(result.first);
  }
  return null;
}


  // CRUD para Gasto
  static Future<int> insertarGasto(Gasto gasto, int usuarioId, int? metodoPagoId) async {
    final dbClient = await db;

    // Incrementar contador de categoría
    var categoria = await getCategoriaByNombre(gasto.categoria);
    if (categoria != null) {
      categoria = Categoria(
        id: categoria.id,
        nombre: categoria.nombre,
        cantidadGastos: categoria.cantidadGastos + 1,
      );
      await updateCategoria(categoria); // Actualiza la categoría en la base de datos
    }

    // Si el método de pago es nulo, asignar el ID del método de pago por defecto
    final gastoMap = gasto.toMap();
    gastoMap['usuario_id'] = usuarioId;
    gastoMap['metodo_pago_id'] = metodoPagoId;

    // Insertar el gasto en la base de datos
    return await dbClient.insert('gastos', gastoMap);
  }

  // Obtiene todos los gastos de un usuario
  static Future<List<Gasto>> getGastosByUsuario(int usuarioId) async {
  final dbClient = await db;

  // Realizar una consulta para obtener los gastos del usuario, incluyendo el nombre del método de pago
  final result = await dbClient.rawQuery('''
    SELECT 
      gastos.*, 
      metodos_pago.nombre AS metodo_pago_nombre
    FROM gastos
    LEFT JOIN metodos_pago ON gastos.metodo_pago_id = metodos_pago.id
    WHERE gastos.usuario_id = ?
    ORDER BY fecha DESC
  ''', [usuarioId]);

  return result.map((map) => Gasto.fromMap(map)).toList();
}

  // Obtiene los gastos de un usuario por categoría
  static Future<List<Gasto>> getGastosByCategoria(int usuarioId, String categoria) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'gastos',
      where: 'usuario_id = ? AND categoria = ?',
      whereArgs: [usuarioId, categoria],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Gasto.fromMap(map)).toList();
  }

  // Obtiene el total de gastos de un usuario
  static Future<double> getTotalGastosByUsuario(int usuarioId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT SUM(monto) as total FROM gastos WHERE usuario_id = ?',
      [usuarioId],
    );
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  // Elimina un gasto por ID
  static Future<int> deleteGasto(int id) async {
    final dbClient = await db;
    
    // Obtener el gasto para decrementar el contador de categoría
    final gastoMaps = await dbClient.query(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (gastoMaps.isNotEmpty) {
      final gasto = Gasto.fromMap(gastoMaps.first);
      var categoria = await getCategoriaByNombre(gasto.categoria);
      if (categoria != null) {
        categoria = Categoria(
          id: categoria.id,
          nombre: categoria.nombre,
          cantidadGastos: categoria.cantidadGastos - 1,
        );
        await updateCategoria(categoria);
      }
    }
    
    return await dbClient.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtiene el total de gastos por mes y año de un usuario
  static Future<double> getTotalGastosPorMes(int usuarioId, int anio, int mes) async {
    final dbClient = await db;

    final fechaInicio = DateTime(anio, mes, 1);
    final fechaFin = DateTime(anio, mes + 1, 0, 23, 59, 59);

    final result = await dbClient.rawQuery(
      'SELECT SUM(monto) as total FROM gastos WHERE usuario_id = ? AND fecha BETWEEN ? AND ?',
      [
        usuarioId,
        fechaInicio.toIso8601String(),
        fechaFin.toIso8601String(),
      ],
    );

    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  // Obtiene los gastos de un usuario por mes y año
  static Future<List<Gasto>> getGastosPorMes(int usuarioId, int anio, int mes) async {
    final dbClient = await db;

    // Definir el rango de fechas para el mes
    final inicio = DateTime(anio, mes, 1);
    final fin = DateTime(anio, mes + 1, 0, 23, 59, 59);

    // Consultar los gastos dentro del rango de fechas
    final result = await dbClient.query(
      'gastos',
      where: 'usuario_id = ? AND fecha BETWEEN ? AND ?',
      whereArgs: [
        usuarioId,
        inicio.toIso8601String(),
        fin.toIso8601String(),
      ],
      orderBy: 'fecha DESC',
    );

    // Convertir los resultados en una lista de objetos Gasto
    return result.map((map) => Gasto.fromMap(map)).toList();
  }
  
  // Actualiza un gasto existente
  static Future<int> updateGasto(Gasto gasto) async {
  final dbClient = await db;
  return await dbClient.update(
    'gastos',
    gasto.toMap(),
    where: 'id = ?',
    whereArgs: [gasto.id],
  );
}
}
