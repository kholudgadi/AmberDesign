import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_top_bar.dart';
import 'home_screen.dart';

/// Collects and validates a four-digit one-time passcode before entering the app.
class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    this.email = 'example@mail.com', // Default email if not provided
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // List of TextEditingControllers for the 4 OTP input fields
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  
  // Controls automatic keyboard focus movement between the individual digit fields.
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isOtpComplete = false;

  @override
  void initState() {
    // Listens to every field so the submit button updates as soon as all digits are present.
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkOtpCompletion);
    }
  }

  // This method checks if all OTP input fields are filled and updates the _isOtpComplete state accordingly
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
                          'تم إرسال رمز أمان مكون من 4 أرقام إلى\n${widget.email}',
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
                              4,
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
                              onTap: () {
                                debugPrint("إعادة إرسال الرمز...");
                              },
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
                          onPressed: _isOtpComplete
                              ? () {
                                  String otpCode = _controllers.map((c) => c.text).join();
                                  debugPrint("الرمز المدخل هو: $otpCode");
                                  Navigator.pushAndRemoveUntil(
                                    // Navigates to the HomeScreen and removes all previous routes from the stack.
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false, // delete all previous routes
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOtpComplete
                                ? const Color.fromRGBO(38, 23, 50, 0.8)
                                : AppColors.textMuted.withOpacity(0.5),
                            disabledBackgroundColor:
                                AppColors.textMuted.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: _isOtpComplete ? 8 : 0,
                          ),
                          child: const Text(
                            'تأكيد',
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
            if (index < 3) {
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
