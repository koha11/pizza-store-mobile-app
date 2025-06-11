import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class HistoryCartController extends GetxController {
  List<CustomerOrder> pendingOrders =
      []; // list chứa các đối tượng CustomerOderId

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
      sortObject: {"order_time": false},
      orObject: [
        {"status": OrderStatus.pending.name},
        {"status": OrderStatus.shipping.name},
        {"status": OrderStatus.finished.name},
      ],
    );

    isLoading = false;
    update();
  }
}

class BindingHistoryCartController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryCartController>(() => HistoryCartController());
  }
}
