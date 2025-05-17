import 'package:get/get.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class OrdersManagerController extends GetxController {
  List<CustomerOrder>? orders;
  bool isLoading = false;
}
