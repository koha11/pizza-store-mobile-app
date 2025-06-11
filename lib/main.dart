import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_dashboard_manager.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart' show LocationBinding;
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/other.helper.dart';

void main() async {
  await dotenv.load();

  await Supabase.initialize(
    url: 'https://khzpqgeowpewrtfozksr.supabase.co',
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pizza Store',
      initialBinding: BindingsBuilder(() {
        BindingsHomePizzaStore().dependencies();
        BindingsShoppingCart().dependencies();
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
        BindingDashboardController().dependencies();
        BindingsOrderManagerController().dependencies();
      }),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(1, 74, 169, 29),
        ),
        useMaterial3: true,
      ),
      // home: PageAdmin(),
      home: GetBuilder(
        id: "user",
        init: UserController(),
        builder: (controller) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return checkRole(controller.appUser?.roleId ?? "");
        },
      ),
      // home: ManagerLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
