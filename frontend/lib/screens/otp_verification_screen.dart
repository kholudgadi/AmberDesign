import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_top_bar.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/phone_auth_service.dart';
import 'home_screen.dart';
import 'designer_home_screen.dart';

/// Collects and validates a four-digit one-time passcode before entering the app.
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String displayName;
  final String phone;
  final bool isDesigner;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.displayName,
    required this.phone,
    required this.isDesigner,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Firebase phone verification uses a six-digit code.
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // Controls automatic keyboard focus movement between the individual digit fields.
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isOtpComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    // Listens to every field so the submit button updates as soon as all digits are present.
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkOtpCompletion);
    }
  }

  // Updates the form state when all OTP digits have been entered.
  void _checkOtpCompletion() {
    bool isComplete = _controllers.every((c) => c.text.isNotEmpty);
    if (_isOtpComplete != isComplete) {
      setState(() {
        _isOtpComplete = isComplete;
      });
    }
  }

  @override
  void dispose() {
    // Disposes all controllers and focus nodes to prevent resource leaks.
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Routes the user to the next screen after the OTP is verified.
  Future<void> _verifyOtpAndProceed() async {
    String otpCode = _controllers.map((c) => c.text).join();
    setState(() => _isLoading = true);
    try {
      final phoneIdToken = await PhoneAuthService.instance.confirmCode(otpCode);
      await AuthService.instance.register(
        email: widget.email,
        password: widget.password,
        displayName: widget.displayName,
        phone: widget.phone,
        phoneIdToken: phoneIdToken,
        isDesigner: widget.isDesigner,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => widget.isDesigner ? const DesignerHomeScreen() : const HomeScreen()),
        (_) => false,
      );
    } on PhoneAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      await PhoneAuthService.instance.sendCode(widget.phone);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رمز جديد')));
    } on PhoneAuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The confirmation action remains disabled until the complete OTP is entered.
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
                        const SizedBox(height: 30),

                        Center(
                          child: Image.asset(
                            'assets/images/Amber_Design_Logo.png',
                            height: 130,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'رمز التحقق',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'تم إرسال رمز أمان مكون من 6 أرقام إلى\n${widget.phone}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Row of OTP input boxes
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              6,
                              (index) => _buildOtpBox(index),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لم يصلك الرمز؟ ',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : _resend,
                              child: const Text(
                                'إعادة إرسال',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: _isOtpComplete && !_isLoading
                              ? _verifyOtpAndProceed // Calls the OTP verification and navigation handler.
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOtpComplete
                                ? const Color.fromRGBO(38, 23, 50, 0.8)
                                : AppColors.textMuted.withOpacity(0.5),
                            disabledBackgroundColor: AppColors.textMuted
                                .withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: _isOtpComplete ? 8 : 0,
                          ),
                          child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text(
                            'تأكيد', style: TextStyle(
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

  // This method builds an individual OTP input box based on the provided index
  Widget _buildOtpBox(int index) {
    // Restricts each box to one digit and moves focus forward or backward automatically.
    return Container(
      width: 60,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? AppColors.textDark
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
