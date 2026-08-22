import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthException implements Exception {
  final String message;
  const PhoneAuthException(this.message);
  @override
  String toString() => message;
}

class PhoneAuthService {
  PhoneAuthService._();
  static final instance = PhoneAuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ConfirmationResult? _webConfirmation;
  String? _verificationId;

  String normalizePhone(String value) {
    var phone = value.replaceAll(RegExp(r'[\s()-]'), '');
    if (phone.startsWith('00966')) phone = '+${phone.substring(2)}';
    if (phone.startsWith('05')) phone = '+966${phone.substring(1)}';
    if (!phone.startsWith('+')) phone = '+$phone';
    return phone;
  }

  Future<void> sendCode(String rawPhone) async {
    final phone = normalizePhone(rawPhone);
    if (kIsWeb) {
      try {
        _webConfirmation = await _auth.signInWithPhoneNumber(phone);
      } on FirebaseAuthException catch (error) {
        throw PhoneAuthException(_message(error));
      }
      return;
    }

    final completer = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: (error) {
        if (!completer.isCompleted) completer.completeError(PhoneAuthException(_message(error)));
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) => _verificationId = verificationId,
    );
    return completer.future;
  }

  Future<String> confirmCode(String code) async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        final confirmation = _webConfirmation;
        if (confirmation == null) throw const PhoneAuthException('أعد إرسال رمز التحقق');
        credential = await confirmation.confirm(code);
      } else {
        final verificationId = _verificationId;
        if (verificationId == null) throw const PhoneAuthException('أعد إرسال رمز التحقق');
        credential = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code),
        );
      }
      final token = await credential.user?.getIdToken(true);
      if (token == null) throw const PhoneAuthException('تعذر إنشاء رمز التحقق');
      return token;
    } on FirebaseAuthException catch (error) {
      throw PhoneAuthException(_message(error));
    }
  }

  String _message(FirebaseAuthException error) => switch (error.code) {
    'invalid-phone-number' => 'رقم الجوال غير صحيح، استخدم الصيغة الدولية +966',
    'invalid-verification-code' => 'رمز التحقق غير صحيح',
    'too-many-requests' => 'محاولات كثيرة، حاول لاحقًا',
    'quota-exceeded' => 'تم تجاوز حصة رسائل التحقق',
    _ => error.message ?? 'تعذر التحقق من رقم الجوال',
  };
}
