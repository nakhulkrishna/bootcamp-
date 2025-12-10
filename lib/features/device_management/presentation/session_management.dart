import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/images.dart';
import 'dart:html' as html show AudioElement;
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/device_management/widget/widgets.dart';
import 'package:gaming_center/shared/providers/console_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';

class SessionManagement extends StatefulWidget {
  const SessionManagement({super.key});

  @override
  State<SessionManagement> createState() => _SessionManagementState();
}

class _SessionManagementState extends State<SessionManagement> {
  int? hoveredIndex;

  final Set<String> _alertedSessions = {};
  bool _audioEnabled = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _audioEnabled = true);
        }
      });
    } else {
      _audioEnabled = true;
    }
  }

  void _playEndSound() {
    if (!_audioEnabled) {
      return;
    }

    try {
      if (kIsWeb) {
        final audio = html.AudioElement();
        final audioPath =
            'assets/SOUNDS/short-digital-notification-alert-440353.mp3';

        audio.src = audioPath;
        audio.volume = 1.0;

        audio.load();

        audio.play().then((_) {}).catchError((error) {});

        // Add event listeners to track audio playback
        audio.onLoadedData.listen((_) {});

        audio.onPlay.listen((_) {});

        audio.onError.listen((event) {});
      } else {}
    } catch (e) {
    
    }
  }

  Future<void> _autoStopSession(SessionModel session) async {
    try {
      await context.read<SessionProvider>().stopSession(
        sessionId: session.id,
        deviceId: session.deviceId,
      );
    } catch (e) {
      debugPrint("Auto stop failed: $e");
    }
  }

  // ✅ Enhanced sound playing with web support
  void _playFallbackWebSound() {
    if (kIsWeb) {
      // You can use dart:html here as a fallback
      // Add this import at top: import 'dart:html' as html;
      // html.AudioElement()
      //   ..src = 'assets/sounds/time_over.mp3'
      //   ..autoplay = true
      //   ..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = context.watch<SessionProvider>();
    final consoles = context.watch<DeviceProvider>();
    final sessionsData = sessionsProvider.sessions;
    final deviceData = consoles.devices;
    // final isLoading = consoleProvider.loading;

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
                    "Playtime Management",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  SizedBox(height: 5),
                  if (kIsWeb) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _audioEnabled
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _audioEnabled
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _audioEnabled
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: _audioEnabled
                                    ? Colors.green
                                    : Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _audioEnabled ? "Sound ON" : "Sound OFF",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _audioEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _audioEnabled
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _audioEnabled
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon(
                              //   _audioEnabled
                              //       ? Icons.volume_up
                              //       : Icons.volume_off,
                              //   color: _audioEnabled
                              //       ? Colors.green
                              //       : Colors.orange,
                              //   size: 14,
                              // ),
                              const SizedBox(width: 4),
                              Text(
                                "${sessionsData.length} devices active",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _audioEnabled
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () async {
                  if (kIsWeb && !_audioEnabled) {
                    setState(() => _audioEnabled = true);
                  }

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
                        _buildHeaderCell("Device", flex: 3),
                        _buildHeaderCell("Running Games", flex: 2),
                        _buildHeaderCell("Timer", flex: 2),
                          _buildHeaderCell("Price", flex: 2),
                        _buildHeaderCell("Payment", flex: 2),
                        _buildHeaderCell("Status", flex: 2),
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
                      itemCount: deviceData.length,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                      itemBuilder: (context, index) {
                        final devicesData = deviceData[index];

                        final session = sessionsData
                            .where((s) => s.deviceId == devicesData.id)
                            .cast<SessionModel?>()
                            .firstOrNull;
                        // ✅ Check for session timeout
                        if (session != null &&
                            session.remainingSeconds == 0 &&
                            !_alertedSessions.contains(session.id)) {
                          _alertedSessions.add(session.id);

                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) async {
                            // ✅ Play sound FIRST
                            _playEndSound();

                            // Small delay so sound starts before dialog
                            await Future.delayed(Duration(milliseconds: 300));

                            if (session.isPaid) {
                              await _autoStopSession(session);
                            } else {
                              if (mounted) {
                                 await _autoStopSession(session);
                                _showSessionEndedPopup(session);
                              }
                            }
                          });
                        }

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
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildDeviceCell(
                                      devicesData.name,
                                      isHovered,
                                    ),
                                    _buildGameCell(
                                      session?.game ?? "FREE",
                                      isHovered,
                                    ),
                                    // _buildAvailableGamesCell(session.game),
                                    _buildTimerCell(
                                      session != null
                                          ? formatRemainingTime(session)
                                          : "-",
                                      isHovered,
                                    ),
                                     _buildPriceCell(session?.price ?? 0, isHovered),
                                         SizedBox(width: 5),
                                    _buildPaymentCell(
                                      session?.paymentMethod ?? "-",
                                      isHovered,
                                    ),

                                    _buildStatusCell(
                                      session?.isPaid ?? false,
                                      isHovered,
                                      session,
                                    ),

                                    SizedBox(width: 5),
                                    _buildActionsCell(
                                      isHovered,
                                      devicesData,
                                      session,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                if (session != null && !session.isPaid)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Colors.orange.withOpacity(
                                              0.1,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.warning,
                                                color: Colors.orange,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  "Payment is not yet completed. Kindly confirm payment before ending this session manually",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
      flex: 3,
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
Widget _buildPriceCell(int price, bool isHovered) {
  return Expanded(
    flex: 2,
    child: price > 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.currency_rupee,
                  color: Colors.green,
                  size: 14,
                ),
                Text(
                  price.toString(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        : Text(
            "-",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
  );
}
  Widget _buildGameCell(String game, bool isHovered) {
    final isFree = game.toLowerCase() == "free";
    return Expanded(
      flex: 2,
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

  Widget _buildStatusCell(bool isPaid, bool isHovered, SessionModel? session) {
    // log(isPaid.toString());
    return Expanded(
      flex: 2,
      child: session?.status == SessionStatus.running
          ? AnimatedContainer(
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
            )
          : SizedBox(),
    );
  }

  Widget _buildActionsCell(
    bool isHovered,
    DeviceModel device,
    SessionModel? session,
  ) {
    final isRunning = session != null;

    return Expanded(
      flex: 2,
      child: Row(
        children: [
          // ▶️ START
          _buildActionButton(
            icon: Icons.play_arrow,
            color: Colors.green,
            isHovered: isHovered,
            onTap: isRunning
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => StartSessionDialog(device: device),
                    );
                  },
          ),

          const SizedBox(width: 8),

          // ⏹ STOP
          _buildActionButton(
            icon: Icons.stop,
            color: Colors.red,
            isHovered: isHovered,
            onTap: isRunning
                ? () {
                    context.read<SessionProvider>().stopSession(
                      sessionId: session.id,
                      deviceId: device.id,
                    );
                  }
                : null,
          ),

          const SizedBox(width: 8),

          // ✏️ EDIT
          PopupMenuButton<DeviceAction>(
            color: AppColors.background,
            tooltip: "More actions",
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              _menuItem(
                value: DeviceAction.extend,
                icon: Icons.timer,
                text: "Extend Time",
                color: Colors.blue,
              ),
              _menuItem(
                value: DeviceAction.maintenance,
                icon: Icons.build,
                text: "Mark as Maintenance",
                color: Colors.orange,
              ),
              const PopupMenuDivider(),
              _menuItem(
                value: DeviceAction.delete,
                icon: Icons.delete,
                text: "Delete Device",
                color: Colors.red,
              ),
            ],
            onSelected: (value) {
              _handleDeviceAction(value, device, session);
            },
            child: _buildActionButton(
              icon: Icons.edit,
              color: AppColors.primary,
              isHovered: isHovered,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<DeviceAction> _menuItem({
    required DeviceAction value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem<DeviceAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeviceAction(
    DeviceAction action,
    DeviceModel device,
    SessionModel? session,
  ) {
    switch (action) {
      case DeviceAction.extend:
        _showExtendTimeDialog(session);
        break;

      case DeviceAction.maintenance:
        context.read<DeviceProvider>().setMaintenance(device.id);
        break;

      case DeviceAction.delete:
        context.read<DeviceProvider>().deleteDevice(device.id);
        break;
    }
  }

  void _showExtendTimeDialog(SessionModel? session) {
    if (session == null) return;

    int selectedMinutes = 30;
final extraPrice =
    SessionProvider.extendPricing[selectedMinutes] ?? 0;

    showDialog(
      barrierColor: AppColors.background,
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with gradient accent
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.05),
                            AppColors.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.surface,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withBlue(255),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Extend Session",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Add extra play time",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade400,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
                          // Current Session Info Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.08),
                                  AppColors.primary.withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CURRENT SESSION",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      session.deviceName + session.game ??
                                          "Active Session",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "REMAINING",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Text(
                                    //   session.duration ?? "15 min",
                                    //   style: const TextStyle(
                                    //     fontSize: 16,
                                    //     fontWeight: FontWeight.bold,
                                    //     color: AppColors.primary,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Time Selection Label
                          const Text(
                            "Select extension duration",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Time Options Grid
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _timeOptionCard(
                                label: "+30 min",
                                value: 30,
                                selectedValue: selectedMinutes,
                                onTap: () =>
                                    setState(() => selectedMinutes = 1),
                              ),
                              _timeOptionCard(
                                label: "+1 hour",
                                value: 60,
                                selectedValue: selectedMinutes,
                                onTap: () =>
                                    setState(() => selectedMinutes = 60),
                              ),
                              _timeOptionCard(
                                label: "+2 hours",
                                value: 120,
                                selectedValue: selectedMinutes,
                                onTap: () =>
                                    setState(() => selectedMinutes = 120),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Extension Preview
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surface),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "New total time:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "+$selectedMinutes minutes",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        border: Border(
                          top: BorderSide(color: AppColors.surface, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withBlue(255),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<SessionProvider>().extendSession(
                                    session.id,
                                    selectedMinutes,
                                  );

                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Confirm Extension",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _timeOptionCard({
    required String label,
    required int value,
    required int selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withBlue(255)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.surface,
            width: isSelected ? 2 : 2,
          ),
          boxShadow: isSelected
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surface
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
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

  void _showSessionEndedPopup(SessionModel session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) {
        return Center(
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔴 Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.orangeAccent],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_off,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Session Finished",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🧾 Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        session.deviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Game: ${session.game}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Time limit reached",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Action
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "OK, Got it",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
