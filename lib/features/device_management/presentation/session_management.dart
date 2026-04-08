import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/device_management/widget/widgets.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/core/utils/web_notifications.dart';
import 'package:gaming_center/core/utils/desktop_notifications.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';

class SessionManagement extends StatefulWidget {
  const SessionManagement({super.key});

  @override
  State<SessionManagement> createState() => _SessionManagementState();
}

class _SessionManagementState extends State<SessionManagement> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer; // For all platforms
  late FlutterTts _flutterTts; // For dynamic voice announcements
  bool _audioUnlocked = false;
  final WebNotifier _notifier = createWebNotifier();
  bool _notificationsEnabled = false;

  int? hoveredIndex;

  final Set<String> _alertedSessions = {};
  final Set<String> _endedDeviceAlerts =
      {}; // Track devices that need attention
  bool _audioEnabled = false;
  SessionProvider? _boundSessionProvider;

  // alert queue logic
  final List<String> _alertQueue = [];
  bool _isProcessingQueue = false;

  // Background heartbeat logic
  late AudioPlayer _heartbeatPlayer;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _heartbeatPlayer = AudioPlayer();
    _flutterTts = FlutterTts();
    _audioEnabled = true; // Audio is handled by audioplayers now
    DesktopNotifier.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb && _notifier.isSupported) {
      _notificationsEnabled = _notifier.isGranted;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _boundSessionProvider = context.read<SessionProvider>();
        _boundSessionProvider?.addListener(_checkSessionTimeouts);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _heartbeatPlayer.dispose();
    _boundSessionProvider?.removeListener(_checkSessionTimeouts);
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      _startHeartbeat();
    } else {
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    if (!kIsWeb) return; // Only needed for Web throttling
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (_audioEnabled) {
        try {
          // Play at nearly zero volume to keep audio context alive
          await _heartbeatPlayer.setVolume(0.001);
          await _heartbeatPlayer.play(
            AssetSource('SOUNDS/short-digital-notification-alert-440353.mp3'),
          );
        } catch (e) {
          debugPrint("Heartbeat failed: $e");
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatPlayer.stop();
  }

  void _checkSessionTimeouts() {
    if (!mounted) return;
    
    final sessionsData = _boundSessionProvider?.sessions ?? [];
    final consoles = context.read<DeviceProvider>().devices;

    bool hasNewAlerts = false;

    for (var session in sessionsData) {
      if (session.endTime != null && 
          session.remainingSeconds <= 0 && 
          !_alertedSessions.contains(session.id)) {
            
        _alertedSessions.add(session.id);

        final device = consoles.cast<DeviceModel?>().firstWhere(
          (d) => d?.id == session.deviceId, 
          orElse: () => null
        );
        
        if (device == null) continue;

        _endedDeviceAlerts.add(device.id);

        // Add to queue instead of playing immediately
        _alertQueue.add(device.name);
        hasNewAlerts = true;

        _notifySessionEnded(device.name, session.game);

        if (session.isPaid) {
          _autoStopSession(session);
        } else {
          _autoStopSession(session).then((_) {
            if (mounted) _showSessionEndedPopup(session);
          });
        }
      }
    }

    if (hasNewAlerts) {
      if (mounted) setState(() {});
      _processAlertQueue();
    }
  }

  Future<void> _processAlertQueue() async {
    if (_isProcessingQueue || _alertQueue.isEmpty) return;

    _isProcessingQueue = true;

    while (_alertQueue.isNotEmpty) {
      final deviceName = _alertQueue.removeAt(0);
      await _playEndSound(deviceName);
      // Small gap between announcements for better clarity
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _isProcessingQueue = false;
  }

  Future<void> _playEndSound(String deviceName) async {
    try {
      if (!_audioEnabled) return;

      // 1. Play the standard notification beep
      await _audioPlayer.play(
        AssetSource('SOUNDS/short-digital-notification-alert-440353.mp3'),
      );

      // 2. Wait briefly so the chime finishes cleanly
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Announce the specific console name dynamically
      await _flutterTts.setLanguage("en-GB");
      await _flutterTts.setVolume(20.0);
      await _flutterTts.setPitch(10.6); // Higher pitch for more energy
      await _flutterTts.setSpeechRate(0.85); // Slightly faster pace
      await _flutterTts.speak("$deviceName session is completed!");
    } catch (e) {
      debugPrint("❌ Play sound or TTS failed: $e");
    }
  }

  void _notifySessionEnded(String deviceName, String gameName) {
    final message = '$deviceName • $gameName time is over. Please confirm.';
    if (kIsWeb) {
      if (!_notifier.isSupported || !_notificationsEnabled) return;
      _notifier.notify('Session Ended', message);
    } else {
      DesktopNotifier.notify(title: 'Session Ended', body: message);
    }
  }

  void _clearAlert(String deviceId) {
    if (mounted) {
      setState(() {
        _endedDeviceAlerts.remove(deviceId);
      });
    }
  }

  Future<void> _enableAlerts() async {
    if (!kIsWeb) return;
    unlockAudioForWeb();
    final granted = await _notifier.requestPermission();
    if (mounted) {
      setState(() {
        _notificationsEnabled = granted;
        _audioEnabled = true;
      });
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

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = context.watch<SessionProvider>();
    final consoles = context.watch<DeviceProvider>();
    final settings = context.watch<SettingsProvider>();
    final sessionsData = sessionsProvider.sessions;
    final deviceData = consoles.devices;
    final warningSeconds = settings.settings.warningThreshold * 60;
    final openSessions = sessionsData.where((s) => s.endTime == null).length;
    final endingSoon = sessionsData
        .where(
          (s) =>
              s.endTime != null &&
              s.remainingSeconds > 0 &&
              s.remainingSeconds <= warningSeconds,
        )
        .length;
    // final isLoading = consoleProvider.loading;

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                  ],
                ),
                Row(
                  children: [
                    _buildTopStatusWidget(
                      icon: _audioEnabled ? Icons.volume_up : Icons.volume_off,
                      label: _audioEnabled ? "Sound On" : "Sound Off",
                      color: _audioEnabled ? Colors.green : Colors.grey,
                      onTap: () =>
                          setState(() => _audioEnabled = !_audioEnabled),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () async {
                        if (kIsWeb && !_audioUnlocked) {
                          unlockAudioForWeb();
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
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ReferenceStatCard(
                    title: "Active Sessions",
                    value: sessionsData.length.toString(),
                    icon: Icons.play_circle_outline,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ReferenceStatCard(
                    title: "Open Sessions",
                    value: openSessions.toString(),
                    icon: Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ReferenceStatCard(
                    title: "Ending Soon",
                    value: endingSoon.toString(),
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Table Container
            Expanded(
              child: Container(
                width: double.infinity,
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
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),

                    // Table Body
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(0),
                        itemCount: deviceData.length,
                        separatorBuilder: (context, index) => Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          color: AppColors.primary.withValues(alpha: 0.05),
                        ),
                        itemBuilder: (context, index) {
                          final devicesData = deviceData[index];

                          final session = sessionsData
                              .where((s) => s.deviceId == devicesData.id)
                              .cast<SessionModel?>()
                              .firstOrNull;

                          final isAlertActive = _endedDeviceAlerts.contains(
                            devicesData.id,
                          );
                          final isHovered = hoveredIndex == index;

                          return MouseRegion(
                            onEnter: (_) =>
                                setState(() => hoveredIndex = index),
                            onExit: (_) => setState(() => hoveredIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isAlertActive
                                    ? Colors.red.withValues(
                                        alpha: 0.05,
                                      ) // Highlight for alerts
                                    : isHovered
                                    ? AppColors.primary.withValues(alpha: 0.03)
                                    : Colors.transparent,
                                border: isAlertActive
                                    ? Border.all(
                                        color: Colors.red.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1,
                                      )
                                    : null,
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
                                        devicesData.status ==
                                                DeviceStatus.maintenance
                                            ? "MAINTENANCE"
                                            : (session?.game ?? "FREE"),
                                        isHovered,
                                      ),
                                      // _buildAvailableGamesCell(session.game),
                                      _buildTimerCell(
                                        session != null
                                            ? formatRemainingTime(session)
                                            : "-",
                                        isHovered,
                                        session,
                                      ),
                                      _buildPriceCell(
                                        session?.price ?? 0,
                                        isHovered,
                                      ),
                                      SizedBox(width: 5),
                                      _buildPaymentCell(
                                        session?.paymentMethod ?? "-",
                                        isHovered,
                                      ),

                                      _buildStatusCell(
                                        session?.isPaid ?? false,
                                        isHovered,
                                        session,
                                        devicesData.id,
                                        devicesData.status,
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.orange.withValues(
                                                alpha: 0.1,
                                              ),
                                              border: Border.all(
                                                color: Colors.orange.withValues(
                                                  alpha: 0.3,
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
                                                      fontWeight:
                                                          FontWeight.w500,
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

  Widget _buildTopStatusWidget({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
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
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
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
          ? Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                final currency = settings.settings.currencySymbol;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
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
                );
              },
            )
          : Text(
              "-",
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFree
                    ? Colors.green.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.15),
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

  void unlockAudioForWeb() {
    if (!kIsWeb || _audioUnlocked) return;

    // Play a silent sound to unlock the AudioContext on web
    try {
      _audioPlayer
          .setSource(
            AssetSource('SOUNDS/short-digital-notification-alert-440353.mp3'),
          )
          .then((_) {
            _audioPlayer.setVolume(0.0);
            _audioPlayer.resume().then((_) {
              _audioPlayer.pause();
              _audioPlayer.setVolume(1.0);
              _audioUnlocked = true;
              if (mounted) {
                setState(() {});
              }
              debugPrint("🔊 Web audio unlocked via audioplayers");
            });
          });
    } catch (e) {
      debugPrint("❌ Unlock audio failed: $e");
    }
  }

  Widget _buildTimerCell(String time, bool isHovered, SessionModel? session) {
    final isActive = time != "-" && session != null;
    double progress = 0.0;
    if (isActive && session.duration > 0) {
      progress =
          (session.duration - session.remainingSeconds) / session.duration;
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;
    }

    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: session.remainingSeconds < 300
                        ? Colors.orange
                        : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (session.remainingSeconds < 300
                                    ? Colors.orange
                                    : Colors.red)
                                .withValues(alpha: 0.5),
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
          if (isActive) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  session.remainingSeconds < 300
                      ? Colors.orange
                      : AppColors.primary,
                ),
                minHeight: 4,
              ),
            ),
          ],
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

  Widget _buildStatusCell(
    bool isPaid,
    bool isHovered,
    SessionModel? session,
    String deviceId,
    DeviceStatus deviceStatus,
  ) {
    final bool isAlertActive = _endedDeviceAlerts.contains(deviceId);

    if (isAlertActive) {
      return Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 14),
              const SizedBox(width: 6),
              const Text(
                "ALERT",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      flex: 2,
      child: session?.status == SessionStatus.running
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.withValues(alpha: isHovered ? 0.15 : 0.1)
                    : Colors.orange.withValues(alpha: isHovered ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
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
          : deviceStatus == DeviceStatus.maintenance
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.build, color: Colors.grey, size: 14),
                  SizedBox(width: 6),
                  Text(
                    "Maintenance",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildActionsCell(
    bool isHovered,
    DeviceModel device,
    SessionModel? session,
  ) {
    final isRunning = session != null;
    final bool isAlertActive = _endedDeviceAlerts.contains(device.id);

    return Expanded(
      flex: 2,
      child: Row(
        children: [
          if (isAlertActive)
            IconButton(
              onPressed: () => _clearAlert(device.id),
              tooltip: "Clear Alert",
              icon: const Icon(
                Icons.notifications_off_outlined,
                color: Colors.red,
                size: 20,
              ),
            ),
          PopupMenuButton<String>(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            offset: const Offset(0, 40),
            elevation: 8,
            onSelected: (action) {
              if (action == 'start') {
                _clearAlert(device.id);
                if (kIsWeb && (!_audioUnlocked || !_notificationsEnabled)) {
                  _enableAlerts();
                }
                showDialog(
                  context: context,
                  builder: (_) => StartSessionDialog(device: device),
                );
              } else if (action == 'stop') {
                context.read<SessionProvider>().stopSession(
                  sessionId: session!.id,
                  deviceId: device.id,
                );
              } else if (action == 'extend') {
                _showExtendTimeDialog(session);
              } else if (action == 'edit') {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => EditConsoleDialog(device: device),
                );
              } else if (action == 'maintenance') {
                context.read<DeviceProvider>().setMaintenance(device.id);
              } else if (action == 'free') {
                context.read<DeviceProvider>().setFree(device.id);
              } else if (action == 'delete') {
                context.read<DeviceProvider>().deleteDevice(device.id);
              }
            },
            itemBuilder: (context) => [
              if (!isRunning && device.status != DeviceStatus.maintenance)
                _buildPopupMenuItem(
                  value: 'start',
                  icon: Icons.play_arrow,
                  label: 'Start Session',
                  color: Colors.green,
                ),
              if (isRunning) ...[
                _buildPopupMenuItem(
                  value: 'stop',
                  icon: Icons.stop,
                  label: 'Stop Session',
                  color: Colors.red,
                ),
                _buildPopupMenuItem(
                  value: 'extend',
                  icon: Icons.timer,
                  label: 'Extend Time',
                  color: Colors.blue,
                ),
              ],
              const PopupMenuDivider(),
              _buildPopupMenuItem(
                value: 'edit',
                icon: Icons.edit,
                label: 'Edit Console',
                color: AppColors.primary,
              ),
              if (device.status == DeviceStatus.maintenance)
                _buildPopupMenuItem(
                  value: 'free',
                  icon: Icons.check_circle,
                  label: 'Available',
                  color: Colors.green,
                )
              else
                _buildPopupMenuItem(
                  value: 'maintenance',
                  icon: Icons.build,
                  label: 'Maintenance',
                  color: Colors.orange,
                ),
              _buildPopupMenuItem(
                value: 'delete',
                icon: Icons.delete,
                label: 'Delete Device',
                color: Colors.red,
              ),
            ],
            child: _buildActionButton(
              icon: Icons.more_vert,
              color: AppColors.textSecondary,
              isHovered: isHovered,
              onTap: null, // Tap handled by PopupMenuButton
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showExtendTimeDialog(SessionModel? session) {
    if (session == null) return;

    int selectedMinutes = 30;

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
                              Icons.timer,
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
                                  "Extend Session",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Add extra play time to ${session.deviceName}",
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
                          // Current Session Info Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.08),
                                  AppColors.primary.withValues(alpha: 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
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
                                      "${session.deviceName} - ${session.game}",
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
                                    Text(
                                      formatRemainingTime(session),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
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
                                icon: Icons.timer_outlined,
                                selectedValue: selectedMinutes,
                                onTap: () =>
                                    setState(() => selectedMinutes = 30),
                              ),
                              _timeOptionCard(
                                label: "+1 hour",
                                value: 60,
                                icon: Icons.add_circle_outline,
                                selectedValue: selectedMinutes,
                                onTap: () =>
                                    setState(() => selectedMinutes = 60),
                              ),
                              _timeOptionCard(
                                label: "+2 hours",
                                value: 120,
                                icon: Icons.add_circle_outline,
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
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
    required IconData icon,
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
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.surface,
            width: 2,
          ),
          boxShadow: isSelected
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
          color: isHovered
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: isHovered ? 0.3 : 0.2),
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
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) {
        return Center(
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
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
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
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
