import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_top_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/app_background.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  final bool isDesigner;

  const SignupScreen({super.key, required this.isDesigner});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // created TextEditingController for each input field to manage and read the text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // This boolean will track if all fields are filled to enable the "Next" button
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Adding listeners to each controller to check form validity whenever the text changes
    _nameController.addListener(_checkFormValidity);
    _emailController.addListener(_checkFormValidity);
    _phoneController.addListener(_checkFormValidity);
    _passwordController.addListener(_checkFormValidity);
    _confirmPasswordController.addListener(_checkFormValidity);
  }

  // This method checks if all input fields are filled and updates the _isFormValid state accordingly
  void _checkFormValidity() {
    bool isValid =
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    // Only update the state if the validity has changed to avoid unnecessary rebuilds
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                const CustomTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/images/Amber_Design_Logo.png',
                            height: 140,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isDesigner
                              ? 'إنشاء حساب مصمم'
                              : 'إنشاء حساب مستخدم',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'أدخل بياناتك للتسجيل',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // connecting the CustomTextField widgets with their respective controllers to manage input
                        CustomTextField(
                          label: 'الاسم الكامل',
                          hint: 'محمد العمري',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'البريد الإلكتروني',
                          hint: 'example@mail.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'رقم الجوال',
                          hint: '+966 5x xxx xxxx',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'كلمة المرور',
                          hint: '••••••••',
                          isPassword: true,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'تأكيد كلمة المرور',
                          hint: '••••••••',
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          onTogglePassword: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // The "Next" button is enabled only when all fields are filled
                        ElevatedButton(
                          // The onPressed callback is set to null when the form is not valid, which disables the button. When the form is valid, it prints a debug message.
                          onPressed: _isFormValid
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtpVerificationScreen(
                                        email: _emailController.text, // Passing the email to the OTP verification screen
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            // The background color changes based on the form's validity. If the form is valid, it uses a darker color; if not, it uses a muted color with opacity.
                            backgroundColor: _isFormValid
                                ? const Color.fromRGBO(38, 23, 50, 0.8)
                                : AppColors.textMuted.withOpacity(0.5),
                            disabledBackgroundColor: AppColors.textMuted
                                .withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: _isFormValid
                                ? 8
                                : 0, // Elevation is set to 0 when the button is disabled to give a flat appearance
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
