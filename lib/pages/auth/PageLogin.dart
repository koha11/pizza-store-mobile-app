import 'package:flutter/material.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_auth.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/layouts/ManagerLayout.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/pages/auth/PageRegister.dart';
import 'package:pizza_store_app/pages/auth/PageVertifyEmail.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../../helpers/other.helper.dart';
import '../../layouts/MainLayout.dart';
import '../shipper/PagePendingOrder.dart';

class PageLogin extends StatefulWidget {
  PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _pwdFieldKey = GlobalKey<FormFieldState<String>>();

  final emailTxt = TextEditingController();

  final pwdTxt = TextEditingController();

  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Đăng nhập vào",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            Text(
              "tài khoản của bạn.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Hãy đăng nhập vô tài khoản của bạn",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: _emailFieldKey,
                    controller: emailTxt,
                    decoration: InputDecoration(labelText: "Địa chỉ Email"),
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return "Vui lòng điền số điện thoại";
                      }

                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );

                      if (!emailRegex.hasMatch(email)) {
                        return "Email không hợp lệ";
                      }

                      return null; // null means “no error”
                    },
                    onChanged: (value) {
                      if (_emailFieldKey.currentState != null) {
                        if (_emailFieldKey.currentState!.hasError) {
                          _emailFieldKey.currentState!.reset();
                        }
                      }
                      emailTxt.text = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    key: _pwdFieldKey,
                    controller: pwdTxt,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      helperText: "Tối thiểu 6 ký tự",
                      suffixIcon: IconButton(
                        // toggle password show/hide
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (pwd) {
                      if (pwd == null || pwd.isEmpty) {
                        return "Vui lòng điền mật khẩu";
                      }

                      if (pwd.length < 6) {
                        return "Vui lòng điền tối thiểu 6 ký tự";
                      }

                      return null; // null means “no error”
                    },
                    onChanged: (value) {
                      if (_pwdFieldKey.currentState != null) {
                        if (_pwdFieldKey.currentState!.hasError) {
                          _pwdFieldKey.currentState!.reset();
                        }
                      }
                      pwdTxt.text = value;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        loadingDialog();

                        AuthController.login(
                          email: emailTxt.text,
                          pwd: pwdTxt.text,
                        );
                      }
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đăng nhập",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bạn không có tài khoản? "),
                      GestureDetector(
                        child: Text(
                          "Hãy đăng ký",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        onTap: () => Get.off(() => PageRegister()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
