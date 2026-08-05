import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

/// Local preference screen for notification and language selections.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Stores the current settings until they are persisted.
  bool _isNotificationsEnabled = true;
  int _selectedLanguage = 1; // 1 = Arabic, 2 = English

  @override
  Widget build(BuildContext context) {
    // State changes are applied locally; persistence can be added behind these controls later.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('الإعدادات', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 8),
                    child: Text('الإشعارات', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إشعارات الطلبات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        Switch(
                          value: _isNotificationsEnabled, // Keeps the switch synchronized with its state.
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.textDark,
                          onChanged: (val) {
                            // Rebuild the screen to reflect the selected preference.
                            setState(() {
                              _isNotificationsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.only(right: 16, bottom: 8),
                    child: Text('اللغة', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          value: 1,
                          groupValue: _selectedLanguage, // Keeps the radio option synchronized with its state.
                          onChanged: (val) {
                            setState(() {
                              _selectedLanguage = val!;
                            });
                          },
                          title: const Text('العربية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          activeColor: AppColors.textDark,
                        ),
                        const Divider(height: 1, color: Colors.black12),
                        RadioListTile<int>(
                          value: 2,
                          groupValue: _selectedLanguage, // Keeps the radio option synchronized with its state.
                          onChanged: (val) {
                            setState(() {
                              _selectedLanguage = val!;
                            });
                          },
                          title: const Text('English', style: TextStyle(fontSize: 16, color: AppColors.textDark)),
                          activeColor: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Center(
                    child: Text('Amber design v1.0.0 © 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
