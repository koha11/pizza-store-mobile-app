import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/admin/item_admin/PageAddItem.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/controllers/controller_dashboard_manager.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/layouts/ManagerLayout.dart';
import 'package:pizza_store_app/pages/profile/PageChangeInfo.dart';
import 'package:pizza_store_app/pages/home/PageItem.dart';
import 'package:pizza_store_app/pages/PageOrderDetails.dart';
import 'package:pizza_store_app/pages/order_manager/PageOrdersList.dart';
import 'package:pizza_store_app/pages/PagePendingOrder.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart' show LocationBinding;

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
      title: 'Flutter Demo',
      initialBinding: BindingsBuilder(() {
        BindingsHomePizzaStore().dependencies();
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
        BindingDashboardDashboardController().dependencies();
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
