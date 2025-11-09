import 'package:flutter/material.dart';
import 'package:finanshome/models/transaction_models.dart';
import 'package:finanshome/utils/formatters.dart';
import 'package:finanshome/utils/constants.dart';

class BudgetAppState {
  final List<Income> incomes;
  final List<Expense> expenses;
  final List<Debt> debts;
  final List<TransactionLog> transactionLogs;
  final List<DebtPayment> debtPayments;

  BudgetAppState({
    required this.incomes,
    required this.expenses,
    required this.debts,
    required this.transactionLogs,
    this.debtPayments = const [],
  });

  BudgetAppState copyWith({
    List<Income>? incomes,
    List<Expense>? expenses,
    List<Debt>? debts,
    List<TransactionLog>? transactionLogs,
    List<DebtPayment>? debtPayments,
  }) {
    return BudgetAppState(
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
      debts: debts ?? this.debts,
      transactionLogs: transactionLogs ?? this.transactionLogs,
      debtPayments: debtPayments ?? this.debtPayments,
    );
  }

  double get totalIncome {
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get totalDebtPayments {
    return debtPayments.fold(0, (sum, payment) => sum + payment.amount);
  }

  double get totalDebt {
    return debts.fold(0, (sum, debt) => sum + debt.remainingAmount);
  }

  double get availableMoney {
    return totalIncome - totalExpenses - totalDebtPayments;
  }

  FinancialSummary get financialSummary {
    final available = availableMoney;
    final totalMonthlyDebtPayment = debts.fold(
      0.0,
      (sum, debt) => sum + debt.monthlyPayment,
    );

    final afterDebtPayment = available - totalMonthlyDebtPayment;
    final suggestedSavings = afterDebtPayment > 0
        ? (afterDebtPayment * 0.2)
        : 0.0;
    final suggestedInvestment = afterDebtPayment > 0
        ? (afterDebtPayment * 0.3)
        : 0.0;

    int estimatedMonths = 0;
    if (totalDebt > 0 && totalMonthlyDebtPayment > 0) {
      estimatedMonths = (totalDebt / totalMonthlyDebtPayment).ceil();
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalDebt: totalDebt,
      availableMoney: available,
      suggestedSavings: suggestedSavings,
      suggestedDebtPayment: totalMonthlyDebtPayment,
      suggestedInvestment: suggestedInvestment,
      estimatedDebtMonths: estimatedMonths,
      totalMonthlyDebtPayment: totalMonthlyDebtPayment,
    );
  }

  List<ChartData> get chartData {
    return [
      ChartData(category: 'Gelir', amount: totalIncome, color: Colors.green),
      ChartData(category: 'Gider', amount: totalExpenses, color: Colors.red),
      ChartData(category: 'Borç', amount: totalDebt, color: Colors.orange),
    ];
  }

  List<ChartData> get expenseChartData {
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
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
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double totalDebt;
  final double availableMoney;
  final double suggestedSavings;
  final double suggestedDebtPayment;
  final double suggestedInvestment;
  final int estimatedDebtMonths;
  final double totalMonthlyDebtPayment;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalDebt,
    required this.availableMoney,
    required this.suggestedSavings,
    required this.suggestedDebtPayment,
    required this.suggestedInvestment,
    required this.estimatedDebtMonths,
    required this.totalMonthlyDebtPayment,
  });

  String formatMoney(double amount) {
    return MoneyFormatter.format(amount);
  }

  String get debtPaymentMessage {
    if (totalDebt == 0) return "Borcunuz bulunmamaktadır. Harika!";
    if (totalMonthlyDebtPayment > availableMoney) {
      return "Aylık borç ödemeniz (${formatMoney(totalMonthlyDebtPayment)} TL) kalan paranızdan (${formatMoney(availableMoney)} TL) fazla. Gelir artırmanız gerekiyor.";
    }
    return "Aylık ${formatMoney(totalMonthlyDebtPayment)} TL borç ödemeniz var. Kalan paranız: ${formatMoney(availableMoney - totalMonthlyDebtPayment)} TL";
  }

  String get debtCompletionMessage {
    if (totalDebt == 0) return "";
    if (estimatedDebtMonths == 0 || totalMonthlyDebtPayment == 0) {
      return "Borç ödeme planı oluşturulamadı. Lütfen aylık ödeme tutarını kontrol edin.";
    }
    if (estimatedDebtMonths > 120) {
      return "Mevcut ödeme planıyla borcun bitmesi $estimatedDebtMonths ay sürecek. Aylık ödemeyi artırmanız önerilir.";
    }
    return "Toplam ${formatMoney(totalDebt)} TL borcunuz $estimatedDebtMonths ayda bitecek (Aylık ${formatMoney(totalMonthlyDebtPayment)} TL).";
  }

  String get savingsMessage {
    if (suggestedSavings <= 0) return "";
    return "Kalan paranızdan ${formatMoney(suggestedSavings)} TL tasarruf yapabilirsiniz.";
  }

  String get investmentMessage {
    if (suggestedInvestment <= 0) return "";
    return "💰 Yatırım Tavsiyesi: Kalan paranızın ${formatMoney(suggestedInvestment)} TL'sini düşük riskli yatırım araçlarında değerlendirebilirsiniz.";
  }
}
