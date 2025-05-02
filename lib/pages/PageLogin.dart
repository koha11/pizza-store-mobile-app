import 'package:flutter/material.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/pages/PageHome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class PageLogin extends StatelessWidget {
  PageLogin({super.key});

  final _formKey = GlobalKey<FormState>();
  final emailTxt = TextEditingController();
  final pwdTxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login to your",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            Text(
              "account.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Please sign in to your account",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailTxt,
                      decoration: InputDecoration(labelText: "Email Address"),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: pwdTxt,
                      decoration: InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () async {
                        final supabase = Supabase.instance.client;
                        final AuthResponse res = await supabase.auth
                            .signInWithPassword(
                              email: emailTxt.text,
                              password: pwdTxt.text,
                            );

                        final Session? session = res.session;
                        final User? user = res.user;

                        print(res);

                        if (user != null) {
                          Get.to(PageHome(), binding: BindingsHomePizzaStore());
                        }
                      },
                      child: Text("Sign In"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
