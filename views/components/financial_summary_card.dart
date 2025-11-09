import 'package:flutter/material.dart';
import 'package:finanshome/models/finance_model.dart';

class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummary summary;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onAddDebt;

  const FinancialSummaryCard({
    super.key,
    required this.summary,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onAddDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [const Color(0xFF2C3E50), const Color(0xFF34495E)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finansal Özet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Gelir',
                  amount: summary.totalIncome,
                  color: Colors.green,
                ),
                _SummaryItem(
                  label: 'Gider',
                  amount: summary.totalExpenses,
                  color: Colors.red,
                ),
                _SummaryItem(
                  label: 'Borç',
                  amount: summary.totalDebt,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MessageRow(
                    icon: Icons.info_outline,
                    message: summary.debtPaymentMessage,
                  ),
                  const SizedBox(height: 8),
                  _MessageRow(
                    icon: Icons.timeline,
                    message: summary.debtCompletionMessage,
                  ),
                  const SizedBox(height: 8),
                  _MessageRow(
                    icon: Icons.savings,
                    message: summary.savingsMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.trending_up,
                  label: 'Gelir',
                  onPressed: onAddIncome,
                ),
                _ActionButton(
                  icon: Icons.trending_down,
                  label: 'Gider',
                  onPressed: onAddExpense,
                ),
                _ActionButton(
                  icon: Icons.credit_card,
                  label: 'Borç',
                  onPressed: onAddDebt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} TL',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MessageRow extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageRow({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
