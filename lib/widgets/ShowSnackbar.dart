import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackBar({required String desc, required bool success}) {
  Get.snackbar(
    "",
    "",
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.white,
    duration: Duration(seconds: 1),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    borderRadius: 10,

    titleText: Text(
      success ? "Thành công" : "Lỗi",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: success ? Colors.green : Colors.red,
      ),
    ),

    messageText: Text(
      desc,
      style: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );
}
