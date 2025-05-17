import 'dart:ui';

import 'package:flutter/material.dart';

enum OrderStatus {
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

  // Thêm phương thức để hiển thị text tương ứng
  String get displayText {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.finished:
        return 'Hoàn thành';
      // case OrderStatus.cancelled:
      //   return 'Đã hủy';
    }
  }

  // Thêm phương thức để lấy màu tương ứng
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.finished:
        return Colors.green;
      // case OrderStatus.cancelled:
      //   return Colors.red;
    }
  }
}