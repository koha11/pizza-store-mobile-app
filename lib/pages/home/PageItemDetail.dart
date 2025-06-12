import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_item_detail.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';
import '../../helpers/other.helper.dart';
import '../../models/Item.model.dart';
import '../../models/variant.model.dart';
import '../../widgets/LoadingDialog.dart';

class PageItemDetail extends StatelessWidget {
  Item item;
  PageItemDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder(
        id: item.itemId,
        tag: item.itemId,
        init: ItemDetailController.get(item.itemId),
        builder: (controller) {
          if (controller.variants == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item.itemImage ?? "",
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      // Download complete, show the image
                      return child;
                    }
                    // Still loading: calculate progress percent
                    final int? expected =
                        loadingProgress.expectedTotalBytes?.toInt();
                    final int loaded =
                        loadingProgress.cumulativeBytesLoaded.toInt();
                    final double progress =
                        expected != null ? loaded / expected : 0;

                    return Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: CircularProgressIndicator(
                          value: expected != null ? progress : null,
                          strokeWidth: 1,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return Image.asset(
                      'asset/images/error_item_img.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "${item.itemName}",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            formatMoney(money: item.price),
                            style: TextStyle(
                              fontSize: 24,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(height: 2, thickness: 2),
                      SizedBox(height: 10),
                      Text("${item.description ?? ""}"),
                      SizedBox(height: 10),

                      ListView(
                        shrinkWrap: true,
                        children:
                            controller.variantsMap!.keys.map((variantTypeId) {
                              final List<Variant>? variants =
                                  controller.variantsMap![variantTypeId];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      variants
                                              ?.first
                                              .variantType
                                              .variantTypeName ??
                                          "",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      variants!.first.variantType.isRequired
                                          ? "Bắt buộc chọn 1"
                                          : "Không bắt buộc",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  children:
                                      variants.map((variant) {
                                        if (variant.variantType.isRequired) {
                                          return RadioListTile(
                                            value: variant.variantId,
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(variant.variantName),
                                                SizedBox(width: 10),
                                                variant.priceChange != 0
                                                    ? Text(
                                                      "+ ${formatMoney(money: variant.priceChange)}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                    : Text(""),
                                              ],
                                            ),
                                            groupValue:
                                                controller
                                                    .variantCheckList[variant
                                                        .variantTypeId]
                                                    ?.first,
                                            onChanged: (value) {
                                              controller.checkVariant(
                                                variantTypeId:
                                                    variant.variantTypeId,
                                                variantId: value!,
                                              );
                                            },
                                          );
                                        } else {
                                          final isChecked = controller
                                              .variantCheckList[variant
                                                  .variantTypeId]
                                              ?.contains(variant.variantId);
                                          return CheckboxListTile(
                                            value: isChecked,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(variant.variantName),
                                                SizedBox(width: 10),
                                                variant.priceChange != 0
                                                    ? Text(
                                                      "+ ${formatMoney(money: variant.priceChange)}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                    : Text(""),
                                              ],
                                            ),
                                            onChanged: (isChecked) {
                                              controller.checkVariant(
                                                variantTypeId:
                                                    variant.variantTypeId,
                                                variantId: variant.variantId,
                                                isChecked: isChecked ?? false,
                                              );
                                            },
                                          );
                                        }
                                      }).toList(),
                                ),
                              );
                            }).toList(),
                      ),

                      Container(height: 300),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: ItemDetailBottomSheet(itemId: item.itemId),
    );
  }
}

class ItemDetailBottomSheet extends StatelessWidget {
  final itemId;
  const ItemDetailBottomSheet({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ItemDetailController.get(itemId),
      tag: itemId,
      id: itemId,
      builder:
          (controller) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          child: Icon(Icons.remove),
                          onPressed: () {
                            if (controller.amount > 1) {
                              controller.adjustAmount(--controller.amount);
                            }
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${controller.amount}",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            controller.adjustAmount(++controller.amount);
                          },
                        ),
                      ],
                    ),
                    Text(
                      formatMoney(money: controller.getItemDetailTotal()),
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (controller.item == null) {
                        return;
                      }

                      if (controller.checkRequiredVariant()) {
                        loadingDialog();

                        await ShoppingCartController.get().addToCart(
                          controller.item!,
                          controller.amount,
                          controller.variantCheckList,
                          controller.variants!,
                        );
                      } else {
                        showSnackBar(
                          desc:
                              "vui lòng điền vào thành phần bắt buộc",
                          success: false,
                        );
                      }
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Thêm vào giỏ hàng"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
