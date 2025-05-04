import 'package:flutter/material.dart';
import 'package:pizza_store_app/helpers/session.helper.dart';

import '../controllers/controller_home.dart';

class PageProfile extends StatelessWidget {
  HomePizzaStoreController controller;

  PageProfile({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCurrUid(),
      builder:
          (context, snapshot) => SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 80),
                  Icon(Icons.person),
                  Text(
                    snapshot.data == null
                        ? "Bạn chưa đăng nhập"
                        : snapshot.data!,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
