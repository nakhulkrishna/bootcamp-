import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/shared/providers/console_provider.dart';

class PaymentStatusChip extends StatelessWidget {
  final bool isPaid;

  const PaymentStatusChip({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withOpacity(0.15)
            : AppColors.warning.withOpacity(0.15),
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
          icon: Icons.stop_circle,
          color: AppColors.primary,
          tooltip: "Stop Session",
        ),
        const SizedBox(width: 8),
        IconBtn(
          icon: Icons.build,
          color: AppColors.warning,
          tooltip: "Maintenance",
        ),
        const SizedBox(width: 8),
        IconBtn(
          icon: Icons.delete,
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
            color: color.withOpacity(0.15),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameController = TextEditingController();

  final List<String> _availableGames = [];
  bool _saving = false;

  void _addGame() {
    final game = _gameController.text.trim();
    if (game.isEmpty) return;

    setState(() {
      _availableGames.add(game);
      _gameController.clear();
    });
  }

  Future<void> _saveConsole() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _saving = true);

    final device = DeviceModel(
      id: '',
      name: _nameController.text.trim(),
      status: DeviceStatus.free,
      availableGames: _availableGames,
    );

    await context.read<DeviceProvider>().addDevice(device);

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Title
              const Text(
                "Add Console",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Console name
              _input(
                controller: _nameController,
                label: "Console Name (e.g. PS-01)",
              ),

              const SizedBox(height: 16),

              // ✅ Add games
              Row(
                children: [
                  Expanded(
                    child: _input(
                      controller: _gameController,
                      label: "Add Available Game",
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addGame,
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Games list
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableGames
                    .map(
                      (game) => Chip(
                        label: Text(game),
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _availableGames.remove(game));
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 28),

              //  Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveConsole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Add Console",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
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
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

String formatRemainingTime(SessionModel session) {
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
  
  // Pricing map
  final Map<int, int> _pricing = {
    1800: 100, 
    3600: 150,  
    7200: 200,  
  };

  @override
  void initState() {
    super.initState();
    if (widget.device.availableGames.isNotEmpty) {
      _game = widget.device.availableGames.first;
    }
  }

  // ✅ Get price for selected duration
  int get _selectedPrice => _pricing[_duration] ?? 0;

  Future<void> _start() async {
    log("function called");
    if (_game == null) return;
    setState(() => _loading = true);
    
    await context.read<SessionProvider>().startSession(
      device: widget.device,
      game: _game!,
      durationSeconds: _duration,
      paymentMethod: _paymentMethod,
      isPaid: _isPaid,
      price: _selectedPrice,  // ✅ Pass price to session
    );

    log("Session started with price: ₹$_selectedPrice");
    Navigator.pop(context);
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
                color: Colors.black.withOpacity(0.1),
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
                      AppColors.primary.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.2),
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
                              color: Colors.white.withOpacity(0.9),
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
                    // Duration Section
                    _buildSectionLabel("Select Duration & Pricing", Icons.schedule),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _timeChip(
                            "30 min",
                            1800,
                            Icons.timer,
                            "100",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _timeChip(
                            "1 hour",
                            3600,
                            Icons.hourglass_bottom,
                            "150",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _timeChip(
                            "2 hours",
                            7200,
                            Icons.hourglass_full,
                            "200",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Game Selection
                    _buildSectionLabel("Choose Game", Icons.sports_esports),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
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
                        onChanged: (v) => setState(() => _game = v),
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
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
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
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
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
                  color: AppColors.primary.withOpacity(0.03),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:  () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
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
          color: selected ? color.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
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
                    AppColors.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: selected ? null : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.15),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
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
                    ? Colors.white.withOpacity(0.2)
                    : Colors.green.withOpacity(0.1),
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
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
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

  String _getDurationText() {
    if (_duration == 1800) return "30 minutes";
    if (_duration == 3600) return "1 hour";
    if (_duration == 7200) return "2 hours";
    return "${_duration ~/ 60} minutes";
  }
}