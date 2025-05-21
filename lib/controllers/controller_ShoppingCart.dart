import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';


class ShoppingCartController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, OrderDetail> _cartItems = {};
  Map<String, bool> _checkedItems = {};
  String? _currentOrderId;

  Map<String, OrderDetail> get cartItems => _cartItems;
  String? get currentOrderId => _currentOrderId;
  Map<String, bool> get checkedItems => _checkedItems;

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
    bool allChecked = _cartItems.keys.every((key) => _checkedItems[key] == true);
    
    // Nếu tất cả đã được chọn thì bỏ chọn tất cả, ngược lại thì chọn tất cả
    _cartItems.forEach((key, _) {
      _checkedItems[key] = !allChecked;
    });
    update();
  }

  // // Phương thức để check tất cả items
  // void checkAllItems() {
  //   _cartItems.forEach((key, _) {
  //     _checkedItems[key] = true;
  //   });
  //   update();
  // }
  //
  // // Phương thức để uncheck tất cả items
  // void uncheckAllItems() {
  //   _cartItems.forEach((key, _) {
  //     _checkedItems[key] = false;
  //   });
  //   update();
  // }

  // Phương thức xóa các items đã được check
  Future<void> removeSelectedItems() async {
    if (_currentOrderId == null) return;

    try {
      final itemsToRemove = _checkedItems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      for (var itemId in itemsToRemove) {
        await removeFromCart(itemId);
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
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return; // Không đăng nhập thì không làm gì cả
      _currentOrderId = await HelperCart.getPendingCustomerOrder(userId);
      if (_currentOrderId == null) {
        _currentOrderId = await CustomerOrderSnapshot.createNewOrder(userId);
      }
      await _loadCartItems();
    } catch (e) {
      print('Lỗi khởi tạo giỏ hàng: $e');
    }
  }

  Future<void> _loadCartItems() async {
    if (_currentOrderId == null) return;
    _cartItems = await CustomerOrderSnapshot.getCartItems(_currentOrderId!);
    _cartItems.forEach((key, _) {
      _checkedItems[key] = false;
    });
    update();
  }

  Future<void> addToCart(Item item, int amount) async {
    try {
      final userId = Get.find<UserController>().appUser?.userId;
      if (userId == null) {
        // Có thể show dialog yêu cầu đăng nhập
        Get.snackbar('Thông báo', 'Bạn cần đăng nhập để sử dụng giỏ hàng');
        return;
      }
      if (_currentOrderId == null) {
        _currentOrderId = await CustomerOrderSnapshot.createNewOrder(userId);
      }

      if (_cartItems.containsKey(item.itemId)) {
        final newAmount = _cartItems[item.itemId]!.amount + amount;
        _cartItems[item.itemId]!.amount = newAmount;
        await OrderDetailSnapshot.updateItemAmount(_currentOrderId!, item.itemId, newAmount);
      } else {
        await CustomerOrderSnapshot.addItemToCart(_currentOrderId!, item, amount);
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
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (_currentOrderId == null) return;

    try {
      await _supabase
          .from('order_detail')
          .delete()
          .eq('order_id', _currentOrderId!)
          .eq('item_id', itemId);

      await _loadCartItems();
      update();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateItemAmount(String itemId, int newAmount) async {
    if (_currentOrderId == null) return;

    try {
      if (newAmount <= 0) {
        await removeFromCart(itemId);
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
        removeFromCart(itemId);
      }
    }
  }

  Future<void> _updateAmountInDatabase(String itemId, int newAmount) async {
    if (_currentOrderId == null) return;

    try {
      await _supabase
          .from('order_detail')
          .update({'amount': newAmount})
          .eq('order_id', _currentOrderId!)
          .eq('item_id', itemId);
    } catch (e) {
      print('Lỗi cập nhật số lượng trong database: $e');
      await _loadCartItems();
    }
  }
  Future<void> placeOrder() async {
    final userId = Get.find<UserController>().appUser?.userId;
    if (userId == null) return;
    final oldOrderId = _currentOrderId;
    // Tính tổng tiền từ giỏ hàng hiện tại
    int totalAmount = _cartItems.values.fold(0, (sum, item) => sum + (item.actualPrice * item.amount));
    // Cập nhật tổng tiền cho đơn hàng cũ (vừa đặt)
    if (oldOrderId != null) {
      await CustomerOrderSnapshot.updateOrderStatusAndTotal(oldOrderId, "pending", totalAmount);
    }
    // Tạo orderId mới cho giỏ hàng tiếp theo
    final newOrderId = await CustomerOrderSnapshot.createNewOrder(userId);
    _currentOrderId = newOrderId;
    await _loadCartItems();
    update();
  }
}

class BindingsShoppingcart extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShoppingCartController>(() => ShoppingCartController());
  }
}