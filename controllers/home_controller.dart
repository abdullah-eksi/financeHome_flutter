import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:finanshome/models/finance_model.dart';
import 'package:finanshome/service/db_service.dart';
import 'package:finanshome/utils/constants.dart';

class HomeController with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  late BudgetAppState _state = BudgetAppState(
    incomes: [],
    expenses: [],
    debts: [],
    transactionLogs: [],
  );

  BudgetAppState get state => _state;
  FinancialSummary get summary => _state.financialSummary;
  List<ChartData> get chartData => _state.chartData;
  List<ChartData> get expenseChartData => _state.expenseChartData;

  HomeController() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final incomes = await _dbService.getAllIncomes();
      final expenses = await _dbService.getAllExpenses();
      final debts = await _dbService.getAllDebts();
      final logs = await _dbService.getAllTransactionLogs();
      final debtPayments = await _dbService.getAllDebtPayments();

      _state = BudgetAppState(
        incomes: incomes,
        expenses: expenses,
        debts: debts,
        transactionLogs: logs,
        debtPayments: debtPayments,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Veri yükleme hatası: $e');
    }
  }

  Future<void> addIncome({
    required String title,
    required double amount,
    required String category,
    String? description,
    double debtPaymentAmount = 0,
  }) async {
    try {
      final income = Income(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
        description: description,
      );

      await _dbService.addIncome(income);

      if (debtPaymentAmount > 0 && _state.debts.isNotEmpty) {
        final debt = _state.debts.first;
        await _loadData();
        if (summary.availableMoney >= debtPaymentAmount) {
          await makeDebtPayment(debt.id, debtPaymentAmount);
        }
      }

      await _loadData();
    } catch (e) {
      debugPrint('Gelir ekleme hatası: $e');
    }
  }

  Future<void> updateIncome({
    required String id,
    required String title,
    required double amount,
    required String category,
    String? description,
  }) async {
    try {
      final income = Income(
        id: id,
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
        description: description,
      );

      await _dbService.updateIncome(income);
      await _loadData();
    } catch (e) {
      debugPrint('Gelir güncelleme hatası: $e');
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _dbService.deleteIncome(id);
      await _loadData();
    } catch (e) {
      debugPrint('Gelir silme hatası: $e');
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    String? description,
  }) async {
    try {
      final expense = Expense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
        description: description,
      );

      await _dbService.addExpense(expense);
      await _loadData();
    } catch (e) {
      debugPrint('Gider ekleme hatası: $e');
    }
  }

  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    String? description,
  }) async {
    try {
      final expense = Expense(
        id: id,
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
        description: description,
      );

      await _dbService.updateExpense(expense);
      await _loadData();
    } catch (e) {
      debugPrint('Gider güncelleme hatası: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dbService.deleteExpense(id);
      await _loadData();
    } catch (e) {
      debugPrint('Gider silme hatası: $e');
    }
  }

  Future<void> addDebt({
    required String title,
    required double totalAmount,
    required double monthlyPayment,
    DateTime? endDate,
    String? description,
  }) async {
    try {
      final debt = Debt(
        id: const Uuid().v4(),
        title: title,
        totalAmount: totalAmount,
        remainingAmount: totalAmount,
        startDate: DateTime.now(),
        endDate: endDate,
        monthlyPayment: monthlyPayment,
        description: description,
      );

      await _dbService.addDebt(debt);
      await _loadData();
    } catch (e) {
      debugPrint('Borç ekleme hatası: $e');
    }
  }

  Future<void> updateDebt({
    required String id,
    required String title,
    required double totalAmount,
    required double remainingAmount,
    required double monthlyPayment,
    DateTime? endDate,
    String? description,
  }) async {
    try {
      final debt = Debt(
        id: id,
        title: title,
        totalAmount: totalAmount,
        remainingAmount: remainingAmount,
        startDate: DateTime.now(),
        endDate: endDate,
        monthlyPayment: monthlyPayment,
        description: description,
      );

      await _dbService.updateDebt(debt);
      await _loadData();
    } catch (e) {
      debugPrint('Borç güncelleme hatası: $e');
    }
  }

  Future<bool> makeDebtPayment(String debtId, double amount) async {
    try {
      if (summary.availableMoney < amount) {
        return false;
      }

      final debt = _state.debts.firstWhere((d) => d.id == debtId);

      final debtPayment = DebtPayment(
        id: const Uuid().v4(),
        debtId: debtId,
        amount: amount,
        paymentDate: DateTime.now(),
        note: 'Ödeme: ${debt.title}',
      );

      await _dbService.addDebtPayment(debtPayment);
      await _dbService.makeDebtPayment(debtId, amount);
      await _loadData();
      return true;
    } catch (e) {
      debugPrint('Borç ödeme hatası: $e');
      return false;
    }
  }

  List<DebtPayment> getDebtPaymentHistory(String debtId) {
    return _state.debtPayments
        .where((payment) => payment.debtId == debtId)
        .toList();
  }

  Future<void> deleteDebt(String id) async {
    try {
      await _dbService.deleteDebt(id);
      await _loadData();
    } catch (e) {
      debugPrint('Borç silme hatası: $e');
    }
  }

  String getDebtCompletionEstimate() {
    final summary = _state.financialSummary;
    if (summary.estimatedDebtMonths == 0) {
      return 'Borç yok';
    }
    return '${summary.estimatedDebtMonths} ayda';
  }

  List<ChartData> getIncomeChartData() {
    final Map<String, double> categoryTotals = {};

    for (var income in _state.incomes) {
      categoryTotals.update(
        income.category,
        (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }

    return categoryTotals.entries.map((entry) {
      return ChartData(
        category: entry.key,
        amount: entry.value,
        color: _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final index = category.hashCode % AppConstants.chartColors.length;
    return AppConstants.chartColors[index];
  }

  Map<String, double> getMonthlyAnalysis() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    double monthlyIncome = 0;
    double monthlyExpense = 0;

    for (var income in _state.incomes) {
      if (income.date.year == currentMonth.year &&
          income.date.month == currentMonth.month) {
        monthlyIncome += income.amount;
      }
    }

    for (var expense in _state.expenses) {
      if (expense.date.year == currentMonth.year &&
          expense.date.month == currentMonth.month) {
        monthlyExpense += expense.amount;
      }
    }

    return {
      'income': monthlyIncome,
      'expense': monthlyExpense,
      'available': monthlyIncome - monthlyExpense,
    };
  }
}
