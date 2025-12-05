import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool waterReminders;
  final bool fertilizerReminders;
  final bool weatherAlerts;

  SettingsState({
    this.waterReminders = true,
    this.fertilizerReminders = true,
    this.weatherAlerts = false,
  });

  SettingsState copyWith({
    bool? waterReminders,
    bool? fertilizerReminders,
    bool? weatherAlerts,
  }) {
    return SettingsState(
      waterReminders: waterReminders ?? this.waterReminders,
      fertilizerReminders: fertilizerReminders ?? this.fertilizerReminders,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      waterReminders: prefs.getBool('waterReminders') ?? true,
      fertilizerReminders: prefs.getBool('fertilizerReminders') ?? true,
      weatherAlerts: prefs.getBool('weatherAlerts') ?? false,
    );
  }

  Future<void> toggleWaterReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('waterReminders', value);
    state = state.copyWith(waterReminders: value);
  }

  Future<void> toggleFertilizerReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fertilizerReminders', value);
    state = state.copyWith(fertilizerReminders: value);
  }

  Future<void> toggleWeatherAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weatherAlerts', value);
    state = state.copyWith(weatherAlerts: value);
  }
}
