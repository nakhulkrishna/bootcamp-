import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:gaming_center/core/utils/formatters.dart';
import 'package:gaming_center/app.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Future<void> _exportToPDF(ReportsProvider reports) async {
  final pdf = pw.Document();
  
  final totalRevenue = reports.totalRevenue;
  final totalExpenses = reports.totalExpenses;
  final netProfit = reports.netProfit;
  final expenses = reports.expenses.where((e) => e.type != 'income').toList();

  final monthlySummary = reports.getMonthlySummary();
  final consoleRevenue = reports.getConsoleRevenue();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          // Header
          pw.Container(
            padding: pw.EdgeInsets.only(bottom: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.purple),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Gaming Center - Financial Report',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Summary Section
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfSummaryItem('Total Revenue', totalRevenue.toStringAsFixed(2), PdfColors.green),
                _buildPdfSummaryItem('Total Expenses', totalExpenses.toStringAsFixed(2), PdfColors.red),
                _buildPdfSummaryItem('Net Profit', netProfit.toStringAsFixed(2), PdfColors.blue),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Monthly Breakdown
          pw.Text(
            'Monthly Revenue & Expenses',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          
  // Monthly Breakdown section in PDF
pw.TableHelper.fromTextArray(
  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
  headerDecoration: pw.BoxDecoration(color: PdfColors.purple),
  cellAlignment: pw.Alignment.centerLeft,
  cellPadding: pw.EdgeInsets.all(8),
  border: pw.TableBorder.all(color: PdfColors.grey400),
  headers: ['Month', 'Revenue', 'Expenses', 'Profit'],
  data: List.generate(12, (i) {
    final month = i + 1;
    final data = monthlySummary[month]!; // Now this will work correctly
    final profit = data['revenue']! - data['expense']!;
    
    return [
      DateFormat('MMMM').format(DateTime(0, month)),
      '₹${data['revenue']!.toStringAsFixed(2)}',
      '₹${data['expense']!.toStringAsFixed(2)}',
      '₹${profit.toStringAsFixed(2)}',
    ];
  }),
),
          pw.SizedBox(height: 30),

          // Console Revenue
          if (consoleRevenue.isNotEmpty) ...[
            pw.Text(
              'Revenue by Console',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColors.purple),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: pw.EdgeInsets.all(8),
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headers: ['Console Name', 'Revenue'],
              data: consoleRevenue.map((c) => [
                c.deviceName,
                c.revenue.toStringAsFixed(2),
              ]).toList(),
            ),
            pw.SizedBox(height: 30),
          ],

          // Expense Details
          pw.Text(
            'Detailed Expenses',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.purple),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: pw.EdgeInsets.all(8),
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headers: ['Date', 'Category', 'Description', 'Amount'],
            data: expenses.map((e) => [
              DateFormat('dd MMM yyyy').format(e.date),
              e.category,
              e.description,
              e.amount.toStringAsFixed(2),
            ]).toList(),
          ),
          
          // Footer
          pw.SizedBox(height: 40),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 10),
          pw.Text(
            'This report is system-generated and does not require a signature.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
          ),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
  
  // Show success message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generated successfully'),
        backgroundColor: Color(0xFF00B894),
      ),
    );
  }
}

pw.Widget _buildPdfSummaryItem(String label, String value, PdfColor color) {
  return pw.Column(
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );
}

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final from = DateTime(now.year, 1, 1);

    Future.microtask(() {
      if (!mounted) return;
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


  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final totalRevenue = reports.totalRevenue;
    final totalExpenses = reports.totalExpenses;
    final totalProfit = reports.netProfit;

    return Container(
      color: const Color(0xFFF3F4F6),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
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

                  /// RIGHT – INSIGHTS
                  Column(
                    children: [
                      SizedBox(
                        width: 360,
                        
                        child: _buildConsoleProfitList()),

                      SizedBox(height: 24),
                      SizedBox(
                        width: 360,
                        child: _buildGameProfitList(),
                      ),
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
  final reports = context.watch<ReportsProvider>();
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
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Financial overview and expense tracking',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      Row(
        children: [
          _buildActionButton(
            icon: Icons.receipt_long,
            label: 'Transactions',
            color: AppColors.primary,
            onTap: () =>
                context.read<NavigationProvider>().setSection(AppSection.expenses),
          ),
          SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.download,
            label: 'Export',
            color: AppColors.success,
               onTap: () {
   
              _exportToPDF(reports);
            },
          ),
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
              color: color.withValues(alpha: 0.3),
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
      final currency = context.watch<SettingsProvider>().settings.currencySymbol;
    return Row(
      children: [
        Expanded(
          child: ReferenceStatCard(
            title: "Total Revenue",
            value: formatMoney(revenue, currencySymbol: currency),
            icon: Icons.trending_up,
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: ReferenceStatCard(
            title: "Total Expenses",
            value: formatMoney(expenses, currencySymbol: currency),
            icon: Icons.trending_down,
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: ReferenceStatCard(
            title: "Net Profit",
            value: formatMoney(profit, currencySymbol: currency),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }


  Widget _buildProfitChart() {
    final reports = context.watch<ReportsProvider>();
    final revenueByDay = reports.getDailyRevenue();
    final expenseByDay = _getDailyExpenses(reports);

    // Show last 14 days for a clearer daily view
    final now = DateTime.now();
    final days = List.generate(
      14,
      (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 13 - i)),
    );

    double maxValue = 0;
    for (final d in days) {
      final rev = revenueByDay[_dateOnly(d)] ?? 0;
      final exp = expenseByDay[_dateOnly(d)] ?? 0;
      if (rev > maxValue) maxValue = rev;
      if (exp > maxValue) maxValue = exp;
    }
    maxValue = maxValue <= 0 ? 1000 : maxValue * 1.2;

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Revenue & Expenses (Last 14 Days)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue,
                barGroups: List.generate(days.length, (index) {
                  final day = days[index];
                  final key = _dateOnly(day);
                  final revenue = revenueByDay[key] ?? 0;
                  final expense = expenseByDay[key] ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: AppColors.success,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: expense,
                        color: AppColors.error,
                        width: 12,
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final day = days[index];
                        final label = DateFormat('d').format(day);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textMuted,
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
                        style: const TextStyle(color: AppColors.textMuted),
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
                      FlLine(color: AppColors.border, strokeWidth: 1),
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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, double> _getDailyExpenses(ReportsProvider reports) {
    final Map<DateTime, double> expenseByDate = {};

    for (final e in reports.expenses.where((e) => e.type != 'income')) {
      final dateOnly = _dateOnly(e.date);
      expenseByDate.update(
        dateOnly,
        (value) => value + e.amount,
        ifAbsent: () => e.amount,
      );
    }

    return expenseByDate;
  }


  Widget _buildExpenseBreakdownChart() {
    final expenses = context
        .watch<ReportsProvider>()
        .expenses
        .where((e) => e.type != 'income')
        .toList();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              color: AppColors.textPrimary,
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
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(
              amount,
              style: TextStyle(
                color: AppColors.textPrimary,
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

Widget _buildConsoleProfitList() {
  final items = context.watch<ReportsProvider>().getConsoleRevenue();
  
  if (items.isEmpty) {
    return const Text(
      'No session data available',
      style: TextStyle(color: AppColors.textMuted),
    );
  }
  
  return Container(
    padding: const EdgeInsets.all(24),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Revenue by Console',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      formatMoney(
                        c.revenue,
                        currencySymbol: context.read<SettingsProvider>().settings.currencySymbol,
                      ),
                      style: const TextStyle(
                        color: AppColors.success,
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


  Widget _buildGameProfitList() {
    final reports = context.watch<ReportsProvider>();
    final profits = reports.getGameRevenue();

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue by Game',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (profits.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No game data",
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profits.length > 5 ? 5 : profits.length,
              separatorBuilder: (context, index) => const Divider(color: AppColors.border),
              itemBuilder: (context, index) {
                final p = profits[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.gameName,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      Text(
                        formatMoney(
                          p.revenue,
                          currencySymbol: context.read<SettingsProvider>().settings.currencySymbol,
                        ),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}



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
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
