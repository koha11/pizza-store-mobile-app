import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/category.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/variant_type.model.dart';

import '../admin/PageAdmin.dart';
import '../controllers/controller_ShoppingCart.dart';
import '../controllers/controller_dashboard_manager.dart';
import '../controllers/controller_home.dart';
import '../controllers/controller_user.dart';
import '../layouts/MainLayout.dart';
import '../layouts/ManagerLayout.dart';
import '../models/variant.model.dart';
import '../pages/shipper/PagePendingOrder.dart';

Future<String> generateId({required String tableName}) async {
  StringBuffer id = StringBuffer();

  switch (tableName) {
    case Item.tableName:
      id.write("I");
      break;

    case Category.tableName:
      id.write("CI");
      break;

    case Variant.tableName:
      id.write("VI");
      break;

    case CustomerOrder.tableName:
      id.write("OI");
      break;

    case VariantType.tableName:
      id.write("VTI");
      break;
  }

  if (tableName == CustomerOrder.tableName) {
    DateTime today = DateTime.now();
    DateTime start = DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime end = DateTime(today.year, today.month, today.day, 23, 59, 59);

    int lastIndex = await SupabaseSnapshot.getLengthOfTable(
      table: tableName,
      ltObject: {"order_time": end.toIso8601String()},
      gtObject: {"order_time": start.toIso8601String()},
    );

    String lastIndexText = lastIndex.toString();
    id.write(formatDateString(datetime: DateTime.now()));
    id.write("0" * (4 - lastIndexText.length));
    id.write(lastIndex + 1);
  } else {
    int lastIndex = await SupabaseSnapshot.getLengthOfTable(table: tableName);

    String lastIndexText = lastIndex.toString();
    id.write("0" * (6 - id.length - lastIndexText.length));
    id.write(lastIndex + 1);
  }

  return id.toString();
}

String formatDateString({required DateTime datetime, bool onlyDate = true}) {
  StringBuffer dateString = StringBuffer();

  int year = datetime.year;
  int month = datetime.month;
  int day = datetime.day;
  int hour = datetime.hour;
  int minute = datetime.minute;
  int second = datetime.second;

  if (onlyDate) {
    String dayStr = "$day".length == 1 ? "0$day" : "$day";
    dateString.write(dayStr);

    String monthStr = "$month".length == 1 ? "0$month" : "$month";
    dateString.write(monthStr);

    String yearStr = "$year".substring(2);
    dateString.write(yearStr);
  }

  return dateString.toString();
}

String formatDateTime(DateTime? dt) {
  if (dt == null) return "—";
  return DateFormat('dd/MM/yyyy HH:mm').format(dt);
}

String formatMoney({required int money}) {
  final locale = "vi_VN";
  final symbol = "₫";
  final currencyFormat = NumberFormat.currency(locale: locale, symbol: symbol);

  return currencyFormat.format(money);
}

String formatShortCurrency(int amount) {
  if (amount >= 1000000) {
    double millions = amount / 1000000;
    return '${millions % 1 == 0 ? millions.toStringAsFixed(0) : millions.toStringAsFixed(1)}tr';
  } else if (amount >= 1000) {
    double thousands = amount / 1000;
    return '${thousands % 1 == 0 ? thousands.toStringAsFixed(0) : thousands.toStringAsFixed(1)}K';
  } else {
    return amount.toString();
  }
}

Widget checkRole(String role) {
  switch (role) {
    case "ADMIN":
      return PageAdmin();
    case "MANAGER":
      return ManagerLayout();
    case "SHIPPER":
      return PagePendingOrder();
    default:
      return MainLayout();
  }
}

BindingsBuilder? getRoleControllerBindings(String role) {
  switch (role) {
    case "ADMIN":
      return BindingsBuilder(() {
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
      });
    case "MANAGER":
      return BindingsBuilder(() {
        BindingDashboardController().dependencies();
      });
    case "SHIPPER":
      return BindingsBuilder(() {
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
      });
    default:
      return BindingsBuilder(() {
        LocationBinding().dependencies();
        BindingsUserController().dependencies();
        BindingsHomePizzaStore().dependencies();
        BindingsShoppingCart().dependencies();
      });
  }
}
