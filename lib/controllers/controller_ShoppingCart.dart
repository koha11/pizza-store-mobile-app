import 'dart:math';

import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';

class ShoppingCartController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, OrderDetail> _cartItems = {};
  Map<String, bool> _checkedItems = {};
  String? _cartId;
  String? _customerId;

  Map<String, OrderDetail> get cartItems => _cartItems;

  String? get cartId => _cartId;

  Map<String, bool> get checkedItems => _checkedItems;
  static ShoppingCartController get() => Get.find();

  // Thêm getter để lấy tổng số lượng sản phẩm
  int get totalItems {
    int total = 0;
    _cartItems.forEach((key, item) {
      total += item.amount;
    });
    return total;
  }

  // Thêm getter để lấy tổng tiền
  int get totalAmount {
    int total = 0;
    _cartItems.forEach((key, item) {
      total += item.actualPrice * item.amount;
    });
    return total;
  }

  // Getter để lấy tổng số lượng sản phẩm đã chọn
  int get totalSelectedItems {
    int total = 0;
    _cartItems.forEach((key, item) {
      if (_checkedItems[key] == true) {
        total += item.amount;
      }
    });
    return total;
  }

  // Getter để lấy tổng tiền của các sản phẩm đã chọn
  int get totalSelectedAmount {
    int total = 0;
    _cartItems.forEach((key, item) {
      if (_checkedItems[key] == true) {
        total += item.actualPrice * item.amount;
      }
    });
    return total;
  }

  // Phương thức để lấy danh sách các mục đã chọn
  List<OrderDetail> getSelectedItems() {
    return _cartItems.entries
        .where((entry) => _checkedItems[entry.key] == true)
        .map((entry) => entry.value)
        .toList();
  }

  // Phương thức để đảo trạng thái check của một item
  void toggleItemCheck(String itemId) {
    _checkedItems[itemId] = !(_checkedItems[itemId] ?? false);
    update();
  }

  // Phương thức để  chọn/bỏ chọn tất cả items
  void checkAndUnAllItems() {
    // Kiểm tra xem tất cả items đã được chọn chưa
    bool allChecked = _cartItems.keys.every(
      (key) => _checkedItems[key] == true,
    );

    // Nếu tất cả đã được chọn thì bỏ chọn tất cả, ngược lại thì chọn tất cả
    _cartItems.forEach((key, _) {
      _checkedItems[key] = !allChecked;
    });
    update();
  }

  // Phương thức xóa các items đã được check
  Future<void> removeSelectedItems() async {
    if (_cartId == null) return;

    try {
      final itemsToRemove =
          _checkedItems.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

      for (var itemId in itemsToRemove) {
        await removeFromCart(itemId: itemId);
        _checkedItems.remove(itemId);
      }
      update();
    } catch (e) {
      print('Lỗi xóa item đã chọn: $e');
      await _loadCartItems();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return; // Không đăng nhập thì không làm gì cả
    _customerId = userId;

    _cartId = await CustomerOrderSnapshot.getCustomerCart(_customerId!);

    _cartId ??= await CustomerOrderSnapshot.createNewOrder(_customerId!);

    await _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (_cartId == null) return;
    _cartItems = await CustomerOrderSnapshot.getCartItems(_cartId!);
    _cartItems.forEach((key, _) {
      _checkedItems[key] = false;
    });
    update();
  }

  Future<void> addToCart(Item item, int amount) async {
    try {
      if (_customerId == null) {
        Get.snackbar(
          'Thông báo',
          'Bạn cần đăng nhập để sử dụng giỏ hàng',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      _cartId ??= await CustomerOrderSnapshot.createNewOrder(_customerId!);
      if (_cartItems.containsKey(item.itemId)) {
        final newAmount = _cartItems[item.itemId]!.amount + amount;
        _cartItems[item.itemId]!.amount = newAmount;
        await OrderDetailSnapshot.updateItemAmount(
          _cartId!,
          item.itemId,
          newAmount,
        );
      } else {
        await CustomerOrderSnapshot.addItemToCart(_cartId!, item, amount);
        await _loadCartItems();
      }
      update();
      Get.snackbar(
        'Thành công',
        'Đã thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error adding to cart: $e');
      await _loadCartItems();
      Get.snackbar(
        'Lỗi',
        'Không thể thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromCart({required String itemId}) async {
    if (_cartId == null) return;

    try {
      await OrderDetailSnapshot.deleteOrderDetail(
        orderId: _cartId!,
        itemId: itemId,
      );

      await _loadCartItems();
      update();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateItemAmount(String itemId, int newAmount) async {
    if (_cartId == null) return;

    try {
      if (newAmount <= 0) {
        await removeFromCart(itemId: itemId);
        return;
      }
      if (_cartItems.containsKey(itemId)) {
        _cartItems[itemId]!.amount = newAmount;
        update();
        await _updateAmountInDatabase(itemId, newAmount);
      }
    } catch (e) {
      print('Lỗi cập nhật số lượng: $e');
      await _loadCartItems();
    }
  }

  void incrementAmount(String itemId) {
    if (_cartItems.containsKey(itemId)) {
      _cartItems[itemId]!.amount++;
      update();
      _updateAmountInDatabase(itemId, _cartItems[itemId]!.amount);
    }
  }

  void decrementAmount(String itemId) {
    if (_cartItems.containsKey(itemId)) {
      if (_cartItems[itemId]!.amount > 1) {
        _cartItems[itemId]!.amount--;
        update();
        _updateAmountInDatabase(itemId, _cartItems[itemId]!.amount);
      } else {
        removeFromCart(itemId: itemId);
      }
    }
  }

  Future<void> _updateAmountInDatabase(String itemId, int newAmount) async {
    if (_cartId == null) return;

    try {
      await SupabaseSnapshot.update(
        table: 'order_detail',
        updateObject: {'amount': newAmount},
        equalObject: {'order_id': _cartId!, 'item_id': itemId},
      );
    } catch (e) {
      print('Lỗi cập nhật số lượng trong database: $e');

      await _loadCartItems();
    }
  }

  Future<void> placeOrder({
    required int shippingFee,
    required String address,
    required int totalAmount,
  }) async {
    if (_customerId == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng đăng nhập để đặt hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Tao 1 order moi co thong tin cua user hien tai + shipping fee + address + status=pending
      final newOrderId = await CustomerOrderSnapshot.placeOrder(
        customerId: _customerId!,
        address: address,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
      );

      if (newOrderId == null) {
        throw Exception('Không thể tạo đơn hàng mới');
      }

      // Chuyen nhung order detail dang co trang thai checked -> order moi
      for (var item in _checkedItems.entries) {
        if (item.value && _cartItems.containsKey(item.key)) {
          // tao order detail moi
          var newOrderDetail = _cartItems[item.key]!;
          newOrderDetail.orderId = newOrderId;
          await OrderDetailSnapshot.createOrderDetail(
            orderDetail: newOrderDetail,
          );

          // xoa order detail
          await OrderDetailSnapshot.deleteOrderDetail(
            itemId: item.key,
            orderId: _cartId!,
          );
        }
      }

      await _loadCartItems();
      _checkedItems.clear();
      update();

      Get.snackbar(
        'Thành công',
        'Đặt hàng thành công!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Lỗi khi đặt hàng: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể đặt hàng: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class BindingsShoppingcart extends Bindings {
  @override
  void dependencies() {
    Get.put<ShoppingCartController>(ShoppingCartController());
  }
}