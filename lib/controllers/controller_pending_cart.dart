import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';

class ShoppingCartPending extends GetxController {
  List<CustomerOrder> pendingOrders =
      []; // list chứa các đối tượng CustomerOderId
  Map<String, List<OrderDetail>> orderDetailsMap = {}; // orderid

  Future<void> fetchPendingOrders(String userId) async {
    // Lấy danh sách đơn hàng có status = 'pending'
    final data = await supabase
        .from('customer_order')
        .select()
        .eq('customer_id', userId)
        .eq('status', 'pending');

    //chuyển đổi mỗi phần tử JSON thành một đối tượng CustomerOrder thông qua hàm fromJson
    pendingOrders = data.map((e) => CustomerOrder.fromJson(e)).toList();

    for (var order in pendingOrders) {
      var myOrderDetail = await OrderDetailSnapshot.getOrderDetailsByOrderId(
        orderId: order.orderId,
      );
      orderDetailsMap.assign(
        order.orderId,
        myOrderDetail,
      ); //Lưu chi tiết đơn hàng vào Map với key là orderId (assign gán giá trị mới cho map )
    }

    update();
  }

  // lấy thông tin đơn hàng cự thể thông qua
  Future<List<OrderDetail>> fetchOrderDetails(String orderId) async {
    final map = await CustomerOrderSnapshot.getCartItems(orderId);
    return map.values
        .toList(); //Kết quả trả về là một Map<String, OrderDetail> với Key là itemId
  }
}

class BindingShoppingCartPending extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShoppingCartPending>(() => ShoppingCartPending());
  }
}