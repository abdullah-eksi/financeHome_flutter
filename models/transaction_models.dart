import 'package:flutter/material.dart';

class Income {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'description': description,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      description: map['description'],
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      description: map['description'],
    );
  }
}

class Debt {
  final String id;
  final String title;
  final double totalAmount;
  double remainingAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final double monthlyPayment;
  final String? description;

  Debt({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.remainingAmount,
    required this.startDate,
    this.endDate,
    required this.monthlyPayment,
    this.description,
  });

  void makePayment(double amount) {
    if (amount <= remainingAmount) {
      remainingAmount -= amount;
    } else {
      remainingAmount = 0;
    }
  }

  int getRemainingMonths() {
    if (monthlyPayment <= 0) return 0;
    return (remainingAmount / monthlyPayment).ceil();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'monthlyPayment': monthlyPayment,
      'description': description,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      title: map['title'],
      totalAmount: map['totalAmount'].toDouble(),
      remainingAmount: map['remainingAmount'].toDouble(),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      monthlyPayment: map['monthlyPayment'].toDouble(),
      description: map['description'],
    );
  }
}

class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final DateTime paymentDate;
  final String? note;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'],
      debtId: map['debtId'],
      amount: map['amount'].toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      note: map['note'],
    );
  }
}

class TransactionLog {
  final String id;
  final String type;
  final String title;
  final double amount;
  final DateTime date;
  final String description;

  TransactionLog({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory TransactionLog.fromMap(Map<String, dynamic> map) {
    return TransactionLog(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
    );
  }
}

class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData({
    required this.category,
    required this.amount,
    required this.color,
  });
}
