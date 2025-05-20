import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pizza_store_app/pages/PageLogin.dart';
import 'package:pizza_store_app/pages/PageVertifyEmail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/controller_home.dart';
import 'PageHome.dart';

class PageRegister extends StatelessWidget {
  PageRegister({super.key});

  final _formKey = GlobalKey<FormState>();
  final emailTxt = TextEditingController();
  final pwdTxt = TextEditingController();
  final rePwdTxt = TextEditingController();
  final nameTxt = TextEditingController();
  final phoneTxt = TextEditingController();

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
                    decoration: InputDecoration(labelText: "Mật khẩu"),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: rePwdTxt,
                    decoration: InputDecoration(labelText: "Nhập lai Mật khẩu"),
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
                      final supabase = Supabase.instance.client;
                      final AuthResponse res = await supabase.auth.signUp(
                        email: emailTxt.text,
                        password: pwdTxt.text,
                      );

                      final User? user = res.user;

                      if (user != null) {
                        await supabase.from('app_user').insert({
                          'user_id': user.id,
                          'user_name': nameTxt.text,
                          'phone_number': phoneTxt.text,
                          'user_email': user.email,
                          'role_id': "CUSTOMER",
                        });

                        Get.to(PageVerifyEmail(email: user.email!));
                      }
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
