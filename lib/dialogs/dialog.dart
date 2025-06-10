import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/admin/user_admin/PageUpdateUser.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/app_user.model.dart';

import '../admin/item_admin/PageAddItem.dart';
import '../admin/item_admin/PageUpdateItem.dart';
import '../admin/user_admin/PageAddUser.dart';
import '../controllers/controller_admin_user.dart';
import '../controllers/controller_item.dart';

final ItemController _itemController = Get.find<ItemController>();
final AdminUserController _adminUserController = Get.find<AdminUserController>();

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

void showSnackBar(BuildContext context,
    {required String message, Color? backgroundColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ),
  );
}

Future<void> showAddItemDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: const PageAddItem(),
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
    builder: (context) => AlertDialog(
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
          child: PageUpdateItem(item: item),
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
          child: const PageAddUser(),
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
    builder: (context) => AlertDialog(
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
          child: PageUpdateUser(user: user),
        ),
      );
    },
  );
  if (result == true) {
    _adminUserController.fetchUsersAdmin();
  }
}
