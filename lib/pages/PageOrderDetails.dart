import 'package:flutter/material.dart';
import 'package:pizza_store_app/models/order_items.dart';
import 'package:pizza_store_app/pages/PageDeliveryFailed.dart';
import 'package:pizza_store_app/pages/PageDeliverySuccessful.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageOrderDetails extends StatefulWidget {
  final String orderId;

  const PageOrderDetails({super.key, required this.orderId});

  @override
  State<PageOrderDetails> createState() => _PageOrderDetailsState();
}

class _PageOrderDetailsState extends State<PageOrderDetails> {
  final supabase = Supabase.instance.client;
  List<OrderDetailWithInfo> orderDetails = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await supabase
          .from('order_detail')
          .select('''
          amount,
          actual_price,
          items:item_id (item_name, price),
          customer_order:order_id (
            shipping_fee,
            shipping_address,
            app_user:customer_id (user_name, phone_number)
          )
        ''')
          .eq('order_id', widget.orderId);

      if (response.isEmpty) {
        throw Exception('Không tìm thấy đơn hàng');
      }

      final List<OrderDetailWithInfo> details = [];
      for (final item in response) {
        final orderData = item['customer_order'] as Map<String, dynamic>? ?? {};
        final userData = orderData['app_user'] as Map<String, dynamic>? ?? {};
        final itemData = item['items'] as Map<String, dynamic>? ?? {};

        details.add(OrderDetailWithInfo(
          customerName: userData['user_name']?.toString() ?? 'Không có tên',
          phoneNumber: userData['phone_number']?.toString() ?? 'Không có số điện thoại',
          itemName: itemData['item_name']?.toString() ?? 'Không có tên sản phẩm',
          amount: (item['amount'] as num?)?.toInt() ?? 0,
          unitPrice: (item['actual_price'] as num?)?.toInt() ?? 0,
          subTotal: ((item['amount'] as num?)?.toInt() ?? 0) *
              ((item['actual_price'] as num?)?.toInt() ?? 0),
          shippingFee: (orderData['shipping_fee'] as num?)?.toInt() ?? 0,
          deliveryAddress: orderData['shipping_address']?.toString() ?? 'Không có địa chỉ',
        ));
      }

      setState(() {
        orderDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
      });
    }
  }

  int get totalPrice {
    return orderDetails.fold(0, (sum, item) => sum + item.subTotal);
  }

  int get grandTotal => totalPrice + (orderDetails.isNotEmpty ? orderDetails.first.shippingFee : 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin khách hàng
            if (orderDetails.isNotEmpty) ...[
              _buildCustomerInfoCard(),
              const SizedBox(height: 24),
            ],

            // Chi tiết đơn hàng
            _buildOrderDetailsCard(),
            const SizedBox(height: 24),

            // Thông tin giao hàng
            if (orderDetails.isNotEmpty) ...[
              _buildDeliveryInfoCard(),
              const SizedBox(height: 24),
            ],

            // Nút hành động
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final firstItem = orderDetails.first;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstItem.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      firstItem.phoneNumber,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _callCustomer(firstItem.phoneNumber),
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Gọi ngay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header bảng
                const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Món",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("SL",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Đơn giá",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Thành tiền",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),
                const Divider(thickness: 1, height: 24),
                // Danh sách món
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderDetails.length,
                  separatorBuilder: (context, index) =>
                  const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = orderDetails[index];
                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            item.itemName,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(item.amount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("${item.unitPrice.toStringAsFixed(0)}đ",
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("${item.subTotal.toStringAsFixed(0)}đ",
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(thickness: 1, height: 24),
                // Tổng cộng
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tạm tính:",
                            style: TextStyle(fontSize: 15)),
                        Text("${totalPrice.toStringAsFixed(0)}đ",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Phí vận chuyển:",
                            style: TextStyle(fontSize: 15)),
                        Text("${orderDetails.isNotEmpty ? orderDetails.first.shippingFee.toStringAsFixed(0) : '0'}đ",
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng cộng:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${grandTotal.toStringAsFixed(0)}đ",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thông tin giao hàng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    orderDetails.first.deliveryAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _cancelOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Hủy đơn hàng"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Xác nhận đơn hàng"),
          ),
        ),
      ],
    );
  }

  void _callCustomer(String phoneNumber) {
    // Implement call functionality
    print("Gọi cho khách hàng: $phoneNumber");
  }

  Future<void> _cancelOrder() async {
    try {
      await supabase
          .from('customer_order')
          .update({'status': 'cancelled'})
          .eq('order_id', widget.orderId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PageDeliveryFailed(),)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Lỗi khi hủy đơn hàng: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmOrder() async {
    try {
      await supabase
          .from('customer_order')
          .update({'status': 'confirmed'})
          .eq('order_id', widget.orderId);

      Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => PageDeliverySuccessful(),));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xác nhận đơn hàng: ${e.toString()}')),
      );
    }
  }
}