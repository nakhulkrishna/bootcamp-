import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/features/expenses/data/expense_model.dart';
import 'package:gaming_center/features/expenses/providers/expense_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:gaming_center/core/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String searchQuery = '';
  ExpenseType? typeFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Expenses & Income",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Track your shop's financial health (Rent, Electricity, etc.)",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showAddTransactionDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Add Transaction",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // ✅ Summary Cards
            Consumer2<ExpenseProvider, SettingsProvider>(
              builder: (context, expenseProv, settingsProv, _) {
                final currency = settingsProv.settings.currencySymbol;
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3,
                  children: [
                    ReferenceStatCard(
                      title: "Total Income",
                      value: formatMoney(expenseProv.totalIncome, currencySymbol: currency),
                      icon: Icons.trending_up,
                    ),
                    ReferenceStatCard(
                      title: "Total Expenses",
                      value: formatMoney(expenseProv.totalExpense, currencySymbol: currency),
                      icon: Icons.trending_down,
                    ),
                    ReferenceStatCard(
                      title: "Net Profit",
                      value: formatMoney(expenseProv.netProfit, currencySymbol: currency),
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // ✅ Filters
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: InputDecoration(
                        hintText: "Search transactions...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<ExpenseType?>(
                      value: typeFilter,
                      underline: const SizedBox(),
                      hint: const Text("All Types"),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("All Types")),
                        DropdownMenuItem(
                          value: ExpenseType.income,
                          child: Text("Income"),
                        ),
                        DropdownMenuItem(
                          value: ExpenseType.expense,
                          child: Text("Expense"),
                        ),
                      ],
                      onChanged: (v) => setState(() => typeFilter = v),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ✅ Transactions List
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, prov, _) {
                  if (prov.isLoading) return const Center(child: CircularProgressIndicator());
                  
                  final filtered = prov.expenses.where((e) {
                    final matchesSearch = e.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                                        e.category.toLowerCase().contains(searchQuery.toLowerCase());
                    final matchesType = typeFilter == null || e.type == typeFilter;
                    return matchesSearch && matchesType;
                  }).toList();
                  
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No transactions found.", style: TextStyle(color: AppColors.textMuted)),
                    );
                  }
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.background),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final currency = context.read<SettingsProvider>().settings.currencySymbol;
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: e.type == ExpenseType.income 
                                  ? Colors.green.withValues(alpha: 0.1) 
                                  : Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              e.type == ExpenseType.income ? Icons.arrow_upward : Icons.arrow_downward,
                              color: e.type == ExpenseType.income ? Colors.green : Colors.red,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            "${e.category} • ${DateFormat('MMM d, yyyy').format(e.date)}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${e.type == ExpenseType.income ? '+' : '-'} ${formatMoney(e.amount, currencySymbol: currency)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: e.type == ExpenseType.income ? Colors.green : Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    e.description,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                onPressed: () => prov.deleteExpense(e.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double amount = 0;
  String category = 'Maintenance';
  String description = '';
  ExpenseType type = ExpenseType.expense;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final categories = settings.expenseCategories.isNotEmpty 
        ? settings.expenseCategories 
        : ['Rent', 'Electricity', 'Maintenance', 'Staff', 'Maintenance', 'Other'];

    return AlertDialog(
      title: const Text("Add Transaction"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Type Toggle
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => type = ExpenseType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: type == ExpenseType.expense ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                          border: Border.all(color: type == ExpenseType.expense ? Colors.red : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("Expense", style: TextStyle(color: type == ExpenseType.expense ? Colors.red : AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => type = ExpenseType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: type == ExpenseType.income ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                          border: Border.all(color: type == ExpenseType.income ? Colors.green : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("Income", style: TextStyle(color: type == ExpenseType.income ? Colors.green : AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                decoration: const InputDecoration(labelText: "Title (e.g. Month Rent)"),
                onSaved: (v) => title = v ?? '',
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                decoration: InputDecoration(labelText: "Amount (${settings.currencySymbol})"),
                keyboardType: TextInputType.number,
                onSaved: (v) => amount = double.tryParse(v ?? '') ?? 0,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? "Enter valid amount" : null,
              ),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                initialValue: categories.contains(category) ? category : categories.first,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                decoration: const InputDecoration(labelText: "Description (Optional)"),
                onSaved: (v) => description = v ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text("Save Transaction", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final expense = ExpenseModel(
        id: '',
        title: title,
        amount: amount,
        category: category,
        date: DateTime.now(),
        description: description,
        type: type,
      );
      context.read<ExpenseProvider>().addExpense(expense);
      Navigator.pop(context);
    }
  }
}
