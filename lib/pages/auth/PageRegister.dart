import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';

import '../../controllers/controller_auth.dart';

class PageRegister extends StatefulWidget {
  PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _pwdFieldKey = GlobalKey<FormFieldState<String>>();
  final _rePwdFieldKey = GlobalKey<FormFieldState<String>>();

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
                    key: _nameFieldKey,
                    controller: nameTxt,
                    decoration: InputDecoration(labelText: "Tên của bạn"),
                    validator: (name) {
                      if (name == null || name.isEmpty) {
                        return "Vui lòng điền số điện thoại";
                      }

                      return null; // null means “no error”
                    },
                    onChanged: (value) {
                      if (_nameFieldKey.currentState != null) {
                        if (_nameFieldKey.currentState!.hasError) {
                          _nameFieldKey.currentState!.reset();
                        }
                      }
                      nameTxt.text = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    key: _phoneFieldKey,
                    controller: phoneTxt,
                    decoration: InputDecoration(labelText: "Số điện thoại"),
                    validator: (phone) {
                      if (phone == null || phone.isEmpty) {
                        return "Vui lòng điền số điện thoại";
                      }

                      final phoneRegex = RegExp(r'^0[0-9]{9}$');

                      if (phone.length < 10 || !phoneRegex.hasMatch(phone)) {
                        return "Số điện thoại không hợp lệ";
                      }

                      return null; // null means “no error”
                    },
                    onChanged: (value) {
                      if (_phoneFieldKey.currentState != null) {
                        if (_phoneFieldKey.currentState!.hasError) {
                          _phoneFieldKey.currentState!.reset();
                        }
                      }
                      phoneTxt.text = value;
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
                        onPressed:
                            () => setState(() => _pwdObscure = !_pwdObscure),
                        icon: Icon(
                          _pwdObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _pwdObscure,
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
                  SizedBox(height: 10),
                  TextFormField(
                    key: _rePwdFieldKey,
                    controller: rePwdTxt,
                    decoration: InputDecoration(
                      labelText: "Nhập lai Mật khẩu",
                      helperText: "Tối thiểu 6 ký tự",
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
                    obscureText: _rePwdObscure,
                    validator: (rePwd) {
                      if (rePwd == null || rePwd.isEmpty) {
                        return "Vui lòng điền nhập lại mật khẩu";
                      }

                      if (rePwd.length < 6) {
                        return "Vui lòng điền tối thiểu 6 ký tự";
                      }

                      if (rePwd != pwdTxt.text) {
                        return "Mật khẩu không trùng khớp";
                      }

                      return null; // null means “no error”
                    },
                    onChanged: (value) {
                      if (_rePwdFieldKey.currentState != null) {
                        if (_rePwdFieldKey.currentState!.hasError) {
                          _rePwdFieldKey.currentState!.reset();
                        }
                      }
                      rePwdTxt.text = value;
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

                        AuthController.register(
                          email: emailTxt.text,
                          pwd: pwdTxt.text,
                          name: nameTxt.text,
                          phone: phoneTxt.text,
                        );
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
                        onTap: () => Get.off(() => PageLogin()),
                      ),
                      SizedBox(height: 20),
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
