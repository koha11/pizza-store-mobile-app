import 'dart:ui';

import 'package:flutter/material.dart';

enum OrderStatus {
  confirmed,
  pending,
  shipping,
  finished;
  // cancelled;

  // Thêm phương thức chuyển đổi từ String sang OrderStatus
  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending, // Giá trị mặc định nếu không khớp
    );
  }

  static String? fromDisplayTextToName(String status) {
    if (status == "Tất cả") return null;
    try {
      final orderStatus = OrderStatus.values.firstWhere(
        (e) => e.displayText == status,
      );
      return orderStatus.name;
    } catch (e) {
      return null;
    }
  }

  // Thêm phương thức để hiển thị text tương ứng
  String get displayText {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.pending:
        return 'Đang chờ';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.finished:
        return 'Đã hoàn thành';
      // case OrderStatus.cancelled:
      //   return 'Đã hủy';
    }
  }

  // Thêm phương thức để lấy màu tương ứng
  Color get color {
    switch (this) {
      case OrderStatus.confirmed:
        return Colors.redAccent;
      case OrderStatus.pending:
        return Colors.purple;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.finished:
        return Colors.green;
      // case OrderStatus.cancelled:
      //   return Colors.red;
    }
  }
}
