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
    //print('ShoppingCartController initialized');
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      //print('Initializing cart...');
      // Tìm giỏ hàng đang pending của user UI0002
      final response = await _supabase
          .from('customer_order')
          .select('order_id')
          .eq('customer_id', 'UI0002')
          .eq('status', 'pending')
          .maybeSingle();

      if (response != null) {
        _currentOrderId = response['order_id'] as String;
       // print('Found existing cart: $_currentOrderId');
        await _loadCartItems();
      } else {
        print('No existing cart found, creating new one');
        await _createNewOrder();
      }
    } catch (e) {
      print('Error initializing cart: $e');
    }
  }

  Future<void> _createNewOrder() async {
    try {
      final orderId = 'OI' + DateTime.now().millisecondsSinceEpoch.toString();
      print('Creating new order: $orderId');

      await _supabase.from('customer_order').insert({
        'order_id': orderId,
        'customer_id': 'UI0002',
        'manager_id': null,
        'shipper_id': null,
        'order_time': null,
        'status': 'pending',
        'payment_method': false,
        'total_amount': 0,
        'shipping_fee': 0,
        'note': null,
        'shipping_address': null,
      });

      _currentOrderId = orderId;
     // print('New order created: $_currentOrderId');
      update();
    } catch (e) {
      print('Error creating new order: $e');
    }
  }

  Future<void> _loadCartItems() async {
    if (_currentOrderId == null) {
     // print('No current order ID, cannot load items');
      return;
    }

    try {
     // print('Loading items for order: $_currentOrderId');
      final response = await _supabase
          .from('order_detail')
          .select('*, item:item_id(item_id, item_name, item_image, price, description, category_id)')
          .eq('order_id', _currentOrderId!);

      //print('Raw response from Supabase: $response');

      final Map<String, OrderDetail> newItems = {};
      for (var item in response) {
        if (item != null) {
          try {
            final Map<String, dynamic> orderDetailData = Map<String, dynamic>.from(item);
           // print('Processing order detail data: $orderDetailData');

            final orderDetail = OrderDetail.fromJson(orderDetailData);
            newItems[orderDetail.itemId] = orderDetail;
            print('Successfully added item to cart: ${orderDetail.itemId}');
          } catch (e) {
            print('Error parsing item: $e');
            print('Item data: $item');
          }
        }
      }

      _cartItems = newItems;
      update(); // Cập nhật UI
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> addToCart(Item item, int amount) async {
    try {
      if (_currentOrderId == null) {
        print('No current order ID, creating new order');
        await _createNewOrder();
      }

      print('Adding item ${item.itemId} to cart');

      // Kiểm tra item đã tồn tại trong database
      final existingItem = await _supabase
          .from('order_detail')
          .select()
          .eq('order_id', _currentOrderId!)
          .eq('item_id', item.itemId)
          .maybeSingle();

      if (existingItem != null) {
        print('Item exists in database, updating amount');
        final currentAmount = existingItem['amount'] as int;
        await _supabase
            .from('order_detail')
            .update({'amount': currentAmount + amount})
            .eq('order_id', _currentOrderId!)
            .eq('item_id', item.itemId);
      } else {
        print('Item is new, inserting');
        await _supabase.from('order_detail').insert({
          'order_id': _currentOrderId,
          'item_id': item.itemId,
          'amount': amount,
          'actual_price': item.price,
          'note': null,
        });
      }

      // Load lại cart items sau khi thêm
      await _loadCartItems();
      update(); // hoặc update(['cart_items'])

      Get.snackbar(
        'Thành công',
        'Đã thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error adding to cart: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      update(); // hoặc update(['cart_items'])
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
      update(); // hoặc update(['cart_items'])
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