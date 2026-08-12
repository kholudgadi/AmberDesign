import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../screens/designer_home_screen.dart';
import '../services/designer_service.dart';
import '../services/api_client.dart';

class DesignerProfileSetupScreen extends StatefulWidget {
  final String
  domainName; // Receives the selected domain name from the previous screen.

  const DesignerProfileSetupScreen({super.key, required this.domainName});

  @override
  State<DesignerProfileSetupScreen> createState() =>
      _DesignerProfileSetupScreenState();
}

class _DesignerProfileSetupScreenState
    extends State<DesignerProfileSetupScreen> {
  // Text controllers that track the form fields and their validity.
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedExperience;

  // Tracks whether the form is complete enough to enable the action button.
  bool _isFormValid = false;

  final List<String> experienceOptions = [
    'أقل من ٢ سنة',
    '٢-٥ سنة',
    '٥-١٠ سنة',
    'أكثر من ١٠ سنة',
  ];

  @override
  void initState() {
    super.initState();
    // Listen for changes in the form fields so the button state updates immediately.
    _cityController.addListener(_checkFormValidity);
    _bioController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Checks whether all required profile fields have been filled.
  void _checkFormValidity() {
    bool isValid =
        _cityController.text.trim().isNotEmpty &&
        _bioController.text.trim().isNotEmpty &&
        _selectedExperience != null;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  // Converts the selected domain into a job title for the profile.
  String _getJobTitle() {
    switch (widget.domainName) {
      case 'تصميم الأزياء':
        return 'مصممة أزياء';
      case 'التصميم الداخلي':
        return 'مصمم داخلي';
      case 'التصميم الخارجي':
        return 'مصمم خارجي';
      default:
        return widget.domainName;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ),
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Header section with profile setup guidance.
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'إعداد ملفك الشخصي',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Shows the derived job title based on the selected domain.
                        Text(
                          _getJobTitle(),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile picture upload placeholder.
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.textDark.withOpacity(0.2),
                                ),
                                color: AppColors.textDark.withOpacity(0.08),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: AppColors.textMuted.withOpacity(0.6),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.textDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.upload,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'رفع صورة شخصية',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // City input field.
                  const Text(
                    'المدينة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: 20,
                    child: TextField(
                      controller: _cityController, 
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'الرياض',
                        hintStyle: TextStyle(color: Colors.black26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Short biography input field.
                  const Text(
                    'نبذة مختصرة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    borderRadius: 20,
                    child: TextField(
                      controller: _bioController, 
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'أكثر من ١٠ سنوات خبرة في تصميم الفضاءات الداخلية...',
                        hintStyle: TextStyle(color: Colors.black26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Experience level selection.
                  const Text(
                    'سنوات الخبرة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: experienceOptions.map((option) {
                      bool isSelected = _selectedExperience == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedExperience = option;
                            _checkFormValidity();
                          });
                        },
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textDark
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  // Submit button that becomes active once the form is complete.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid
                          ? () async {
                              final experienceIndex = experienceOptions.indexOf(_selectedExperience!);
                              final experience = switch (experienceIndex) { 0 => 1, 1 => 3, 2 => 7, _ => 11 };
                              try {
                                await DesignerService.instance.updateAccount(city: _cityController.text.trim(), bio: _bioController.text.trim());
                                await DesignerService.instance.updateProfessionalProfile(experienceYears: experience, specialties: [widget.domainName]);
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DesignerHomeScreen(),
                                ),
                                (route) => false,
                              );
                              } on ApiException catch (error) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        // Adjusts the button color based on the form completeness.
                        backgroundColor: _isFormValid
                            ? AppColors.textDark
                            : AppColors.textMuted.withOpacity(0.3),
                        disabledBackgroundColor: AppColors.textMuted
                            .withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isFormValid
                              ? Colors.white
                              : Colors.white70, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
