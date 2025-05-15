import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/pages/PageOrderDetails.dart';
import 'package:pizza_store_app/pages/PagePendingOrder.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart' show LocationBinding;

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load();

  await Supabase.initialize(
    url: 'https://khzpqgeowpewrtfozksr.supabase.co',
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      initialBinding: BindingsBuilder(() {
        BindingsHomePizzaStore().dependencies();
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
      }),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(1, 74, 169, 29),
        ),
        useMaterial3: true,
      ),
      home: MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
