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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subscriptions (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            cost REAL NOT NULL,
            cycle INTEGER NOT NULL,
            category TEXT NOT NULL,
            nextRenewal TEXT NOT NULL,
            colorValue INTEGER NOT NULL DEFAULT ${0xFF3D5AFE},
            isTrial INTEGER NOT NULL DEFAULT 0,
            trialEndDate TEXT,
            notes TEXT,
            reminderEnabled INTEGER NOT NULL DEFAULT 1,
            reminderDaysBefore INTEGER NOT NULL DEFAULT 2
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
      onUpgrade: (db, oldVersion, newVersion) async {
        // Adds the new columns to anyone who already has version 1 installed,
        // so their existing subscriptions are preserved rather than wiped.
        // Note: paymentMethod is intentionally NOT added here anymore — the
        // feature was removed. Any device that already has that column from
        // an earlier test build just keeps it, unused; it's harmless.
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE subscriptions ADD COLUMN colorValue INTEGER NOT NULL DEFAULT ${0xFF3D5AFE}');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN isTrial INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN trialEndDate TEXT');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN notes TEXT');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN reminderEnabled INTEGER NOT NULL DEFAULT 1');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN reminderDaysBefore INTEGER NOT NULL DEFAULT 2');
        }
      },
    );
  }

  Map<String, dynamic> _toMap(Subscription s) {
    return {
      'id': s.id,
      'name': s.name,
      'cost': s.cost,
      'cycle': s.cycle.index,
      'category': s.category,
      'nextRenewal': s.nextRenewal.toIso8601String(),
      'colorValue': s.colorValue,
      'isTrial': s.isTrial ? 1 : 0,
      'trialEndDate': s.trialEndDate?.toIso8601String(),
      'notes': s.notes,
      'reminderEnabled': s.reminderEnabled ? 1 : 0,
      'reminderDaysBefore': s.reminderDaysBefore,
    };
  }

  Subscription _fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      name: map['name'] as String,
      cost: (map['cost'] as num).toDouble(),
      cycle: BillingCycle.values[map['cycle'] as int],
      category: map['category'] as String,
      nextRenewal: DateTime.parse(map['nextRenewal'] as String),
      colorValue: map['colorValue'] as int? ?? 0xFF3D5AFE,
      isTrial: (map['isTrial'] as int? ?? 0) == 1,
      trialEndDate: map['trialEndDate'] != null ? DateTime.parse(map['trialEndDate'] as String) : null,
      notes: map['notes'] as String?,
      reminderEnabled: (map['reminderEnabled'] as int? ?? 1) == 1,
      reminderDaysBefore: map['reminderDaysBefore'] as int? ?? 2,
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