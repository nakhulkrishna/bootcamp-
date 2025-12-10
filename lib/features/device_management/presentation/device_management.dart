import 'package:flutter/material.dart';

import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/widget/widgets.dart';
import 'package:gaming_center/shared/providers/console_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final consoleProvider = context.watch<DeviceProvider>();
    final devices = consoleProvider.devices;
    final isLoading = consoleProvider.loading;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Device Management",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${devices.length} devices active",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AddConsoleDialog(),
                  );
                },
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
                        color: AppColors.primary.withOpacity(0.3),
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
                        "Add Device",
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
          const SizedBox(height: 24),

          // Table Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell("Device", flex: 2),
                        _buildHeaderCell("Available Games", flex: 5),
                        // _buildHeaderCell("Timer", flex: 2),
                        // _buildHeaderCell("Payment", flex: 2),
                        // _buildHeaderCell("Status", flex: 2),
                        _buildHeaderCell("Actions", flex: 2),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.primary.withOpacity(0.1),
                  ),

                  // Table Body
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemCount: devices.length,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isHovered = hoveredIndex == index;

                        return MouseRegion(
                          onEnter: (_) => setState(() => hoveredIndex = index),
                          onExit: (_) => setState(() => hoveredIndex = null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: isHovered
                                  ? AppColors.primary.withOpacity(0.03)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                _buildDeviceCell(device.name, isHovered),
                                _buildAvailableGamesCell(device.availableGames),
                                // _buildTimerCell(formatTimer(device), isHovered),
                                // _buildPaymentCell(
                                //   device.paymentMethod ?? "Google Pay",
                                //   isHovered,
                                // ),
                                // _buildStatusCell(device.isPaid, isHovered),
                                // SizedBox(width: 5),
                                _buildActionsCell(isHovered, device),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDeviceCell(String name, bool isHovered) {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.videogame_asset,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCell(String game, bool isHovered) {
    final isFree = game.toLowerCase() == "free";
    return Expanded(
      flex: 3,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFree
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFree
                    ? Colors.green.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              game,
              style: TextStyle(
                color: isFree ? Colors.green : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableGamesCell(List<String> games) {
    return Expanded(
      flex: 5,
      child: Align(
        alignment: Alignment.centerLeft,
        child: games.isEmpty
            ? Text(
                "No games",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 6,
                children: games.map((game) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      game,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildTimerCell(String time, bool isHovered) {
    final isActive = time != "-";
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          if (isActive)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          Text(
            time,
            style: TextStyle(
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCell(String method, bool isHovered) {
    return Expanded(
      flex: 2,
      child: Text(
        method,
        style: TextStyle(
          color: method == "-" ? AppColors.textMuted : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStatusCell(bool isPaid, bool isHovered) {
    return Expanded(
      flex: 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPaid
              ? Colors.green.withOpacity(isHovered ? 0.15 : 0.1)
              : Colors.orange.withOpacity(isHovered ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPaid
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              color: isPaid ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isPaid ? "Paid" : "Pending",
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(bool isHovered, DeviceModel device) {
    // final isRunning = device.status == DeviceStatus.running;

    return Expanded(
      flex: 2,
      child: Row(
        children: [
          // // ▶️ START
          // _buildActionButton(
          //   icon: Icons.play_arrow,
          //   color: Colors.green,
          //   isHovered: isHovered,
          //   onTap: isRunning
          //       ? null
          //       : () {
          //           showDialog(
          //             context: context,
          //             builder: (_) => StartSessionDialog(device: device),
          //           );
          //         },
          // ),

          // const SizedBox(width: 8),

          // // ⏹ STOP
          // _buildActionButton(
          //   icon: Icons.stop,
          //   color: Colors.red,
          //   isHovered: isHovered,
          //   // onTap: isRunning
          //   //     ? () {
          //   //         context
          //   //             .read<DeviceProvider>()
          //   //             .stopSession(device.id);
          //   //       }
          //   //     : null,
          // ),

          const SizedBox(width: 8),

          // ✏️ EDIT
          _buildActionButton(
            icon: Icons.edit,
            color: AppColors.primary,
            isHovered: isHovered,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => EditConsoleDialog(device: device),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required bool isHovered,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHovered ? color.withOpacity(0.15) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(isHovered ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
