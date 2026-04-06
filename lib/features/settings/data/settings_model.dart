class SettingsModel {
  /// pricing structure: { 'Standard': { '1800': 100 }, 'VR': { '1800': 200 } }
  final Map<String, Map<String, int>> pricing; 
  final String currencySymbol;
  final String shopName;
  final List<String> expenseCategories;
  final bool enableAlarm;
  final int warningThreshold; // minutes before session ends

  SettingsModel({
    required this.pricing,
    this.currencySymbol = '₹',
    this.shopName = 'Gaming Center',
    this.expenseCategories = const ['Rent', 'Electricity', 'Maintenance', 'Staff', 'Other'],
    this.enableAlarm = true,
    this.warningThreshold = 5,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    final rawPricing = map['pricing'] as Map<String, dynamic>? ?? {};
    
    Map<String, Map<String, int>> processedPricing = {};

    if (rawPricing.isNotEmpty) {
      final firstValue = rawPricing.values.first;
      if (firstValue is int) {
        // Legacy format: { '1800': 100 }
        processedPricing['Standard'] = rawPricing.map((key, value) => MapEntry(key, value as int));
        processedPricing['VR'] = {}; // Initialize empty VR pricing
      } else if (firstValue is Map) {
        // New format: { 'Standard': { '1800': 100 } }
        rawPricing.forEach((category, categoryPricing) {
          if (categoryPricing is Map) {
            processedPricing[category] = (categoryPricing as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value as int));
          }
        });
      }
    }

    // Ensure defaults if empty
    if (processedPricing.isEmpty) {
      processedPricing = {
        'Standard': {'1800': 100, '3600': 150, '7200': 200},
        'VR': {'1800': 200, '3600': 350},
        'Car Racing': {'1800': 250, '3600': 450},
      };
    } else {
      // Ensure 'Car Racing' exists even if other categories were found
      if (!processedPricing.containsKey('Car Racing')) {
        processedPricing['Car Racing'] = {'1800': 250, '3600': 450};
      }
      if (!processedPricing.containsKey('VR')) {
        processedPricing['VR'] = {'1800': 200, '3600': 350};
      }
    }

    return SettingsModel(
      pricing: processedPricing,
      currencySymbol: map['currencySymbol'] ?? '₹',
      shopName: map['shopName'] ?? 'Gaming Center',
      expenseCategories: List<String>.from(map['expenseCategories'] ?? ['Rent', 'Electricity', 'Maintenance', 'Staff', 'Other']),
      enableAlarm: map['enableAlarm'] ?? true,
      warningThreshold: map['warningThreshold'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pricing': pricing,
      'currencySymbol': currencySymbol,
      'shopName': shopName,
      'expenseCategories': expenseCategories,
      'enableAlarm': enableAlarm,
      'warningThreshold': warningThreshold,
    };
  }

  SettingsModel copyWith({
    Map<String, Map<String, int>>? pricing,
    String? currencySymbol,
    String? shopName,
    List<String>? expenseCategories,
    bool? enableAlarm,
    int? warningThreshold,
  }) {
    return SettingsModel(
      pricing: pricing ?? this.pricing,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      shopName: shopName ?? this.shopName,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      enableAlarm: enableAlarm ?? this.enableAlarm,
      warningThreshold: warningThreshold ?? this.warningThreshold,
    );
  }
}
