import 'package:finanshome/models/finance_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'budget_app2.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE debt_payments(
          id TEXT PRIMARY KEY,
          debtId TEXT NOT NULL,
          amount REAL NOT NULL,
          paymentDate INTEGER NOT NULL,
          note TEXT,
          FOREIGN KEY (debtId) REFERENCES debts (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incomes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE debts(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        monthlyPayment REAL NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_logs(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE debt_payments(
        id TEXT PRIMARY KEY,
        debtId TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (debtId) REFERENCES debts (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> addIncome(Income income) async {
    final db = await database;
    await db.insert(
      'incomes',
      income.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Income>> getAllIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  Future<void> updateIncome(Income income) async {
    final db = await database;
    await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<void> deleteIncome(String id) async {
    final db = await database;
    await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addDebt(Debt debt) async {
    final db = await database;
    await db.insert(
      'debts',
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debts');
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<void> updateDebt(Debt debt) async {
    final db = await database;
    await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  Future<void> deleteDebt(String id) async {
    final db = await database;
    await db.delete('debt_payments', where: 'debtId = ?', whereArgs: [id]);
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> makeDebtPayment(String debtId, double amount) async {
    final db = await database;
    final debts = await db.query('debts', where: 'id = ?', whereArgs: [debtId]);

    if (debts.isNotEmpty) {
      var debt = Debt.fromMap(debts.first);
      debt.makePayment(amount);
      await db.update(
        'debts',
        debt.toMap(),
        where: 'id = ?',
        whereArgs: [debtId],
      );
    }
  }

  Future<void> addDebtPayment(DebtPayment payment) async {
    final db = await database;
    await db.insert(
      'debt_payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DebtPayment>> getAllDebtPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debt_payments',
      orderBy: 'paymentDate DESC',
    );
    return List.generate(maps.length, (i) => DebtPayment.fromMap(maps[i]));
  }

  Future<List<DebtPayment>> getDebtPaymentsByDebtId(String debtId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debt_payments',
      where: 'debtId = ?',
      whereArgs: [debtId],
      orderBy: 'paymentDate DESC',
    );
    return List.generate(maps.length, (i) => DebtPayment.fromMap(maps[i]));
  }

  Future<void> deleteDebtPayment(String id) async {
    final db = await database;
    await db.delete('debt_payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addTransactionLog(TransactionLog log) async {
    final db = await database;
    await db.insert(
      'transaction_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionLog>> getAllTransactionLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_logs',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionLog.fromMap(maps[i]));
  }

  Future<void> clearTransactionLogs() async {
    final db = await database;
    await db.delete('transaction_logs');
  }

  Future<List<Income>> getIncomesByMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
