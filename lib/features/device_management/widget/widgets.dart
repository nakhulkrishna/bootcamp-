import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/data/game_model.dart';
import 'package:gaming_center/features/device_management/providers/game_provider.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';

class PaymentStatusChip extends StatelessWidget {
  final bool isPaid;

  const PaymentStatusChip({super.key, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? "PAID" : "PENDING",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isPaid ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBtn(
          icon: Iconsax.stop_circle,
          color: AppColors.primary,
          tooltip: "Stop Session",
        ),
        const SizedBox(width: 8),
        IconBtn(
          icon: Iconsax.setting_2,
          color: AppColors.warning,
          tooltip: "Maintenance",
        ),
        const SizedBox(width: 8),
        IconBtn(
          icon: Iconsax.trash,
          color: AppColors.error,
          tooltip: "Delete Device",
        ),
      ],
    );
  }
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;

  const IconBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // TODO: handle action
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class AddConsoleDialog extends StatefulWidget {
  const AddConsoleDialog({super.key});

  @override
  State<AddConsoleDialog> createState() => _AddConsoleDialogState();
}

class _AddConsoleDialogState extends State<AddConsoleDialog> {
  int _currentStep = 0; // 0: Type Selection, 1: Configuration
  DeviceType? _selectedType;
  final TextEditingController _nameController = TextEditingController();
  int _quantity = 1;

  final List<String> _availableGames = [];
  bool _saving = false;

  String _getTypePrefix(DeviceType type) {
    switch (type) {
      case DeviceType.ps5:
        return "PS5";
      case DeviceType.ps4:
        return "PS4";
      case DeviceType.xboxSeriesX:
        return "XBX";
      case DeviceType.xboxSeriesS:
        return "XBS";
      case DeviceType.pc:
        return "PC";
      case DeviceType.nintendoSwitch:
        return "NSW";
      default:
        return "DEV";
    }
  }

  void _selectType(DeviceType type) {
    setState(() {
      _selectedType = type;
      _currentStep = 1;

      final prefix = _getTypePrefix(type);
      final existingCount = context
          .read<DeviceProvider>()
          .devices
          .where((d) => d.type == type)
          .length;
      _nameController.text =
          "$prefix-${(existingCount + 1).toString().padLeft(2, '0')}";
    });
  }

  void _showAddGlobalGameDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Global Game",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _input(controller: controller, label: "Game Name"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        final gameProv = context.read<GameProvider>();
                        final nav = Navigator.of(context);
                        await gameProv.addGame(name);
                        nav.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text("Add Game"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelector(List<GameModel> globalGames) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        hint: const Text("Select games",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.surface,
        items: globalGames.map((game) {
          final isSelected = _availableGames.contains(game.name);
          return DropdownMenuItem<String>(
            value: game.name,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(game.name,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            if (_availableGames.contains(val)) {
              _availableGames.remove(val);
            } else {
              _availableGames.add(val);
            }
          });
        },
      ),
    );
  }

  Future<void> _saveDevices() async {
    final baseName = _nameController.text.trim();
    if (baseName.isEmpty) return;

    setState(() => _saving = true);

    if (_quantity == 1) {
      final device = DeviceModel(
        id: '',
        name: baseName,
        status: DeviceStatus.free,
        type: _selectedType!,
        availableGames: _availableGames,
      );
      await context.read<DeviceProvider>().addDevice(device);
    } else {
      final List<DeviceModel> devices = [];
      final parts = baseName.split('-');
      final prefix = parts.length > 1 ? parts[0] : baseName;
      int startNum = 1;
      if (parts.length > 1) {
        startNum = int.tryParse(parts[1]) ?? 1;
      }

      for (int i = 0; i < _quantity; i++) {
        final currentNum = startNum + i;
        devices.add(DeviceModel(
          id: '',
          name: "$prefix-${currentNum.toString().padLeft(2, '0')}",
          status: DeviceStatus.free,
          type: _selectedType!,
          availableGames: _availableGames,
        ));
      }
      await context.read<DeviceProvider>().bulkAddDevices(devices);
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_currentStep == 1)
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left_2),
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                const SizedBox(width: 8),
                Text(
                  _currentStep == 0 ? "Select Platform" : "Configure Device",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_currentStep == 0)
              _buildTypeSelection()
            else
              _buildConfiguration(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _typeCard(DeviceType.ps5, "PS5", Iconsax.game),
        _typeCard(DeviceType.xboxSeriesX, "Xbox X", Iconsax.game),
        _typeCard(DeviceType.pc, "Gaming PC", Iconsax.monitor),
        _typeCard(DeviceType.nintendoSwitch, "Switch",
            Iconsax.game),
        _typeCard(DeviceType.ps4, "PS4", Iconsax.game),
        _typeCard(DeviceType.other, "Other", Iconsax.more_2),
      ],
    );
  }

  Widget _typeCard(DeviceType type, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _selectType(type),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _input(
                controller: _nameController,
                label: "Device Name / ID",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text("Qty:",
                        style: TextStyle(color: AppColors.textSecondary)),
                    Expanded(
                      child: DropdownButton<int>(
                        value: _quantity,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.surface,
                        items: [1, 2, 3, 4, 5, 10].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString(),
                                style: const TextStyle(
                                    color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _quantity = val!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Games List",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _showAddGlobalGameDialog,
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text("New Global Game"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return _buildGameSelector(gameProvider.games);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableGames
              .map((game) => Chip(
                    label: Text(game, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    deleteIcon: const Icon(Iconsax.close_circle, size: 14),
                    onDeleted: () =>
                        setState(() => _availableGames.remove(game)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveDevices,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white))
                : Text(_quantity > 1 ? "Add $_quantity Devices" : "Add Device",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class EditConsoleDialog extends StatefulWidget {
  const EditConsoleDialog({
    super.key,
    required this.device,
  });

  final DeviceModel device;

  @override
  State<EditConsoleDialog> createState() => _EditConsoleDialogState();
}

class _EditConsoleDialogState extends State<EditConsoleDialog> {
  late TextEditingController _nameController;
  late List<String> _availableGames;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _availableGames = List.from(widget.device.availableGames);
  }

  void _showAddGlobalGameDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Global Game",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _input(controller: controller, label: "Game Name"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        final gameProv = context.read<GameProvider>();
                        final nav = Navigator.of(context);
                        await gameProv.addGame(name, category: 'Standard');
                        nav.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text("Add Game"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelector(List<GameModel> globalGames) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        hint: const Text("Select games",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.surface,
        items: globalGames.map((game) {
          final isSelected = _availableGames.contains(game.name);
          return DropdownMenuItem<String>(
            value: game.name,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(game.name,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            if (_availableGames.contains(val)) {
              _availableGames.remove(val);
            } else {
              _availableGames.add(val);
            }
          });
        },
      ),
    );
  }

  Future<void> _saveConsole() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);

    final updatedDevice = widget.device.copyWith(
      name: name,
      availableGames: _availableGames,
    );

    context.read<DeviceProvider>().updateDevice(updatedDevice);

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 450,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Console",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Iconsax.close_circle, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _input(
                controller: _nameController,
                label: "Console Name",
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Games List",
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _showAddGlobalGameDialog,
                    icon: const Icon(Iconsax.add, size: 18),
                    label: const Text("New Global Game"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return _buildGameSelector(gameProvider.games);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableGames
                    .map((game) => Chip(
                          label:
                              Text(game, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          deleteIcon: const Icon(Iconsax.close_circle, size: 14),
                          onDeleted: () =>
                              setState(() => _availableGames.remove(game)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveConsole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Update Console",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}


String formatRemainingTime(SessionModel session) {
  if (session.endTime == null) {
    final elapsed = Duration(seconds: session.elapsedSeconds);
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds (Open)";
  }

  final duration = remaining(session);

  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return "$hours:$minutes:$seconds";
}

class StartSessionDialog extends StatefulWidget {
  final DeviceModel device;

  const StartSessionDialog({super.key, required this.device});

  @override
  State<StartSessionDialog> createState() => _StartSessionDialogState();
}

Duration remaining(SessionModel s) {
  if (s.endTime == null) {
    return Duration.zero;
  }

  final end = DateTime.fromMillisecondsSinceEpoch(s.endTime!);
  final now = DateTime.now();

  final diff = end.difference(now);
  return diff.isNegative ? Duration.zero : diff;
}

class _StartSessionDialogState extends State<StartSessionDialog> {
  int _duration = 1800;
  String? _game;
  String _paymentMethod = "GPay";
  bool _loading = false;
  bool _isPaid = false;
  String _selectedCategory = "Standard";

  String _deriveCategory(String? gameName) {
    if (gameName == null) return "Standard";
    final games = context.read<GameProvider>().games;
    final gameModel = games.firstWhere(
      (g) => g.name == gameName,
      orElse: () => GameModel(id: '', name: '', category: 'Standard'),
    );
    return gameModel.category;
  }

  @override
  void initState() {
    super.initState();
    if (widget.device.availableGames.isNotEmpty) {
      _game = widget.device.availableGames.first;
      _selectedCategory = _deriveCategory(_game);
    }

    // Set default duration to the first available pricing option if 1800 is not in settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pricing =
          context.read<SettingsProvider>().settings.pricing[_selectedCategory] ??
              {};
      if (pricing.isNotEmpty && !pricing.containsKey(_duration.toString())) {
        final sortedKeys = pricing.keys.toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        setState(() {
          _duration = int.parse(sortedKeys.first);
        });
      }
    });
  }

  // ✅ Get price for selected duration
  int get _selectedPrice {
    final pricing =
        context.read<SettingsProvider>().settings.pricing[_selectedCategory] ??
            {};
    return (pricing[_duration.toString()] ?? 0);
  }

  Future<void> _start() async {
    if (_game == null) return;
    setState(() => _loading = true);

    await context.read<SessionProvider>().startSession(
          device: widget.device,
          game: _game!,
          durationSeconds: _duration,
          paymentMethod: _paymentMethod,
          isPaid: _isPaid,
          price: _selectedPrice,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Start Gaming Session",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.device.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pricing Category Selection
                    _buildSectionLabel("Pricing Mode", Icons.category),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _categoryOption("Standard", Icons.sports_esports),
                        const SizedBox(width: 8),
                        _categoryOption("VR", Icons.visibility),
                        const SizedBox(width: 8),
                        _categoryOption("Car Racing", Icons.directions_car),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Duration Section
                    _buildSectionLabel(
                        "Select Duration & Pricing", Icons.schedule),
                    const SizedBox(height: 12),
                    Consumer<SettingsProvider>(
                      builder: (context, settingsProvider, _) {
                        final pricing = settingsProvider
                                .settings.pricing[_selectedCategory] ??
                            {};
                        if (pricing.isEmpty) {
                          return Center(
                              child: Text(
                                  "No pricing rules found for $_selectedCategory in settings."));
                        }

                        // Sort by duration (seconds)
                        final sortedKeys = pricing.keys.toList()
                          ..sort((a, b) =>
                              int.parse(a).compareTo(int.parse(b)));

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: sortedKeys.map((key) {
                            final seconds = int.parse(key);
                            final amount = pricing[key];
                            final minutes = seconds ~/ 60;

                            String label;
                            IconData icon;

                            if (seconds == 0) {
                              label = "Open Time";
                              icon = Icons.all_inclusive;
                            } else if (minutes < 60) {
                              label = "$minutes min";
                              icon = Icons.timer;
                            } else {
                              final hours = minutes / 60;
                              label = hours == hours.toInt()
                                  ? "${hours.toInt()} hour${hours > 1 ? 's' : ''}"
                                  : "${hours.toStringAsFixed(1)} hours";
                              icon = minutes >= 120
                                  ? Icons.hourglass_full
                                  : Icons.hourglass_bottom;
                            }

                            return SizedBox(
                              width: (450 - 64 - 24) / 3, // Roughly 3 columns
                              child: _timeChip(
                                label,
                                seconds,
                                icon,
                                amount.toString(),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Game Selection
                    _buildSectionLabel("Choose Game", Icons.sports_esports),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _game,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.gamepad,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        dropdownColor: AppColors.surface,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                        ),
                        items: widget.device.availableGames
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _game = v;
                            _selectedCategory = _deriveCategory(v);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method
                    _buildSectionLabel("Payment Method", Icons.payment),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _paymentMethodCard(
                            "GPay",
                            Icons.phone_android,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _paymentMethodCard(
                            "Cash",
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Status
                    _buildSectionLabel("Payment Status", Icons.verified),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _radioOption(
                            label: "Paid",
                            value: true,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _radioOption(
                            label: "Pending",
                            value: false,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ✅ Price Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.1),
                            Colors.green.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.currency_rupee,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹$_selectedPrice",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isPaid
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isPaid ? "PAID" : "PENDING",
                              style: TextStyle(
                                color: _isPaid ? Colors.green : Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.03),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _start,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Start Session",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryOption(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption({
    required String label,
    required bool value,
    required Color color,
  }) {
    final selected = _isPaid == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _isPaid = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? color.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            // ignore: deprecated_member_use
            Radio<bool>(
              value: value,
              groupValue: _isPaid,
              onChanged: (v) => setState(() => _isPaid = v!),
              activeColor: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ✅ Updated time chip with price
  Widget _timeChip(String label, int seconds, IconData icon, String price) {
    final selected = _duration == seconds;
    return GestureDetector(
      onTap: () => setState(() => _duration = seconds),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: selected ? null : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.primary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            // ✅ Price tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                price,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodCard(String method, IconData icon, Color color) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              method,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageGamesDialog extends StatefulWidget {
  const ManageGamesDialog({super.key});

  @override
  State<ManageGamesDialog> createState() => _ManageGamesDialogState();
}

class _ManageGamesDialogState extends State<ManageGamesDialog> {
  final TextEditingController _gameController = TextEditingController();
  String _category = 'Standard';

  void _addGame() async {
    final name = _gameController.text.trim();
    if (name.isNotEmpty) {
      await context.read<GameProvider>().addGame(name, category: _category);
      _gameController.clear();
      setState(() {
        _category = 'Standard';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 620,
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Global Game Library",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Add or remove titles available to all devices.",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _gameController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: "Enter game name",
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _categoryIconOption("Standard", Icons.sports_esports),
                              const SizedBox(width: 8),
                              _categoryIconOption("VR", Icons.visibility),
                              const SizedBox(width: 8),
                              _categoryIconOption("Car Racing", Icons.directions_car),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _addGame,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
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
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Global Games Collection",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Consumer<GameProvider>(
                    builder: (context, provider, child) {
                      if (provider.games.isEmpty) {
                        return const Center(
                          child: Text(
                            "No games added yet.",
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: provider.games.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.surfaceLight,
                        ),
                        itemBuilder: (context, index) {
                          final game = provider.games[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Text(
                                  game.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                if (game.category != 'Standard') ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      game.category.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              onPressed: () => provider.deleteGame(game.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryIconOption(String cat, IconData icon) {
    final isSelected = _category == cat;
    return InkWell(
      onTap: () => setState(() => _category = cat),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              cat,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
