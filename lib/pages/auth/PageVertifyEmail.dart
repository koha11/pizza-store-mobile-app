import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/pages/home/PageHome.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../../controllers/controller_auth.dart';
import '../../controllers/controller_user.dart';
import 'PageLogin.dart';

class PageVerifyEmail extends StatelessWidget {
  final String email;
  const PageVerifyEmail({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String otpCode = '';

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xác thực OTP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Chúng tôi đã gửi một mã OTP vào email của bạn",
                style: TextStyle(color: Colors.grey),
              ),
              Form(
                key: formKey,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) => otpCode = value,
                  onCompleted: (value) async {
                    otpCode = value;
                    loadingDialog();

                    AuthController.verifyOtp(otpCode: otpCode, email: email);
                  },
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    activeColor: Colors.blue,
                    selectedColor: Colors.black,
                    inactiveColor: Colors.grey,
                  ),
                  onEditingComplete: () async {
                    if (otpCode.length == 6) {
                      loadingDialog();

                      AuthController.verifyOtp(otpCode: otpCode, email: email);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
