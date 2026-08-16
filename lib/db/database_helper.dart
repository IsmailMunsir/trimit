import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trimit.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subscriptions (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            cost REAL NOT NULL,
            cycle INTEGER NOT NULL,
            category TEXT NOT NULL,
            nextRenewal TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL,
            emailVerified INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Converts a Subscription object into a plain Map (key-value pairs),
  // which is the format sqflite needs for saving to the database.
  Map<String, dynamic> _toMap(Subscription s) {
    return {
      'id': s.id,
      'name': s.name,
      'cost': s.cost,
      'cycle': s.cycle.index, // enums are stored as their position number (0, 1, 2)
      'category': s.category,
      'nextRenewal': s.nextRenewal.toIso8601String(), // dates stored as text
    };
  }

  // Converts a row back from the database into a real Subscription object.
  Subscription _fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
      cycle: BillingCycle.values[map['cycle'] as int],
      category: map['category'] as String,
      nextRenewal: DateTime.parse(map['nextRenewal'] as String),
    );
  }

  Future<void> insertSubscription(Subscription s) async {
    final db = await database;
    await db.insert(
      'subscriptions',
      _toMap(s),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subscription>> getAllSubscriptions() async {
    final db = await database;
    final rows = await db.query('subscriptions', orderBy: 'nextRenewal ASC');
    return rows.map((row) => _fromMap(row)).toList();
  }

  Future<void> deleteSubscription(String id) async {
    final db = await database;
    await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // ---- User / authentication methods ----

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }
}