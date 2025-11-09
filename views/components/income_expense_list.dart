import 'package:flutter/material.dart';
import 'package:finanshome/models/finance_model.dart';

String _formatMoney(double amount) {
  return amount
      .toStringAsFixed(2)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}

class IncomeExpenseList extends StatefulWidget {
  final List<Income> incomes;
  final List<Expense> expenses;
  final List<Debt> debts;
  final List<DebtPayment> debtPayments;
  final Function(String) onDeleteIncome;
  final Function(String) onDeleteExpense;
  final Function(String) onDeleteDebt;
  final Function(Income) onEditIncome;
  final Function(Expense) onEditExpense;
  final Function(Debt) onEditDebt;
  final Function(Debt) onViewDebtHistory;

  const IncomeExpenseList({
    super.key,
    required this.incomes,
    required this.expenses,
    required this.debts,
    required this.debtPayments,
    required this.onDeleteIncome,
    required this.onDeleteExpense,
    required this.onDeleteDebt,
    required this.onEditIncome,
    required this.onEditExpense,
    required this.onEditDebt,
    required this.onViewDebtHistory,
  });

  @override
  State<IncomeExpenseList> createState() => _IncomeExpenseListState();
}

class _IncomeExpenseListState extends State<IncomeExpenseList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Gelirler (${widget.incomes.length})'),
              Tab(text: 'Giderler (${widget.expenses.length})'),
              Tab(text: 'Borçlar (${widget.debts.length})'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _IncomesList(
                  incomes: widget.incomes,
                  onDelete: widget.onDeleteIncome,
                  onEdit: widget.onEditIncome,
                ),
                _ExpensesList(
                  expenses: widget.expenses,
                  onDelete: widget.onDeleteExpense,
                  onEdit: widget.onEditExpense,
                ),
                _DebtsList(
                  debts: widget.debts,
                  debtPayments: widget.debtPayments,
                  onDelete: widget.onDeleteDebt,
                  onEdit: widget.onEditDebt,
                  onViewHistory: widget.onViewDebtHistory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomesList extends StatelessWidget {
  final List<Income> incomes;
  final Function(String) onDelete;
  final Function(Income) onEdit;

  const _IncomesList({
    required this.incomes,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return const Center(child: Text('Henüz gelir eklenmedi'));
    }

    return ListView.builder(
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return Dismissible(
          key: Key(income.id),
          onDismissed: (_) => onDelete(income.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: Icon(Icons.trending_up, color: Colors.green),
            title: Text(income.title),
            subtitle: Text(income.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${_formatMoney(income.amount)} TL',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Silme Onayı'),
                        content: Text(
                          '${income.title} gelirini silmek istediğinize emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete(income.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () => onEdit(income),
          ),
        );
      },
    );
  }
}

class _ExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String) onDelete;
  final Function(Expense) onEdit;

  const _ExpensesList({
    required this.expenses,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Henüz gider eklenmedi'));
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id),
          onDismissed: (_) => onDelete(expense.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: Icon(Icons.trending_down, color: Colors.red),
            title: Text(expense.title),
            subtitle: Text(expense.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-${_formatMoney(expense.amount)} TL',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Silme Onayı'),
                        content: Text(
                          '${expense.title} giderini silmek istediğinize emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete(expense.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () => onEdit(expense),
          ),
        );
      },
    );
  }
}

class _DebtsList extends StatelessWidget {
  final List<Debt> debts;
  final List<DebtPayment> debtPayments;
  final Function(String) onDelete;
  final Function(Debt) onEdit;
  final Function(Debt) onViewHistory;

  const _DebtsList({
    required this.debts,
    required this.debtPayments,
    required this.onDelete,
    required this.onEdit,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return const Center(child: Text('Henüz borç eklenmedi'));
    }

    return ListView.builder(
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final progress = debt.remainingAmount / debt.totalAmount;
        return Dismissible(
          key: Key(debt.id),
          onDismissed: (_) => onDelete(debt.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: Icon(Icons.credit_card, color: Colors.orange),
            title: Text(debt.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kalan: ${_formatMoney(debt.remainingAmount)} TL'),
                LinearProgressIndicator(value: 1 - progress),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${debt.getRemainingMonths()} ay',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.history, color: Colors.blue),
                  tooltip: 'Ödeme Geçmişi',
                  onPressed: () => onViewHistory(debt),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Silme Onayı'),
                        content: Text(
                          '${debt.title} borcunu silmek istediğinize emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete(debt.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () => onEdit(debt),
          ),
        );
      },
    );
  }
}
