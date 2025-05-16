import 'package:get/get.dart';
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

  // Thêm getter để lấy tổng tiền đã có bên page shopping cart
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

  // Phương thức để toggle trạng thái check của một item
  void toggleItemCheck(String itemId) {
    _checkedItems[itemId] = !(_checkedItems[itemId] ?? false);
    update();
  }

  // Phương thức để check tất cả items
  void checkAllItems() {
    _cartItems.forEach((key, _) {
      _checkedItems[key] = true;
    });
    update();
  }

  // Phương thức để uncheck tất cả items
  void uncheckAllItems() {
    _cartItems.forEach((key, _) { // key,_ tại không cần check value
      _checkedItems[key] = false;
    });
    update();
  }

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
      _currentOrderId = await SupabaseHelper.getPendingOrderId('UI0002');
      if (_currentOrderId == null) {
        _currentOrderId = await CustomerOrderSnapshot.createNewOrder('UI0002');
      }
      await _loadCartItems();
    } catch (e) {
      print('Lỗi khởi tạo giỏ hàng: $e');
    }
  }

  Future<void> _loadCartItems() async {
    if (_currentOrderId == null) return;
    _cartItems = await CustomerOrderSnapshot.getCartItems(_currentOrderId!);
    // Khởi tạo trạng thái check cho các items mới
    _cartItems.forEach((key, _) {
      _checkedItems[key] = false;
    });
    update();
  }

  Future<void> addToCart(Item item, int amount) async {
    try {
      if (_currentOrderId == null) {
        _currentOrderId = await CustomerOrderSnapshot.createNewOrder('UI0002');
      }

      if (_cartItems.containsKey(item.itemId)) {
        final newAmount = _cartItems[item.itemId]!.amount + amount;
        _cartItems[item.itemId]!.amount = newAmount;
        await OrderDetailSnapshot.updateItemAmount(_currentOrderId!, item.itemId, newAmount);
      } else {
        _cartItems[item.itemId] = OrderDetail(
          orderId: _currentOrderId!,
          itemId: item.itemId,
          amount: amount,
          actualPrice: item.price,
          item: item,
        );
        await OrderDetailSnapshot.addItemToCart(_currentOrderId!, item, amount);
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
      update(); // hoặc update(['cart_items'])
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }
  // update số lượng khi thêm vào giỏ hàng
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

  //  phương thức tăng số lượng
  void incrementAmount(String itemId) {
    if (_cartItems.containsKey(itemId)) {
      _cartItems[itemId]!.amount++;
      update();
      _updateAmountInDatabase(itemId, _cartItems[itemId]!.amount);
    }
  }

  // phương thức giảm số lượng
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

  // Phương thức private cập nhật số lượng trong database
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
      await _loadCartItems(); // Load lại dữ liệu nếu có lỗi
    }
  }
}

class BindingsShoppingcart extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShoppingCartController>(() => ShoppingCartController());
  }
}