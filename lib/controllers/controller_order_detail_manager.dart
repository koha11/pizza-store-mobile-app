import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail_manager.model.dart';

class OrderDetailManagerController extends GetxController {
  final String orderId;

  OrderDetailManagerController({required this.orderId});

  CustomerOrder? orderDetail;

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
    orderDetail = await CustomerOrderSnapshot.getOrderDetail(orderId: orderId);
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
