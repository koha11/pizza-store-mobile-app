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

  int lastIndex = await SupabaseSnapshot.getLengthOfTable(table: tableName);

  String lastIndexText = lastIndex.toString();

  if (tableName == CustomerOrder.tableName) {
    id.write(DateTime.now());
    id.write("0" * (4 - lastIndexText.length));
  } else {
    id.write("0" * (6 - id.length - lastIndexText.length));
  }

  id.write(lastIndex + 1);

  return id.toString();
}
