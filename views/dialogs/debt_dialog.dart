import 'package:flutter/material.dart';
import 'package:finanshome/controllers/home_controller.dart';
import 'package:finanshome/models/finance_model.dart';

class DebtDialog {
  static void show(BuildContext context, HomeController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final monthlyPaymentCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Borç Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Borç Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Toplam Borç (₺)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monthlyPaymentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Aylık Ödeme (₺)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty &&
                    amountCtrl.text.isNotEmpty &&
                    monthlyPaymentCtrl.text.isNotEmpty) {
                  controller.addDebt(
                    title: titleCtrl.text,
                    totalAmount: double.parse(amountCtrl.text),
                    monthlyPayment: double.parse(monthlyPaymentCtrl.text),
                    description: descriptionCtrl.text,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  static void showEdit(
    BuildContext context,
    HomeController controller,
    dynamic debt,
  ) {
    final titleCtrl = TextEditingController(text: debt.title);
    final amountCtrl = TextEditingController(text: debt.totalAmount.toString());
    final remainingCtrl = TextEditingController(
      text: debt.remainingAmount.toString(),
    );
    final monthlyPaymentCtrl = TextEditingController(
      text: debt.monthlyPayment.toString(),
    );
    final descriptionCtrl = TextEditingController(text: debt.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Borç Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Borç Adı'),
                ),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Toplam Borç'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: remainingCtrl,
                  decoration: const InputDecoration(labelText: 'Kalan Borç'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: monthlyPaymentCtrl,
                  decoration: const InputDecoration(labelText: 'Aylık Ödeme'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                  controller.updateDebt(
                    id: debt.id,
                    title: titleCtrl.text,
                    totalAmount: double.parse(amountCtrl.text),
                    remainingAmount: double.parse(remainingCtrl.text),
                    monthlyPayment: double.parse(monthlyPaymentCtrl.text),
                    description: descriptionCtrl.text,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  static void showPayment(BuildContext context, HomeController controller) {
    final amountCtrl = TextEditingController();
    final debts = controller.state.debts;

    if (debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödenmesi gereken borç bulunmamaktadır')),
      );
      return;
    }

    Debt? selectedDebt = debts.first;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Borç Öde'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Debt>(
                      initialValue: selectedDebt,
                      decoration: const InputDecoration(
                        labelText: 'Borç Seçin',
                        border: OutlineInputBorder(),
                      ),
                      items: debts.map((debt) {
                        return DropdownMenuItem(
                          value: debt,
                          child: Text(
                            '${debt.title} - Kalan: ${debt.remainingAmount.toStringAsFixed(2)} ₺',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDebt = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ödeme Tutarı (₺)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (selectedDebt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Kalan Borç: ${selectedDebt!.remainingAmount.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (amountCtrl.text.isNotEmpty && selectedDebt != null) {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      if (amount > 0 &&
                          amount <= selectedDebt!.remainingAmount) {
                        final success = await controller.makeDebtPayment(
                          selectedDebt!.id,
                          amount,
                        );
                        if (context.mounted) {
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${amount.toStringAsFixed(2)} ₺ ödendi',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Yetersiz bakiye! Mevcut bakiyeniz: ${controller.summary.availableMoney.toStringAsFixed(2)} ₺',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Geçersiz tutar')),
                        );
                      }
                    }
                  },
                  child: const Text('Öde'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
