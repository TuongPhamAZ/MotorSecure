import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'otp_contract.dart';

class OtpPresenter {
  final OtpViewContract? _view;
  OtpPresenter(this._view, this.email);
  String pinCode = "";
  String? email = "";

  void initSendPinCode() {
    pinCode = _generateRandomCode();
    _sendConfirmationCode(pinCode);
  }

  Future<void> pinCodeVerify(String? pinCode) async {
    if (this.pinCode == pinCode) {
      _view?.onVerifySucceeded();
    } else {
      _view?.onWrongPinCodeError();
    }
  }

  void resendConfirmationCode() {
    pinCode = _generateRandomCode();
    _sendConfirmationCode(pinCode);
    _view?.onResendPinCode();
  }

  String _generateRandomCode() {
    Random random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  void _sendConfirmationCode(String code) async {
    String username = "personalschedulemanager@gmail.com";
    String password = "myocgxvnvsdybuhr";

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(email)
      ..subject = 'Confirmation Code'
      ..text = 'Your confirmation code is: $code';

    try {
      final sendReport = await send(message, smtpServer);
      if (kDebugMode) {
        print('Message sent to $email: $sendReport');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}
