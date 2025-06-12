import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:pizza_store_app/models/order_variant.model.dart';
import 'package:pizza_store_app/models/variant.model.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';

class ShoppingCartController extends GetxController {
  Map<String, bool> _checkedItems = {}; // lưu trạng thái của các item/ itemId
  String? _customerId;
  CustomerOrder? _cart; // lưu giỏ hàng

  CustomerOrder? get cart => _cart;
  Map<String, bool> get checkedItems => _checkedItems;

  static ShoppingCartController get() => Get.find();

  Future<void> loadCart() async => await _loadCart();
  Future<void> initializeCart() async => await _initializeCart();

  @override
  void onReady() async {
    // TODO: implement onInit
    super.onReady();
    await _initializeCart();
  }

  // Thêm getter để lấy tổng số lượng sản phẩm
  int get totalItems {
    int total = 0;
    _cart?.orderDetails?.forEach((od) {
      total += od.amount;
    });
    return total;
  }

  // Thêm getter để lấy tổng tiền
  int get totalAmount {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      total += od.actualPrice * od.amount;
    });
    return total;
  }

  // Getter để lấy tổng số lượng sản phẩm đã chọn
  int get totalSelectedItems {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      if (_checkedItems[od.itemId] == true) {
        total += od.amount;
      }
    });
    return total;
  }

  // Getter để lấy tổng tiền của các sản phẩm đã chọn
  int get totalSelectedAmount {
    int total = 0;
    _cart!.orderDetails?.forEach((od) {
      if (_checkedItems[od.itemId] == true) {
        total += od.actualPrice;
      }
    });
    return total;
  }

  // Phương thức để lấy danh sách các mục đã chọn
  List<OrderDetail> getSelectedItems() {
    return _cart!.orderDetails
            ?.where((element) => _checkedItems[element.itemId] == true)
            .toList() ??
        [];
  }

  // Phương thức để đảo trạng thái check của một item
  void toggleItemCheck(String itemId) {
    _checkedItems[itemId] = !(_checkedItems[itemId] ?? false);
    update();
  }

  // Phương thức để  chọn/bỏ chọn tất cả items
  void checkAndUnAllItems() {
    // Kiểm tra xem tất cả items đã được chọn chưa
    // bool allChecked = _cart!.orderDetails?.keys.every(
    //   (key) => _checkedItems[key] == true,
    // );
    bool allChecked =
        _cart!.orderDetails?.every((od) => _checkedItems[od.itemId] == true) ??
        false;

    // Nếu tất cả đã được chọn thì bỏ chọn tất cả, ngược lại thì chọn tất cả
    _cart!.orderDetails?.forEach((od) {
      _checkedItems[od.itemId] = !allChecked;
    });
    update();
  }

  // Phương thức xóa các items đã được check
  Future<void> removeSelectedItems() async {
    if (_cart == null) return;

    try {
      final itemsToRemove =
          _checkedItems.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

      for (var itemId in itemsToRemove) {
        OrderDetail? od = _cart!.orderDetails?.firstWhere(
          (od) => od.itemId == itemId,
        );
        if (od != null) {
          await removeFromCart(orderDetail: od);
        }
        _checkedItems.remove(itemId);
      }

      update();
    } catch (e) {
      print('Lỗi xóa item đã chọn: $e');
      await _loadCart();
    }
  }

  Future<void> _initializeCart() async {
    final userId = UserController.get().appUser?.userId;
    if (userId == null) return;

    _customerId = userId;

    // Tìm giỏ hàng đang cart của user
    await _loadCart(); // Nếu không có giỏ hàng nào, tạo mới

    if (_cart == null) {
      await CustomerOrderSnapshot.createNewOrder(userId);
      await _loadCart();
    }

    update();
  }

  Future<void> _loadCart() async {
    _cart = await CustomerOrderSnapshot.getCustomerCart(_customerId!);
    // khởi tạo trạng thái check cho từng item
    if (_cart != null) {
      for (var od in _cart!.orderDetails!) {
        _checkedItems[od.itemId] = false;
      }
    }

    update();
  }

  int calcODActualPrice(
    Item item,
    int amount,
    Map<String, List<String>> myVariantMap,
    List<Variant> variants,
  ) {
    int total = item.price;

    myVariantMap.forEach(
      (variantTypeId, variantIds) => variantIds.forEach((variantId) {
        if (variantId.isNotEmpty) {
          total +=
              variants
                  .firstWhere((variant) => variant.variantId == variantId)
                  .priceChange;
        }
      }),
    );

    total *= amount;

    return total;
  }

  Future<void> addToCart(
    Item item,
    int amount,
    Map<String, List<String>> myVariantMap,
    List<Variant> variants,
  ) async {
    if (UserController.get().appUser == null) {
      showSnackBar(desc: "bạn cần đăng nhập", success: false);
    }

    if (_cart == null) {
      await _initializeCart();
    }

    OrderDetail? myOD;

    try {
      myOD = _cart!.orderDetails?.firstWhere((od) => od.itemId == item.itemId);
    } catch (e) {
      // throw e;
      myOD = null;
    }

    if (myOD != null) {
      OrderDetailSnapshot.updateItemAmount(
        _cart!.orderId,
        item.itemId,
        ++myOD.amount,
      );
    } else {
      await CustomerOrderSnapshot.addItemToCart(
        _cart!.orderId,
        item,
        amount,
        calcODActualPrice(item, amount, myVariantMap, variants),
      );

      myVariantMap.forEach((key, value) {
        if (value.isNotEmpty) {
          value.forEach((variantId) async {
            if (variantId.isNotEmpty) {
              await OrderVariantSnapshot.insertOrderVariant(
                OrderVariant(
                  variantId: variantId,
                  itemId: item.itemId,
                  orderId: _cart!.orderId,
                ),
              );
            }
          });
        }
      });
    }

    Get.back();

    showSnackBar(desc: 'Đã thêm sản phẩm vào giỏ hàng', success: true);

    await _loadCart();
  }

  Future<void> removeFromCart({required OrderDetail orderDetail}) async {
    if (_cart == null) return;

    try {
      await OrderDetailSnapshot.deleteOrderDetail(
        orderId: _cart!.orderId,
        itemId: orderDetail.itemId,
      );

      orderDetail.variantMaps.forEach(
        (key, value) => value.forEach(
          (variant) async => await OrderVariantSnapshot.deleteOrderVariant(
            OrderVariant(
              variantId: variant.variantId,
              itemId: orderDetail.itemId,
              orderId: orderDetail.orderId,
            ),
          ),
        ),
      );

      await _loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateAmount(String itemId, bool isDes) async {
    final itemAmount =
        _cart!.orderDetails
            ?.firstWhere((element) => element.itemId == itemId)
            .amount;
    OrderDetailSnapshot.updateItemAmount(
      _cart!.orderId,
      itemId,
      isDes ? itemAmount! - 1 : itemAmount! + 1,
    );

    await _loadCart();
  }

  Future<void> placeOrder({
    required int shippingFee,
    required String address,
    required int totalAmount,
  }) async {
    loadingDialog();
    // if (_customerId == null) {
    //   Get.snackbar(
    //     'Lỗi',
    //     'Vui lòng đăng nhập để đặt hàng',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    // Tao 1 order moi co thong tin cua user hien tai + shipping fee + address + status=pending
    final newOrderId = await CustomerOrderSnapshot.createOrder(
      customerId: _customerId!,
      address: address,
      shippingFee: shippingFee,
      totalAmount: totalAmount,
    );

    // Chuyen nhung order detail dang co trang thai checked -> order moi
    for (var item in _checkedItems.entries) {
      if (item.value) {
        OrderDetail? newOrderDetail;

        try {
          newOrderDetail = _cart!.orderDetails?.firstWhere(
            (od) => od.itemId == item.key,
          );
        } catch (e) {
          newOrderDetail = null;
        }

        // var newOrderDetail = _cart!.orderDetails[item.key]!;

        // tao order detail moi
        newOrderDetail!.orderId = newOrderId;

        await OrderDetailSnapshot.createOrderDetail(
          orderDetail: newOrderDetail,
        );

        // xoa order detail
        await OrderDetailSnapshot.deleteOrderDetail(
          itemId: item.key,
          orderId: _cart!.orderId,
        );

        // tao order variant moi
        if (newOrderDetail.variantMaps.isNotEmpty) {
          final myVariants =
              newOrderDetail.variantMaps.values.expand((e) => e).toList();

          myVariants.forEach((variant) async {
            await OrderVariantSnapshot.insertOrderVariant(
              OrderVariant(
                variantId: variant.variantId,
                itemId: newOrderDetail!.itemId,
                orderId: newOrderDetail.orderId,
              ),
            );
            // xoa order variant
            await OrderVariantSnapshot.deleteOrderVariant(
              OrderVariant(
                variantId: variant.variantId,
                itemId: newOrderDetail.itemId,
                orderId: _cart!.orderId,
              ),
            );
          });
        }
      }
    }
    _checkedItems.clear();
    await _loadCart();
    Get.back();
    showSnackBar(desc: "Dat hang thanh cong", success: true);
  }

  void reset() {
    _cart == null;
    _checkedItems.clear();
    update();
  }
}

class BindingsShoppingCart extends Bindings {
  @override
  void dependencies() {
    // Get.put<ShoppingCartController>(ShoppingCartController());
    Get.lazyPut(() => ShoppingCartController());
  }
}