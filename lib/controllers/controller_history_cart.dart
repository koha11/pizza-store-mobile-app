import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryCartController extends GetxController {
  List<CustomerOrder> pendingOrders = []; // list chứa các đối tượng CustomerOderId

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
  }

  static HistoryCartController get() => Get.find();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchPendingOrders();
  }

  // Thêm phương thức reset
  void reset() {
    pendingOrders.clear();
    _isLoading = true;
    update();
  }

  Future<void> fetchPendingOrders() async {
    // Lấy danh sách đơn hàng có status = 'pending'
    pendingOrders = await CustomerOrderSnapshot.getOrders(
      equalObject: {"customer_id": UserController.get().appUser!.userId},
    );

    isLoading = false;
    update();
  }

  // lấy thông tin đơn hàng cự thể thông qua
  Future<List<OrderDetail>> fetchOrderDetails(String orderId) async {
    final map = await CustomerOrderSnapshot.getCartItems(orderId);
    return map.values
        .toList(); //Kết quả trả về là một Map<String, OrderDetail> với Key là itemIdHistoryCartController
  }
}

class BindingHistoryCartController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryCartController>(() => HistoryCartController());
  }
}