import 'package:flutter/material.dart';
import 'package:finanshome/controllers/home_controller.dart';
import 'package:finanshome/utils/constants.dart';

class ExpenseDialog {
  static void show(BuildContext context, HomeController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories.first;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gider Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tutar (₺)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.expenseCategories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
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
                        amountCtrl.text.isNotEmpty) {
                      controller.addExpense(
                        title: titleCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        category: selectedCategory,
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
      },
    );
  }

  static void showEdit(
    BuildContext context,
    HomeController controller,
    dynamic expense,
  ) {
    final titleCtrl = TextEditingController(text: expense.title);
    final amountCtrl = TextEditingController(text: expense.amount.toString());
    final descriptionCtrl = TextEditingController(
      text: expense.description ?? '',
    );
    String selectedCategory = expense.category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gider Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Başlık'),
                    ),
                    TextField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(labelText: 'Tutar'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: AppConstants.expenseCategories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
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
                    if (titleCtrl.text.isNotEmpty &&
                        amountCtrl.text.isNotEmpty) {
                      controller.updateExpense(
                        id: expense.id,
                        title: titleCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        category: selectedCategory,
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
      },
    );
  }
}
