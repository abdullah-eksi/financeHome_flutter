import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanshome/controllers/home_controller.dart';
import 'package:finanshome/models/finance_model.dart';
import 'package:finanshome/views/components/income_expense_list.dart';
import 'package:finanshome/views/components/chart_widget.dart';
import 'package:finanshome/views/components/debt_payment_history.dart';
import 'package:finanshome/views/components/modern_dialog.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Consumer<HomeController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('FinansHome'),
              elevation: 0,
              backgroundColor: const Color(0xFF2C3E50),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceCard(controller),

                  const SizedBox(height: 16),

                  // Grafik
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ChartWidget(
                      chartData: controller.chartData,
                      title: 'Gelir / Gider / Borç Dağılımı',
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IncomeExpenseList(
                      incomes: controller.state.incomes,
                      expenses: controller.state.expenses,
                      debts: controller.state.debts,
                      debtPayments: controller.state.debtPayments,
                      onDeleteIncome: (id) => controller.deleteIncome(id),
                      onDeleteExpense: (id) => controller.deleteExpense(id),
                      onDeleteDebt: (id) => controller.deleteDebt(id),
                      onEditIncome: (income) =>
                          _showEditIncomeDialog(context, controller, income),
                      onEditExpense: (expense) =>
                          _showEditExpenseDialog(context, controller, expense),
                      onEditDebt: (debt) =>
                          _showEditDebtDialog(context, controller, debt),
                      onViewDebtHistory: (debt) =>
                          _showDebtPaymentHistory(context, controller, debt),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showMainMenu(context, controller),
              tooltip: 'Ekle',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(HomeController controller) {
    final summary = controller.summary;
    final kalanPara = summary.availableMoney;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'KALAN PARANIZ',
            style: TextStyle(
              color: const Color.fromARGB(179, 190, 8, 8),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${summary.formatMoney(kalanPara)} ₺',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white30, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Gelir',
                summary.totalIncome,
                Colors.greenAccent,
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatColumn(
                'Gider',
                summary.totalExpenses,
                Colors.redAccent,
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatColumn('Borç', summary.totalDebt, Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 20),
          if (summary.totalDebt > 0) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary.debtCompletionMessage,
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (summary.investmentMessage.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            summary.investmentMessage,
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else if (summary.investmentMessage.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.investmentMessage,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, double amount, Color color) {
    String formatAmount(double amt) {
      return amt
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '${formatAmount(amount)} ₺',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDebtPaymentHistory(
    BuildContext context,
    HomeController controller,
    Debt debt,
  ) {
    final payments = controller.getDebtPaymentHistory(debt.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => DebtPaymentHistory(
          debt: debt,
          payments: payments,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showMainMenu(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'İşlem Seç',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 16),
              _buildMenuTile(
                icon: Icons.trending_up,
                title: 'Gelir Ekle',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAddIncomeDialog(context, controller);
                },
              ),
              _buildMenuTile(
                icon: Icons.trending_down,
                title: 'Gider Ekle',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAddExpenseDialog(context, controller);
                },
              ),
              _buildMenuTile(
                icon: Icons.credit_card,
                title: 'Borç Ekle',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAddDebtDialog(context, controller);
                },
              ),
              _buildMenuTile(
                icon: Icons.payment,
                title: 'Borç Öde',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showDebtPaymentDialog(context, controller);
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context, HomeController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    String selectedCategory = 'Maaş';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ModernDialog(
              title: 'Gelir Ekle',
              icon: Icons.trending_up,
              iconColor: Colors.green,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernTextField(
                    controller: titleCtrl,
                    label: 'Başlık',
                    icon: Icons.title,
                  ),
                  ModernTextField(
                    controller: amountCtrl,
                    label: 'Tutar (₺)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  ModernDropdown(
                    value: selectedCategory,
                    label: 'Kategori',
                    icon: Icons.category,
                    items: ['Maaş', 'Freelance', 'Yatırım', 'Diğer'],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  ModernTextField(
                    controller: descriptionCtrl,
                    label: 'Açıklama',
                    icon: Icons.notes,
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                ModernButton(
                  text: 'İptal',
                  onPressed: () => Navigator.pop(dialogContext),
                  color: Colors.grey,
                  isOutlined: true,
                ),
                ModernButton(
                  text: 'Ekle',
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty &&
                        amountCtrl.text.isNotEmpty) {
                      controller.addIncome(
                        title: titleCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        category: selectedCategory,
                        description: descriptionCtrl.text,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  color: Colors.green,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context, HomeController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    String selectedCategory = 'Kira';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ModernDialog(
              title: 'Gider Ekle',
              icon: Icons.trending_down,
              iconColor: Colors.red,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernTextField(
                    controller: titleCtrl,
                    label: 'Başlık',
                    icon: Icons.title,
                  ),
                  ModernTextField(
                    controller: amountCtrl,
                    label: 'Tutar (₺)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  ModernDropdown(
                    value: selectedCategory,
                    label: 'Kategori',
                    icon: Icons.category,
                    items: [
                      'Kira',
                      'Market',
                      'Fatura',
                      'Eğlence',
                      'Ulaşım',
                      'Sağlık',
                      'Diğer',
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  ModernTextField(
                    controller: descriptionCtrl,
                    label: 'Açıklama',
                    icon: Icons.notes,
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                ModernButton(
                  text: 'İptal',
                  onPressed: () => Navigator.pop(dialogContext),
                  color: Colors.grey,
                  isOutlined: true,
                ),
                ModernButton(
                  text: 'Ekle',
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
                  color: Colors.red,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddDebtDialog(BuildContext context, HomeController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final monthlyPaymentCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ModernDialog(
          title: 'Borç Ekle',
          icon: Icons.credit_card,
          iconColor: Colors.orange,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                controller: titleCtrl,
                label: 'Borç Adı',
                icon: Icons.label,
              ),
              ModernTextField(
                controller: amountCtrl,
                label: 'Toplam Borç (₺)',
                icon: Icons.account_balance_wallet,
                keyboardType: TextInputType.number,
              ),
              ModernTextField(
                controller: monthlyPaymentCtrl,
                label: 'Aylık Ödeme (₺)',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
              ),
              ModernTextField(
                controller: descriptionCtrl,
                label: 'Açıklama',
                icon: Icons.notes,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            ModernButton(
              text: 'İptal',
              onPressed: () => Navigator.pop(dialogContext),
              color: Colors.grey,
              isOutlined: true,
            ),
            ModernButton(
              text: 'Ekle',
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
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  void _showDebtPaymentDialog(BuildContext context, HomeController controller) {
    final amountCtrl = TextEditingController();
    final debts = controller.state.debts;

    if (debts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ödenmesi gereken borç bulunmamaktadır'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Debt? selectedDebt = debts.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ModernDialog(
              title: 'Borç Öde',
              icon: Icons.payment,
              iconColor: Colors.blue,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<Debt>(
                      initialValue: selectedDebt,
                      decoration: InputDecoration(
                        labelText: 'Borç Seçin',
                        prefixIcon: Icon(
                          Icons.list,
                          color: const Color(0xFF2C3E50),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2C3E50),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: debts.map((debt) {
                        return DropdownMenuItem(
                          value: debt,
                          child: Text(
                            '${debt.title} - ${debt.remainingAmount.toStringAsFixed(0)} ₺',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDebt = value;
                        });
                      },
                    ),
                  ),
                  ModernTextField(
                    controller: amountCtrl,
                    label: 'Ödeme Tutarı (₺)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  if (selectedDebt != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kalan Borç: ${selectedDebt!.remainingAmount.toStringAsFixed(2)} ₺',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                ModernButton(
                  text: 'İptal',
                  onPressed: () => Navigator.pop(dialogContext),
                  color: Colors.grey,
                  isOutlined: true,
                ),
                ModernButton(
                  text: 'Öde',
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
                                  'Yetersiz bakiye! Mevcut: ${controller.summary.availableMoney.toStringAsFixed(2)} ₺',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Geçersiz tutar'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  color: Colors.blue,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditIncomeDialog(
    BuildContext context,
    HomeController controller,
    dynamic income,
  ) {
    final titleCtrl = TextEditingController(text: income.title);
    final amountCtrl = TextEditingController(text: income.amount.toString());
    final descriptionCtrl = TextEditingController(
      text: income.description ?? '',
    );
    String selectedCategory = income.category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Gelir Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(labelText: 'Başlık'),
                    ),
                    TextField(
                      controller: amountCtrl,
                      decoration: InputDecoration(labelText: 'Tutar'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: ['Maaş', 'Freelance', 'Yatırım', 'Diğer']
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
                      decoration: InputDecoration(labelText: 'Açıklama'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty &&
                        amountCtrl.text.isNotEmpty) {
                      controller.updateIncome(
                        id: income.id,
                        title: titleCtrl.text,
                        amount: double.parse(amountCtrl.text),
                        category: selectedCategory,
                        description: descriptionCtrl.text,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text('Güncelle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditExpenseDialog(
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
              title: Text('Gider Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(labelText: 'Başlık'),
                    ),
                    TextField(
                      controller: amountCtrl,
                      decoration: InputDecoration(labelText: 'Tutar'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items:
                          [
                                'Kira',
                                'Market',
                                'Fatura',
                                'Eğlence',
                                'Ulaşım',
                                'Sağlık',
                                'Diğer',
                              ]
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
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
                      decoration: InputDecoration(labelText: 'Açıklama'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('İptal'),
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
                  child: Text('Güncelle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDebtDialog(
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
          title: Text('Borç Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: 'Borç Adı'),
                ),
                TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(labelText: 'Toplam Borç'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: remainingCtrl,
                  decoration: InputDecoration(labelText: 'Kalan Borç'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: monthlyPaymentCtrl,
                  decoration: InputDecoration(labelText: 'Aylık Ödeme'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionCtrl,
                  decoration: InputDecoration(labelText: 'Açıklama'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('İptal'),
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
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }
}
