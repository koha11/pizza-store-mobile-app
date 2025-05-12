import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingCartController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, OrderDetail> _cartItems = {};
  String? _currentOrderId;

  Map<String, OrderDetail> get cartItems => _cartItems;
  String? get currentOrderId => _currentOrderId;
  
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

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Tìm order_id của giỏ hàng hiện tại
      final response = await _supabase
          .from('customer_order')
          .select('order_id')
          .eq('customer_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (response != null) {
        _currentOrderId = response['order_id'] as String;
        await _loadCartItems();
      } else {
        // Tạo order mới nếu chưa có
        await _createNewOrder();
      }
    } catch (e) {
      print('Error initializing cart: $e');
      await _createNewOrder();
    }
  }

  Future<void> _createNewOrder() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase.from('customer_order').insert({
        'customer_id': user.id,
        'status': 'pending',
        'order_time': DateTime.now().toIso8601String(),
        'total': 0,
        'shipping_fee': 0,
        'payment_method': false,
        'shipping_address': '',
      }).select('order_id').single();

      _currentOrderId = response['order_id'] as String;
      update();
    } catch (e) {
      print('Error creating new order: $e');
    }
  }

  Future<void> _loadCartItems() async {
    if (_currentOrderId == null) return;

    try {
      final response = await _supabase
          .from('order_detail')
          .select('*, item(*)')
          .eq('order_id', _currentOrderId!);

      _cartItems = {};
      for (var item in response) {
        _cartItems[item['item_id'] as String] = OrderDetail.fromJson(item);
      }
      update(['cart', 'badge']); // Thêm id 'badge' để cập nhật badge
    } catch (e) {
      print('lỗi cập nhật cart items: $e');
    }
  }

  Future<void> addToCart(Item item, int amount) async {
    if (_currentOrderId == null) {
      await _createNewOrder();
    }

    try {
      final existingItem = _cartItems[item.itemId];
      if (existingItem != null) {
        // Cập nhật số lượng nếu sản phẩm đã có trong giỏ
        await _supabase
            .from('order_detail')
            .update({'amount': existingItem.amount + amount})
            .eq('order_id', _currentOrderId!)
            .eq('item_id', item.itemId);
      } else {
        // Thêm sản phẩm mới vào giỏ
        await _supabase.from('order_detail').insert({
          'order_id': _currentOrderId,
          'item_id': item.itemId,
          'amount': amount,
          'actual_price': item.price,
          'note': '',
        });
      }

      await _loadCartItems();
      update(['cart', 'badge']); // Thêm id 'badge'
    } catch (e) {
      print('Error adding to cart: $e');
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
      update(['cart', 'badge']); // Thêm id 'badge'
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

      await _supabase
          .from('order_detail')
          .update({'amount': newAmount})
          .eq('order_id', _currentOrderId!)
          .eq('item_id', itemId);

      await _loadCartItems();
      update(['cart', 'badge']); // Thêm id 'badge'
    } catch (e) {
      print('Error updating item amount: $e');
    }
  }

  Future<void> clearCart() async {
    if (_currentOrderId == null) return;

    try {
      await _supabase
          .from('order_detail')
          .delete()
          .eq('order_id', _currentOrderId!);

      await _loadCartItems();
      update(['cart', 'badge']); // Thêm id 'badge'
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}

class BindingsShoppingcart extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShoppingCartController>(() => ShoppingCartController());
  }
}