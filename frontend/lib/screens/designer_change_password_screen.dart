import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/designer_app_background.dart';
import '../widgets/designer_glass_card.dart';

class DesignerChangePasswordScreen extends StatefulWidget {
  const DesignerChangePasswordScreen({super.key});

  @override
  State<DesignerChangePasswordScreen> createState() => _DesignerChangePasswordScreenState();
}

class _DesignerChangePasswordScreenState extends State<DesignerChangePasswordScreen> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordCtrl.addListener(_checkValidation);
    _newPasswordCtrl.addListener(_checkValidation);
    _confirmPasswordCtrl.addListener(_checkValidation);
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _checkValidation() {
    final current = _currentPasswordCtrl.text;
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    final isValid = current.isNotEmpty && 
                    newPass.isNotEmpty && 
                    confirmPass.isNotEmpty && 
                    (newPass == confirmPass); 

    if (_isButtonEnabled != isValid) {
      setState(() => _isButtonEnabled = isValid);
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
          centerTitle: true,
          title: const Text(
            'تغيير كلمة المرور',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark), 
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: DesignerAppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40), 
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildPasswordField(
                    title: 'كلمة المرور الحالية',
                    controller: _currentPasswordCtrl,
                    isObscured: _obscureCurrent,
                    onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),

                  _buildPasswordField(
                    title: 'كلمة المرور الجديدة',
                    controller: _newPasswordCtrl,
                    isObscured: _obscureNew,
                    onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                  ),

                  _buildPasswordField(
                    title: 'تأكيد كلمة المرور',
                    controller: _confirmPasswordCtrl,
                    isObscured: _obscureConfirm,
                    onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isButtonEnabled ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح!')),
                        );
                        Navigator.pop(context); 
                      } : null, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled 
                            ? const Color(0xFF4A3B52) 
                            : const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5), 
                        disabledBackgroundColor: const Color.fromARGB(255, 175, 165, 175).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: _isButtonEnabled ? 4 : 0,
                      ),
                      child: Text(
                        'تحديث كلمة المرور', 
                        style: TextStyle(
                          color: _isButtonEnabled ? Colors.white : Colors.white.withOpacity(0.7), 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )
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

  Widget _buildPasswordField({
    required String title,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 12),
          child: Text(
            title, 
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.bold)
          ),
        ),
        DesignerGlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 50,
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            style: const TextStyle(color: AppColors.textDark, fontSize: 18, letterSpacing: 3.0),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.4), letterSpacing: 3.0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, 
                  color: AppColors.textMuted.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}