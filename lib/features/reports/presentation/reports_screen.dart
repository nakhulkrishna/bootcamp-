import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gaming_center/features/reports/data/expenses_model.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
// import 'package:excel/excel.dart' as excel_pkg;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final from = DateTime(now.year, 1, 1);

    Future.microtask(() {
      context.read<ReportsProvider>().loadReports(from: from, to: now);
    });
  }

  String selectedPeriod = 'This Month';
  final List<String> periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];

  // Sample data - Replace with your provider data
  // final List<ExpenseEntry> expenses = [
  //   ExpenseEntry(
  //     date: DateTime.now().subtract(Duration(days: 5)),
  //     category: 'Electricity',
  //     amount: 1500,
  //     description: 'Monthly bill',
  //   ),
  //   ExpenseEntry(
  //     date: DateTime.now().subtract(Duration(days: 10)),
  //     category: 'WiFi',
  //     amount: 800,
  //     description: 'Internet subscription',
  //   ),
  //   ExpenseEntry(
  //     date: DateTime.now().subtract(Duration(days: 15)),
  //     category: 'Console Maintenance',
  //     amount: 2500,
  //     description: 'PS5 controller repair',
  //   ),
  //   ExpenseEntry(
  //     date: DateTime.now().subtract(Duration(days: 20)),
  //     category: 'Rent',
  //     amount: 15000,
  //     description: 'Shop rent',
  //   ),
  // ];
  // final List<Map<String, double>> monthlyData = [
  //   {'revenue': 35000, 'expense': 18000},
  //   {'revenue': 42000, 'expense': 19500},
  //   {'revenue': 38000, 'expense': 21000},
  //   {'revenue': 45000, 'expense': 19800},
  //   {'revenue': 40000, 'expense': 22000},
  //   {'revenue': 48000, 'expense': 20000},
  // ];

  // final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final totalRevenue = reports.totalRevenue;
    final totalExpenses = reports.totalExpenses;
    final totalProfit = reports.netProfit;

    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildSummaryCards(totalRevenue, totalExpenses, totalProfit),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT – MAIN CONTENT
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        SizedBox(height: 380, child: _buildProfitChart()),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 390,
                          child: _buildExpenseBreakdownChart(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  /// RIGHT – ACTIONABLE LIST
                  Column(
                    children: [
                      SizedBox(
                        width: 360,
                        height: 380,
                        child: _buildExpensesList(reports.expenses),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: 360,
                        
                        child: _buildConsoleProfitList()),
                    ],
                  ),
                ],
              ),
              // Expanded(
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Expanded(
              //         flex: 2,
              //         child: Column(
              //           children: [
              //             Expanded(child: _buildProfitChart()),
              //             SizedBox(height: 16),
              //             Expanded(child: _buildExpenseBreakdownChart()),
              //           ],
              //         ),
              //       ),
              //       SizedBox(width: 16),
              //       Expanded(
              //         flex: 1,
              //         child: _buildExpensesList(),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Financial overview and expense tracking',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
        
            _buildActionButton(
              icon: Icons.add,
              label: 'Add Expense',
              color: Color(0xFF6C5CE7),
              onTap: () => _showAddExpenseDialog(),
            ),
            SizedBox(width: 12),
            // _buildActionButton(
            //   icon: Icons.download,
            //   label: 'Export',
            //   color: Color(0xFF00B894),
            //   onTap: () => _showExportOptions(),
            // ),
          ],
        ),
      ],
    );
  }


  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, double expenses, double profit) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            '₹${revenue.toStringAsFixed(0)}',
            Icons.trending_up,
            Color(0xFF00B894),
            '+12.5%',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Expenses',
            '₹${expenses.toStringAsFixed(0)}',
            Icons.trending_down,
            Color(0xFFFF7675),
            '+8.3%',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Net Profit',
            '₹${profit.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Color(0xFF6C5CE7),
            profit > 0
                ? '+${((profit / revenue) * 100).toStringAsFixed(1)}%'
                : '0%',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitChart() {
    final reports = context.watch<ReportsProvider>();
    final monthlySummary = reports.getMonthlySummary();

    // Convert map to list (Jan → Dec)
    final months = List.generate(12, (i) => i + 1);

    final maxValue =
        monthlySummary.values
            .expand((e) => [e['revenue']!, e['expense']!])
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Revenue & Expense',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue <= 0 ? 1000 : maxValue,
                barGroups: List.generate(months.length, (index) {
                  final m = months[index];
                  final data = monthlySummary[m]!;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 6,
                    barRods: [
                      /// ✅ REVENUE
                      BarChartRodData(
                        toY: data['revenue']!,
                        color: const Color(0xFF00B894),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),

                      /// ✅ EXPENSE
                      BarChartRodData(
                        toY: data['expense']!,
                        color: const Color(0xFFFF7675),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = DateFormat(
                          'MMM',
                        ).format(DateTime(0, value.toInt() + 1));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            month,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, _) => Text(
                        '₹${(value ~/ 1000)}k',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(label: 'Revenue', color: Color(0xFF00B894)),
              SizedBox(width: 24),
              _Legend(label: 'Expenses', color: Color(0xFFFF7675)),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double revenue, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: revenue,
          color: Color(0xFF00B894),
          width: 16,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expense,
          color: Color(0xFFFF7675),
          width: 16,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildExpenseBreakdownChart() {
    final expenses = context.watch<ReportsProvider>().expenses;

    // ✅ Group expenses by category
    final Map<String, double> grouped = {};
    double total = 0;

    for (final e in expenses) {
      grouped[e.category] = (grouped[e.category] ?? 0) + e.amount;
      total += e.amount;
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                /// ✅ PIE
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      sections: grouped.entries.map((entry) {
                        final percent = (entry.value / total) * 100;

                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percent.toStringAsFixed(1)}%',
                          radius: 60,
                          color: _colorForCategory(entry.key),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                /// ✅ LEGEND (AUTO)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grouped.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildExpenseCategory(
                        entry.key,
                        '₹${entry.value.toStringAsFixed(0)}',
                        _colorForCategory(entry.key),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategory(String label, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(
              amount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return const Color(0xFF6C5CE7);
      case 'maintenance':
        return const Color(0xFF00B894);
      case 'electricity':
        return const Color(0xFFFF7675);
      case 'wifi':
        return const Color(0xFFFDCB6E);
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildExpensesList(List<ExpenseEntry> expense) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF6C5CE7).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.white54),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: expense.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.white10, height: 24),
              itemBuilder: (context, index) {
                final expenses = expense[index];
                return _buildExpenseItem(expenses);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseEntry expense) {
    final categoryColors = {
      'Electricity': Color(0xFFFF7675),
      'WiFi': Color(0xFFFDCB6E),
      'Console Maintenance': Color(0xFF00B894),
      'Rent': Color(0xFF6C5CE7),
    };

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (categoryColors[expense.category] ?? Color(0xFF6C5CE7))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: categoryColors[expense.category] ?? Color(0xFF6C5CE7),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.category,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                expense.description,
                style: TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${expense.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: Color(0xFFFF7675),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('MMM dd').format(expense.date),
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electricity':
        return Icons.bolt;
      case 'WiFi':
        return Icons.wifi;
      case 'Console Maintenance':
        return Icons.build;
      case 'Rent':
        return Icons.home;
      default:
        return Icons.receipt;
    }
  }

  void _showAddExpenseDialog() {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Expense', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final category = categoryController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              final description = descriptionController.text.trim();

              if (category.isEmpty || amount <= 0) return;

              context.read<ReportsProvider>().addExpense(
                category: category,
                amount: amount,
                description: description,
              );

              Navigator.pop(context);
            },

            child: Text('Add Expense'),
          ),
        ],
      ),
    );
  }

Widget _buildConsoleProfitList() {
  final items = context.watch<ReportsProvider>().getConsoleRevenue();
  
  if (items.isEmpty) {
    return const Text(
      'No session data available',
      style: TextStyle(color: Colors.white54),
    );
  }
  
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1F3A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue by Console',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Make the list scrollable with a max height
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 300, // Adjust this height as needed
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final c = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.deviceName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '₹${c.revenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF00B894),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
  // void _showExportOptions() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Color(0xFF1A1F3A),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Text('Export Report', style: TextStyle(color: Colors.white)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: Icon(Icons.picture_as_pdf, color: Color(0xFFFF7675)),
  //             title: Text(
  //               'Export as PDF',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _exportToPDF();
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.table_chart, color: Color(0xFF00B894)),
  //             title: Text(
  //               'Export as Excel',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _exportToExcel();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _exportToPDF() async {
  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text(
  //               'Gaming Center - Financial Report',
  //               style: pw.TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Text('Period: $selectedPeriod'),
  //             pw.SizedBox(height: 20),
  //             pw.Text('Revenue: ₹45,000', style: pw.TextStyle(fontSize: 16)),
  //             pw.Text('Expenses: ₹19,800', style: pw.TextStyle(fontSize: 16)),
  //             pw.Text(
  //               'Net Profit: ₹25,200',
  //               style: pw.TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //             ),
  //             pw.SizedBox(height: 30),
  //             pw.Text(
  //               'Expense Details:',
  //               style: pw.TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //             ),
  //             pw.SizedBox(height: 10),
  //             ...expenses.map(
  //               (e) =>
  //                   pw.Text('${e.category}: ₹${e.amount} - ${e.description}'),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }

  Future<void> _exportToExcel() async {
    // var excel = excel_pkg.Excel.createExcel();
    // var sheet = excel['Report'];

    // // Headers
    // sheet.appendRow(['Category', 'Amount', 'Description', 'Date']);

    // // Data
    // for (var expense in expenses) {
    //   sheet.appendRow([
    //     expense.category,
    //     expense.amount,
    //     expense.description,
    //     DateFormat('yyyy-MM-dd').format(expense.date),
    //   ]);
    // }

    // // Save file
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/gaming_center_report.xlsx');
    // await file.writeAsBytes(excel.encode()!);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Excel file saved to ${file.path}')),
    // );
  }
}

// class ExpenseEntry {
//   final DateTime date;
//   final String category;
//   final double amount;
//   final String description;

//   ExpenseEntry({
//     required this.date,
//     required this.category,
//     required this.amount,
//     required this.description,
//   });
// }

class _Legend extends StatelessWidget {
  final String label;
  final Color color;

  const _Legend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
