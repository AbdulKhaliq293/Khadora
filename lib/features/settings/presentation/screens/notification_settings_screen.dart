import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/theme/colors.dart';
import 'package:plant_care_app/features/settings/presentation/providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingTile(
            context,
            title: 'Water Reminders',
            subtitle: 'Get notified when it\'s time to water your plants.',
            value: settings.waterReminders,
            onChanged: (value) => notifier.toggleWaterReminders(value),
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            title: 'Fertilization Reminders',
            subtitle: 'Get notified when it\'s time to fertilize your plants.',
            value: settings.fertilizerReminders,
            onChanged: (value) => notifier.toggleFertilizerReminders(value),
            icon: Icons.science,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            title: 'Weather Alerts',
            subtitle: 'Get notified about extreme weather conditions.',
            value: settings.weatherAlerts,
            onChanged: (value) => notifier.toggleWeatherAlerts(value),
            icon: Icons.cloud_outlined,
            color: Colors.white,
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: white.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications are scheduled based on Gemini analysis of each plant\'s needs.',
                    style: TextStyle(color: white.withOpacity(0.7), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: darkGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 40),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
        ),
      ),
    );
  }
}
