import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_order_info.dart';

class OrderController extends GetxController {
  final RxList<CustomerOrderInfo> pendingOrders = <CustomerOrderInfo>[].obs;
  final RxList<CustomerOrderInfo> historyOrders = <CustomerOrderInfo>[].obs;
  final RxBool isLoading = true.obs;
  final RxString shipperId = ''.obs;
  final RxString shipperName = ''.obs;
  final RxString shipperPhone = ''.obs;

  final _supabase = Supabase.instance.client;
  static const _orderTable = 'customer_order';
  static const _userTable = 'app_user';

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      fetchPendingOrders(),
      fetchHistoryOrders(),
    ]);
  }

  Stream<List<CustomerOrderInfo>> get pendingOrderStream => _supabase
      .from(_orderTable)
      .stream(primaryKey: ['order_id'])
      .order('order_time', ascending: false)
      .asyncMap((_) => _fetchOrdersWithDetails(
    filter: 'status.eq.pending,status.eq.shipping',
  ));

  Stream<List<CustomerOrderInfo>> get historyOrderStream => _supabase
      .from(_orderTable)
      .stream(primaryKey: ['order_id'])
      .order('order_time', ascending: false)
      .asyncMap((_) => _fetchOrdersWithDetails(
    filter: 'status.eq.finished,status.eq.cancelled',
  ));

  Future<List<CustomerOrderInfo>> _fetchOrdersWithDetails({
    required String filter,
  }) async {
    try {
      final response = await _supabase.from(_orderTable).select('''
        order_id,
        shipping_address,
        shipper_id,
        order_time,
        status,
        ${_userTable}!customer_order_customer_id_fkey (
          user_name,
          phone_number
        ),
        shipper:${_userTable}!customer_order_shipper_id_fkey (
          user_id,
          user_name,
          phone_number
        )
      ''').or(filter).order('order_time', ascending: false);

      final orders = (response as List).map((json) => CustomerOrderInfo.fromJson(json)).toList();
      if (response.isEmpty) return [];
      shipperId.value = orders[0].shipperId;
      shipperName.value = orders[0].shipperName;
      shipperPhone.value = orders[0].shipperPhone;
      return orders;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  Future<void> fetchPendingOrders() async {
    await _fetchAndSetOrders(
      filter: 'status.eq.pending,status.eq.shipping',
      targetList: pendingOrders,
    );
  }

  Future<void> fetchHistoryOrders() async {
    await _fetchAndSetOrders(
      filter: 'status.eq.finished,status.eq.cancelled',
      targetList: historyOrders,
    );
  }

  Future<void> _fetchAndSetOrders({
    required String filter,
    required RxList<CustomerOrderInfo> targetList,
  }) async {
    try {
      isLoading.value = true;
      final orders = await _fetchOrdersWithDetails(filter: filter);
      targetList.assignAll(orders);
    } catch (e) {
      debugPrint("Error in _fetchAndSetOrders: $e");
      targetList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}