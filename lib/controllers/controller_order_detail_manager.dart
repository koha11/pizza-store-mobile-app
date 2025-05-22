import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/order_detail_manager.model.dart';

class OrderDetailManagerController extends GetxController {
  final String orderId;

  OrderDetailManagerController({required this.orderId});

  OrderDetailManager? orderDetailManager;

  bool isLoading = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getOrderDetail();
  }

  Future<void> getOrderDetail() async {
    isLoading = true;
    update();
    orderDetailManager = await OrderDetailManagerSnapshot.getOrderDetail(
      orderId: orderId,
    );
    isLoading = false;
    update();
  }

  Future<void> acceptOrder() async {
    isLoading = true;
    update();
    await SupabaseSnapshot.update(
      table: "customer_order",
      updateObject: {
        "status": "confirmed",
        "accept_time": DateTime.now().toIso8601String(),
        "manager_id": supabase.auth.currentUser!.id,
      },
      equalObject: {"order_id": orderId},
    );
    isLoading = false;
    update();
    await getOrderDetail();
  }

  Future<void> updateShipperToOrder({required String shipperId}) async {
    isLoading = true;
    update();
    await SupabaseSnapshot.update(
      table: "customer_order",
      updateObject: {"shipper_id": shipperId, "status": "shipping"},
      equalObject: {"order_id": orderId},
    );
    isLoading = false;
    update();
    await getOrderDetail();
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
