import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../data/terminal_coordinates.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/sleep_mode_task.dart';
import '../theme/app_theme.dart';

class SleepModeScreen extends StatefulWidget {
  final String destTerminalName;

  const SleepModeScreen({super.key, required this.destTerminalName});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  double _alertKm = 2.0;
  String? _errorMsg;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    super.dispose();
  }

  void _onTaskData(dynamic data) {
    if (data is Map && data['action'] == 'wake_up') {
      _triggerWakeUp();
    }
  }

  Future<void> _triggerWakeUp() async {
    await _stopService();
    if (!mounted) return;
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [0, 600, 200, 600, 200, 600], repeat: 3);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WakeUpDialog(
        destName: widget.destTerminalName,
        onDismiss: () {
          Vibration.cancel();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<bool> _checkAndRequestPermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      final lang = context.read<LanguageProvider>().langCode;
      setState(() => _errorMsg = AppStrings.get(lang, 'locationPermDenied'));
      return false;
    }
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  Future<void> _startService() async {
    setState(() => _errorMsg = null);

    final coord = findCoord(widget.destTerminalName);
    if (coord == null) {
      final lang = context.read<LanguageProvider>().langCode;
      setState(() => _errorMsg = AppStrings.fmt(lang, 'terminalCoordsNotFound', {'dest': widget.destTerminalName}));
      return;
    }

    final permitted = await _checkAndRequestPermission();
    if (!permitted) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final lang = context.read<LanguageProvider>().langCode;
      setState(() => _errorMsg = AppStrings.get(lang, 'enableLocationService'));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sleep_dest_lat', coord.lat);
    await prefs.setDouble('sleep_dest_lng', coord.lng);
    await prefs.setDouble('sleep_alert_meters', _alertKm * 1000);

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: '수면 모드 중 🌙',
      notificationText: '목적지(${widget.destTerminalName}) 접근 시 알립니다',
      callback: startSleepModeCallback,
    );

    setState(() => _isRunning = true);
  }

  Future<void> _stopService() async {
    await FlutterForegroundTask.stopService();
    if (mounted) setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: _isRunning ? const Color(0xFF0D1B2A) : AppColors.background,
        appBar: AppBar(
          backgroundColor: _isRunning ? const Color(0xFF0D1B2A) : AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get(lang, 'sleepMode')),
          elevation: 0,
        ),
        body: _isRunning ? _buildActiveUI(lang) : _buildSetupUI(lang),
      ),
    );
  }

  Widget _buildSetupUI(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Column(
              children: [
                const Icon(Icons.snooze, size: 56, color: Color(0xFF7C3AED)),
                const SizedBox(height: 12),
                Text(AppStrings.get(lang, 'sleepMode'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get(lang, 'sleepModeDesc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.get(lang, 'sleepDest'), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(widget.destTerminalName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.get(lang, 'alertDistance'),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [2.0, 5.0, 10.0].map((km) {
              final selected = _alertKm == km;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _alertKm = km),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      AppStrings.fmt(lang, 'kmBefore', {'km': '${km.toInt()}'}),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMsg!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startService,
              icon: const Icon(Icons.snooze),
              label: Text(AppStrings.get(lang, 'startSleepMode'), style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUI(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2E4A),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.snooze, size: 80, color: Color(0xFFE2D9F3)),
            ),
          ),
          const SizedBox(height: 40),
          Text(AppStrings.get(lang, 'sleepModeRunning'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            AppStrings.fmt(lang, 'sleepModeAlert', {'dest': widget.destTerminalName, 'km': '${_alertKm.toInt()}'}),
            style: const TextStyle(fontSize: 15, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(AppStrings.get(lang, 'gpsMonitoring'),
              style: const TextStyle(fontSize: 13, color: Colors.white38)),
          const SizedBox(height: 60),
          OutlinedButton.icon(
            onPressed: _stopService,
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white60),
            label: Text(AppStrings.get(lang, 'stopSleepMode'), style: const TextStyle(color: Colors.white60)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WakeUpDialog extends StatelessWidget {
  final String destName;
  final VoidCallback onDismiss;

  const _WakeUpDialog({required this.destName, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageProvider>().langCode;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm, size: 44, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.get(lang, 'wakeUpTitle'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              AppStrings.fmt(lang, 'wakeUpDesc', {'dest': destName}),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.get(lang, 'confirm'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
