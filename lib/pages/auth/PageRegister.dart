import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';
import 'package:pizza_store_app/pages/auth/PageVertifyEmail.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/controller_auth.dart';
import '../../controllers/controller_home.dart';
import '../home/PageHome.dart';

class PageRegister extends StatefulWidget {
  PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final _formKey = GlobalKey<FormState>();

  final emailTxt = TextEditingController();

  final pwdTxt = TextEditingController();

  final rePwdTxt = TextEditingController();

  final nameTxt = TextEditingController();

  final phoneTxt = TextEditingController();

  bool _pwdObscure = true;

  bool _rePwdObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Đăng ký một",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            Text(
              "tài khoản cho bạn.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Hãy đăng ký một tài khoản của riêng bạn để có thể bắt đầu hưởng thức những món pizza tuyệt vời của chúng tôi.",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTxt,
                    decoration: InputDecoration(labelText: "Địa chỉ Email"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: nameTxt,
                    decoration: InputDecoration(labelText: "Tên của bạn"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: phoneTxt,
                    decoration: InputDecoration(labelText: "Số điện thoại"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: pwdTxt,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      suffixIcon: IconButton(
                        // toggle password show/hide
                        onPressed:
                            () => setState(() => _pwdObscure = !_pwdObscure),
                        icon: Icon(
                          _pwdObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _pwdObscure,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: rePwdTxt,
                    decoration: InputDecoration(
                      labelText: "Nhập lai Mật khẩu",
                      suffixIcon: IconButton(
                        // toggle password show/hide
                        onPressed:
                            () =>
                                setState(() => _rePwdObscure = !_rePwdObscure),
                        icon: Icon(
                          _rePwdObscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: true,
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
                      loadingDialog();

                      AuthController.register(
                        email: emailTxt.text,
                        pwd: pwdTxt.text,
                        name: nameTxt.text,
                        phone: phoneTxt.text,
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đăng ký",
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
                      Text("Bạn đã có tài khoản? "),
                      GestureDetector(
                        child: Text(
                          "Hãy đăng nhập",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        onTap: () => Get.off(PageLogin()),
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
