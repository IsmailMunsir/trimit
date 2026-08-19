import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import '../models/payment_record.dart';

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
      version: 5,
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
            reminderDaysBefore INTEGER NOT NULL DEFAULT 2,
            status INTEGER NOT NULL DEFAULT 0,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0,
            walletId TEXT
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
        await db.execute('''
          CREATE TABLE wallets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            colorValue INTEGER NOT NULL DEFAULT ${0xFF3D5AFE}
          )
        ''');
        await db.execute('''
          CREATE TABLE payment_records (
            id TEXT PRIMARY KEY,
            subscriptionId TEXT NOT NULL,
            subscriptionName TEXT NOT NULL,
            amount REAL NOT NULL,
            paidOn TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE subscriptions ADD COLUMN colorValue INTEGER NOT NULL DEFAULT ${0xFF3D5AFE}');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN isTrial INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN trialEndDate TEXT');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN notes TEXT');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN reminderEnabled INTEGER NOT NULL DEFAULT 1');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN reminderDaysBefore INTEGER NOT NULL DEFAULT 2');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE subscriptions ADD COLUMN status INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE subscriptions ADD COLUMN isArchived INTEGER NOT NULL DEFAULT 0');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE subscriptions ADD COLUMN walletId TEXT');
          await db.execute('''
            CREATE TABLE wallets (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              colorValue INTEGER NOT NULL DEFAULT ${0xFF3D5AFE}
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE payment_records (
              id TEXT PRIMARY KEY,
              subscriptionId TEXT NOT NULL,
              subscriptionName TEXT NOT NULL,
              amount REAL NOT NULL,
              paidOn TEXT NOT NULL
            )
          ''');
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
      'status': s.status.index,
      'isFavorite': s.isFavorite ? 1 : 0,
      'isArchived': s.isArchived ? 1 : 0,
      'walletId': s.walletId,
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
      status: SubscriptionStatus.values[map['status'] as int? ?? 0],
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      isArchived: (map['isArchived'] as int? ?? 0) == 1,
      walletId: map['walletId'] as String?,
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

  // ---- Wallet methods ----

  Future<void> insertWallet(Wallet w) async {
    final db = await database;
    await db.insert('wallets', w.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Wallet>> getAllWallets() async {
    final db = await database;
    final rows = await db.query('wallets', orderBy: 'name ASC');
    return rows.map((row) => Wallet.fromMap(row)).toList();
  }

  Future<void> deleteWallet(String id) async {
    final db = await database;
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
    await db.rawUpdate('UPDATE subscriptions SET walletId = NULL WHERE walletId = ?', [id]);
  }

  // ---- Payment record methods ----

  Future<void> insertPaymentRecord(PaymentRecord p) async {
    final db = await database;
    await db.insert('payment_records', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PaymentRecord>> getPaymentHistoryFor(String subscriptionId) async {
    final db = await database;
    final rows = await db.query(
      'payment_records',
      where: 'subscriptionId = ?',
      whereArgs: [subscriptionId],
      orderBy: 'paidOn DESC',
    );
    return rows.map((row) => PaymentRecord.fromMap(row)).toList();
  }

  Future<List<PaymentRecord>> getAllPaymentRecords() async {
    final db = await database;
    final rows = await db.query('payment_records', orderBy: 'paidOn DESC');
    return rows.map((row) => PaymentRecord.fromMap(row)).toList();
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