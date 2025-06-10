import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';

class ShoppingCartController extends GetxController {
  //final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, OrderDetail> _cartItems = {};
  Map<String, bool> _checkedItems = {};

  String? _customerId;
  CustomerOrder? _cart;

  Map<String, OrderDetail> get cartItems => _cartItems;

  CustomerOrder? get cart => _cart;

  Map<String, bool> get checkedItems => _checkedItems;
  static ShoppingCartController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
  }

  // Thêm getter để lấy tổng số lượng sản phẩm
  int get totalItems {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      total += od.amount;
    });
    return total;
  }

  // Thêm getter để lấy tổng tiền
  int get totalAmount {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      total += od.actualPrice * od.amount;
    });
    return total;
  }

  // Getter để lấy tổng số lượng sản phẩm đã chọn
  int get totalSelectedItems {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      if (_checkedItems[od.itemId] == true) {
        total += od.amount;
      }
    });
    return total;
  }

  // Getter để lấy tổng tiền của các sản phẩm đã chọn
  int get totalSelectedAmount {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      if (_checkedItems[od.itemId] == true) {
        total += od.actualPrice * od.amount;
      }
    });
    return total;
  }

  // Phương thức để lấy danh sách các mục đã chọn
  List<OrderDetail> getSelectedItems() {
    return _cart!.orderDetails
            ?.where((element) => _checkedItems[element.itemId] == true)
            .toList() ??
        [];
  }

  // Phương thức để đảo trạng thái check của một item
  void toggleItemCheck(String itemId) {
    _checkedItems[itemId] = !(_checkedItems[itemId] ?? false);
    update();
  }

  // Phương thức để  chọn/bỏ chọn tất cả items
  void checkAndUnAllItems() {
    // Kiểm tra xem tất cả items đã được chọn chưa
    // bool allChecked = _cart!.orderDetails?.keys.every(
    //   (key) => _checkedItems[key] == true,
    // );
    bool allChecked =
        _cart!.orderDetails?.every((od) => _checkedItems[od.itemId] == true) ??
        false;

    // Nếu tất cả đã được chọn thì bỏ chọn tất cả, ngược lại thì chọn tất cả
    _cart!.orderDetails?.forEach((od) {
      _checkedItems[od.itemId] = !allChecked;
    });
    update();
  }

  // Phương thức xóa các items đã được check
  Future<void> removeSelectedItems() async {
    if (_cart == null) return;

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

  Future<void> _initializeCart() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _customerId = userId;

    // Tìm giỏ hàng đang cart của user
    _cart = await CustomerOrderSnapshot.getCustomerCart(_customerId!);
    // Nếu không có giỏ hàng nào, tạo mới
    _cart ??= await CustomerOrderSnapshot.createNewOrder(_customerId!);
  }

  Future<void> _loadCart() async {
    _cart = await CustomerOrderSnapshot.getCustomerCart(_customerId!);
    for (var od in _cart!.orderDetails!) {
      _checkedItems[od.itemId] = false;
    }
    update();
  }

  Future<void> _loadCartItems() async {
    if (_cart == null) {
      // _cartItems.clear();
      _checkedItems.clear();
      update();
      return;
    }
    // _cartItems = _cart!.orderId as Map<String, OrderDetail>;
    for (var od in _cart!.orderDetails!) {
      _checkedItems[od.itemId] = false;
    }

    _cart = await CustomerOrderSnapshot.getCustomerCart(_customerId!);

    update();
  }

  Future<void> addToCart(Item item, int amount) async {
    try {
      if (_customerId == null) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          Get.snackbar(
            'Thông báo',
            'Bạn cần đăng nhập để sử dụng giỏ hàng',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        _customerId = userId;
        await _initializeCart();
      }

      if (_cart == null) {
        await _initializeCart();
      }

      OrderDetail? myOD;

      try {
        myOD = _cart!.orderDetails?.firstWhere(
          (od) => od.itemId == item.itemId,
        );
      } catch (e) {
        myOD = null;
      }

      if (myOD != null) {
        OrderDetailSnapshot.updateItemAmount(
          _cart!.orderId,
          item.itemId,
          ++myOD.amount,
        );
      } else {
        await CustomerOrderSnapshot.addItemToCart(_cart!.orderId, item, amount);
        await _loadCartItems();
      }

      // if(_cart?.orderDetails?.any((od) => od.itemId == item.itemId,) != null) {
      //   _cart.
      // }

      // if (_cartItems.containsKey(item.itemId)) {
      //   final newAmount = _cartItems[item.itemId]!.amount + amount;
      //   _cartItems[item.itemId]!.amount = newAmount;
      //   await OrderDetailSnapshot.updateItemAmount(
      //     _cart!.orderId,
      //     item.itemId,
      //     newAmount,
      //   );
      // } else {
      //   await CustomerOrderSnapshot.addItemToCart(_cart!.orderId, item, amount);
      //   await _loadCartItems();
      // }
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
    if (_cart == null) return;
    try {
      await OrderDetailSnapshot.deleteOrderDetail(
        orderId: _cart!.orderId,
        itemId: itemId,
      );

      await _loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  // Future<void> updateItemAmount(String itemId, int newAmount) async {
  //   if (_cart?.orderId == null) return;
  //
  //   try {
  //     if (newAmount <= 0) {
  //       await removeFromCart(itemId: itemId);
  //       return;
  //     }
  //     if (_cartItems.containsKey(itemId)) {
  //       _cartItems[itemId]!.amount = newAmount;
  //       update();
  //       await _updateAmountInDatabase(itemId, newAmount);
  //     }
  //   } catch (e) {
  //     print('Lỗi cập nhật số lượng: $e');
  //     await _loadCartItems();
  //   }
  // }

  Future<void> updateAmount(String itemId, bool isDes) async {
    final itemAmount =
        _cart!.orderDetails
            ?.firstWhere((element) => element.itemId == itemId)
            .amount;
    OrderDetailSnapshot.updateItemAmount(
      _cart!.orderId,
      itemId,
      isDes ? itemAmount! - 1 : itemAmount! + 1,
    );

    await _loadCart();
  }

  // Future<void> _updateAmountInDatabase(String itemId, int newAmount) async {
  //   if (_cart == null) return;
  //
  //   try {
  //     await SupabaseSnapshot.update(
  //       table: 'order_detail',
  //       updateObject: {'amount': newAmount},
  //       equalObject: {'order_id': _cart?.orderId, 'item_id': itemId},
  //     );
  //   } catch (e) {
  //     print('Lỗi cập nhật số lượng trong database: $e');
  //
  //     await _loadCartItems();
  //   }
  // }

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
            orderId: _cart!.orderId,
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

  void reset() {
    _cartItems.clear();
    _checkedItems.clear();
    _cart!.orderId;
    _customerId = null;
    _loadCartItems();
  }
}

class BindingsShoppingCart extends Bindings {
  @override
  void dependencies() {
    Get.put<ShoppingCartController>(ShoppingCartController());
  }
}