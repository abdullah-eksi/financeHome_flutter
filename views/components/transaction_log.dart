import 'package:flutter/material.dart';
import 'package:finanshome/models/finance_model.dart';

class TransactionLogWidget extends StatelessWidget {
  final List<TransactionLog> transactionLogs;
  final VoidCallback onClear;

  const TransactionLogWidget({
    super.key,
    required this.transactionLogs,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İşlem Geçmişi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Günlüğü Temizle'),
                        content: const Text(
                          'Tüm işlem geçmişini silmek istediğinizden emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              onClear();
                              Navigator.pop(context);
                            },
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Temizle'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: transactionLogs.isEmpty
                ? const Center(child: Text('Henüz işlem kaydı yok'))
                : ListView.builder(
                    itemCount: transactionLogs.length,
                    itemBuilder: (context, index) {
                      final log = transactionLogs[index];
                      return _TransactionLogItem(log: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransactionLogItem extends StatelessWidget {
  final TransactionLog log;

  const _TransactionLogItem({required this.log});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(log.date);

    IconData icon;
    Color color;

    switch (log.type) {
      case 'income':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case 'expense':
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case 'debt':
      case 'debt_payment':
        icon = Icons.credit_card;
        color = Colors.orange;
        break;
      default:
        icon = Icons.receipt;
        color = Colors.blue;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(log.title),
      subtitle: Text(formattedDate),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${log.amount.toStringAsFixed(2)} TL',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            log.description,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
