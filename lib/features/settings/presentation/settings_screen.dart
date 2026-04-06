import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/core/utils/firestore_reset.dart';
import '../../../core/constants/colors.dart';
import '../data/settings_model.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _newDurationController = TextEditingController(); // in minutes
  final TextEditingController _newAmountController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _resetConfirmController = TextEditingController();
  String _selectedCategory = 'Standard';

  @override
  void initState() {
    super.initState();
    final SettingsModel settings = context.read<SettingsProvider>().settings;
    _shopNameController.text = settings.shopName;
    _currencyController.text = settings.currencySymbol;
  }

  void _saveGeneralSettings() {
    final provider = context.read<SettingsProvider>();
    final newSettings = provider.settings.copyWith(
      shopName: _shopNameController.text.trim(),
      currencySymbol: _currencyController.text.trim(),
    );
    provider.updateSettings(newSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("General settings saved")),
    );
  }

  void _addPricingPair() {
    final durationMin = int.tryParse(_newDurationController.text);
    final amount = int.tryParse(_newAmountController.text);

    if (durationMin != null && amount != null) {
      final provider = context.read<SettingsProvider>();
      final newPricing = Map<String, Map<String, int>>.from(provider.settings.pricing);
      
      final categoryPricing = Map<String, int>.from(newPricing[_selectedCategory] ?? {});
      final seconds = durationMin * 60;
      categoryPricing[seconds.toString()] = amount;
      
      newPricing[_selectedCategory] = categoryPricing;
      
      provider.updateSettings(provider.settings.copyWith(pricing: newPricing));
      _newDurationController.clear();
      _newAmountController.clear();
    }
  }

  void _removePricingPair(String secondsKey) {
    final provider = context.read<SettingsProvider>();
    final newPricing = Map<String, Map<String, int>>.from(provider.settings.pricing);
    
    final categoryPricing = Map<String, int>.from(newPricing[_selectedCategory] ?? {});
    categoryPricing.remove(secondsKey);
    
    newPricing[_selectedCategory] = categoryPricing;
    
    provider.updateSettings(provider.settings.copyWith(pricing: newPricing));
  }

  void _addCategory() {
    final cat = _newCategoryController.text.trim();
    if (cat.isNotEmpty) {
      final provider = context.read<SettingsProvider>();
      final cats = List<String>.from(provider.settings.expenseCategories);
      if (!cats.contains(cat)) {
        cats.add(cat);
        provider.updateSettings(provider.settings.copyWith(expenseCategories: cats));
      }
      _newCategoryController.clear();
    }
  }

  void _removeCategory(String cat) {
    final provider = context.read<SettingsProvider>();
    final cats = List<String>.from(provider.settings.expenseCategories);
    cats.remove(cat);
    provider.updateSettings(provider.settings.copyWith(expenseCategories: cats));
  }

  void _toggleAlarm(bool value) {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings(provider.settings.copyWith(enableAlarm: value));
  }

  void _updateThreshold(double value) {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings(provider.settings.copyWith(warningThreshold: value.toInt()));
  }

  void _showResetDialog() {
    _resetConfirmController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canDelete = _resetConfirmController.text.trim().toUpperCase() == 'RESET';
            return AlertDialog(
              title: const Text('Reset All Data'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will permanently delete all devices, sessions, games, expenses, and settings.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Type RESET to confirm.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _resetConfirmController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'RESET',
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canDelete
                      ? () async {
                          Navigator.pop(context);
                          try {
                            await FirestoreResetService.wipeAllData();
                            if (!context.mounted) return;
                            await context.read<SettingsProvider>().loadSettings();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All data cleared. App reset complete.'),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reset failed. Please try again.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete All Data'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final pricingCount = settings.pricing.length;

    final alarmStatus = settings.enableAlarm ? "On" : "Off";

    return Container(
      color: const Color(0xFFF3F4F6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Application Settings",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Configure your gaming center rules, pricing, and preferences.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ReferenceStatCard(
                    title: "Store Name",
                    value: settings.shopName.isEmpty ? "Not set" : settings.shopName,
                    icon: Iconsax.shop,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ReferenceStatCard(
                    title: "Pricing Pairs",
                    value: pricingCount.toString(),
                    icon: Iconsax.money_3,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ReferenceStatCard(
                    title: "Alarm Status",
                    value: alarmStatus,
                    icon: Iconsax.notification,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: [
                    _buildCard(
                      title: "Store Configuration",
                      icon: Iconsax.shop,
                      children: [
                        _buildTextField("Shop Name", _shopNameController, "e.g. Pro Gaming Center"),
                        const SizedBox(height: 20),
                        _buildTextField("Currency Symbol", _currencyController, "e.g. ₹ or \$"),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _saveGeneralSettings,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            child: const Center(
                              child: Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildCard(
                      title: "Notifications",
                      icon: Iconsax.notification,
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, prov, _) {
                            return Column(
                              children: [
                                SwitchListTile(
                                  title: const Text("End Session Alarm", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  subtitle: const Text("Play a sound when a timer hits zero.", style: TextStyle(fontSize: 12)),
                                  value: prov.settings.enableAlarm,
                                  onChanged: _toggleAlarm,
                                  activeThumbColor: AppColors.primary,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                const Divider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Warning Threshold: ${prov.settings.warningThreshold}m", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    const Text("Notify before session ends.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Slider(
                                      value: prov.settings.warningThreshold.toDouble(),
                                      min: 1,
                                      max: 15,
                                      divisions: 14,
                                      label: "${prov.settings.warningThreshold}m",
                                      onChanged: _updateThreshold,
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDangerCard(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              
              // Right Column
              Expanded(
                child: Column(
                  children: [
                    _buildCard(
                      title: "Custom Pricing Models",
                      icon: Iconsax.money_3,
                      children: [
                        Row(
                          children: [
                            _buildCategoryTab("Standard"),
                            const SizedBox(width: 12),
                            _buildCategoryTab("VR"),
                            const SizedBox(width: 12),
                            _buildCategoryTab("Car Racing"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text("Current $_selectedCategory Pricing Pairs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Consumer<SettingsProvider>(
                          builder: (context, provider, _) {
                            final categoryPricing = provider.settings.pricing[_selectedCategory] ?? {};
                            final sortedKeys = categoryPricing.keys.toList()
                              ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                            
                            if (sortedKeys.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text("No pricing pairs for this category.", style: TextStyle(color: AppColors.textMuted))),
                              );
                            }

                            return Column(
                              children: sortedKeys.map((key) {
                                final duration = int.parse(key);
                                final amount = categoryPricing[key];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.timer_1, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 12),
                                      Text("${duration ~/ 60} mins", style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Text("${provider.settings.currencySymbol}$amount", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        onPressed: () => _removePricingPair(key),
                                        icon: const Icon(Iconsax.trash, size: 20, color: AppColors.error),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const Divider(height: 48),
                        Text("Add New $_selectedCategory Pricing Pair", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField("Duration (min)", _newDurationController, "30")),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField("Amount", _newAmountController, "100")),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: ElevatedButton(
                                onPressed: _addPricingPair,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Icon(Iconsax.add),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildCard(
                      title: "Expense Categories",
                      icon: Iconsax.category,
                      children: [
                        const Text("Manage categories for your expenses.", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        Consumer<SettingsProvider>(
                          builder: (context, prov, _) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: prov.settings.expenseCategories.map((cat) => Chip(
                                label: Text(cat),
                                onDeleted: () => _removeCategory(cat),
                                deleteIconColor: AppColors.error,
                                backgroundColor: AppColors.surfaceLight,
                              )).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField("New Category", _newCategoryController, "Electricity")),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: ElevatedButton(
                                onPressed: _addCategory,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Icon(Iconsax.add),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(28),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
          Row(
            children: const [
              Icon(Iconsax.warning_2, color: AppColors.error, size: 20),
              SizedBox(width: 10),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Reset the app to a fresh state by removing all backend data.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showResetDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Reset All Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Color.fromRGBO(0, 0, 0, 0),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
