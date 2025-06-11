import 'package:flutter/material.dart';
import 'package:get/get.dart';

void loadingDialog() {
  Get.dialog(
    Center(child: CircularProgressIndicator()),
    barrierDismissible: false, // prevent closing by tapping outside
  );
}
