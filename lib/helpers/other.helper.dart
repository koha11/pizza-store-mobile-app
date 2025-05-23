import 'package:flutter/cupertino.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/category.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/variant_type.model.dart';

import '../models/variant.model.dart';

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

String formatMoney({required int money}) {
  StringBuffer moneyStr = StringBuffer();
  final moneyChars = Characters(money.toString());

  for (int i = 1; i <= moneyChars.length; i++) {
    moneyStr.write(
      "${moneyChars.elementAt(moneyChars.length - i)}${i % 3 == 0 && i != moneyChars.length ? "," : ""}",
    );
  }

  final moneyStrChars = Characters(moneyStr.toString());
  moneyStr.clear();

  for (int i = moneyStrChars.length - 1; i >= 0; i--) {
    moneyStr.write(moneyStrChars.elementAt(i));
  }

  moneyStr.write(" VNĐ");

  return moneyStr.toString();
}