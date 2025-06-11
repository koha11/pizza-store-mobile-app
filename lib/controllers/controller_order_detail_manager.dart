import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class OrderDetailManagerController extends GetxController {
  final String orderId;

  OrderDetailManagerController({required this.orderId});

  CustomerOrder? orderDetail;
  List<AppUser> shipperList = [];

  bool isLoading = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getOrderDetail();
    fetchShippers();
  }

  Future<void> getOrderDetail() async {
    isLoading = true;
    update();
    orderDetail = await CustomerOrderSnapshot.getOrderDetail(orderId: orderId);
    isLoading = false;
    update();
  }

  Future<void> fetchShippers() async {
    isLoading = true;
    update();
    shipperList = await AppUserSnapshot.getAppUsers(
      equalObject: {"role_id": "SHIPPER", "is_active": true},
    );
    isLoading = false;
    update();
  }

  Future<void> assignShipperToOrder({required String shipperId}) async {
    isLoading = true;
    update();
    await CustomerOrderSnapshot.assignShipperToOrder(
      orderId: orderId,
      shipperId: shipperId,
      managerId: supabase.auth.currentUser!.id,
    );

    await getOrderDetail();

    OrdersManagerController ordersController = OrdersManagerController.get();
    await ordersController.getOrders();
    isLoading = false;
    update();
  }
}

class BindingOrderDetailManager extends Bindings {
  final String orderId;

  BindingOrderDetailManager(this.orderId);

  @override
  void dependencies() {
    Get.lazyPut(() => OrderDetailManagerController(orderId: orderId));
  }
}
