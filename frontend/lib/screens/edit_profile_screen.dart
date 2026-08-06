import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

/// Editable profile form that tracks whether any field has been modified.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Prevents saving until the user makes a change.
  bool _hasChanges = false;
  
  
  void _onFieldChanged(String value) {
    // Marks the form dirty only once; further edits do not need extra state updates.
    if (!_hasChanges) setState(() => _hasChanges = true);
  }
  
  @override
  Widget build(BuildContext context) {
    // The save button styling reflects whether there are pending profile changes.
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
          title: const Text('تعديل الملف الشخصي', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            color: AppColors.textDark.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.textDark.withOpacity(0.20), width: 2),
                          ),
                          child: const Icon(Icons.person_outline, size: 50, color: AppColors.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.textDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.upload, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text('تغيير الصورة الشخصية', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                  const SizedBox(height: 32),

                  _buildTextFieldTitle('الاسم الكامل'),
                  _buildGlassTextField('اسم المستخدم'),
                  
                  const SizedBox(height: 24),
                  _buildTextFieldTitle('البريد الإلكتروني'),
                  _buildGlassTextField('user@example.com'),
                  
                  const SizedBox(height: 24),
                  _buildTextFieldTitle('رقم الجوال'),
                  _buildGlassTextField('+966 5x xxx xxxx'),
                  
                  const SizedBox(height: 48),

                  // Save button becomes active only after a field changes.
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _hasChanges ? () {
                        // Reset the dirty state after the changes are saved.
                        setState(() => _hasChanges = false); // Disables the button again after saving.
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasChanges ? AppColors.textDark : AppColors.textDark.withOpacity(0.3),
                        disabledBackgroundColor: AppColors.textDark.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: _hasChanges ? 5 : 0,
                      ),
                      child: const Text(
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldTitle(String title) {
    // Standardizes labels above each editable profile field.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 16),
      child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
    );
  }

  Widget _buildGlassTextField(String hint) {
    // Reuses the glass field appearance and forwards edits to the dirty-state handler.
    return GlassCard(
      height: 55,
      borderRadius: 25,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _onFieldChanged, // Enables the save button when the user edits a field.
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textDark),
        ),
      ),
    );
  }
}
