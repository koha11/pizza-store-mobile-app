import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/admin/user_admin/PageUpdateUserAdmin.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/app_user.model.dart';

import '../admin/item_admin/PageAddItemAdmin.dart';
import '../admin/item_admin/PageUpdateItemAdmin.dart';
import '../admin/user_admin/PageAddUserAdmin.dart';
import '../controllers/controller_item_admin.dart';
import '../controllers/controller_user_admin.dart';

final ItemAdminController _itemController = Get.find<ItemAdminController>();
final UserAdminController _adminUserController =
    Get.find<UserAdminController>();

Future<bool?> showConfirmDialog(BuildContext context, String message) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> showAddItemDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: const PageAddItemAdmin(),
        ),
      );
    },
  );
  if (result == true) {
    _itemController.fetchItems();
  }
}

Future<bool?> showDeleteItemDialog(BuildContext context, String itemName) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa món "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
  );
}

Future<void> showUpdateItemDialog(BuildContext context, Item item) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: PageUpdateItemAdmin(item: item),
        ),
      );
    },
  );
  if (result == true) {
    _itemController.fetchItems();
  }
}

Future<void> showAddUserDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: const PageAddUserAdmin(),
        ),
      );
    },
  );
  if (result == true) {
    _adminUserController.fetchUsersAdmin();
  }
}

Future<bool?> showDeleteUserDialog(BuildContext context, String userName) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa khách hàng "$userName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
  );
}

Future<void> showUpdateUserDialog(BuildContext context, AppUser user) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: PageUpdateUserAdmin(user: user),
        ),
      );
    },
  );
  if (result == true) {
    _adminUserController.fetchUsersAdmin();
  }
}
