import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_item_detail.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import '../../helpers/other.helper.dart';
import '../../models/Item.model.dart';

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
                Image.network(item.itemImage ?? ""),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${item.itemName}",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${formatMoney(money: item.price)}",
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
                            controller.variantsMap!.keys
                                .map(
                                  (variantTypeName) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          variantTypeName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Bat buoc, chon 1",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      children:
                                          controller
                                              .variantsMap![variantTypeName]!
                                              .map((variant) {
                                                return RadioListTile(
                                                  value: variant.variantId,
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                                          .variantTypeId],
                                                  onChanged: (value) {
                                                    controller.checkVariant(
                                                      variantTypeId:
                                                          variant.variantTypeId,
                                                      variantId: value!,
                                                    );
                                                  },
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ),
                                )
                                .toList(),
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
      bottomSheet: ItemDetailBottomSheet(item: item),
    );
  }
}

class ItemDetailBottomSheet extends StatefulWidget {
  Item item;

  ItemDetailBottomSheet({super.key, required this.item});

  @override
  State<ItemDetailBottomSheet> createState() => _ItemDetailBottomSheetState();
}

class _ItemDetailBottomSheetState extends State<ItemDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    Item item = widget.item;
    final controller = ItemDetailController.get(item.itemId);
    int amount = controller.amount;

    return Container(
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
                      if (amount > 1) {
                        setState(() {
                          controller.amount = --amount;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 8),
                  Text("$amount", style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  ElevatedButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        controller.amount = ++amount;
                      });
                    },
                  ),
                ],
              ),
              Text(
                "${item.price * amount}",
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
              onPressed: () {
                final myVariantItem =
                    ItemDetailController.get(item.itemId).variantCheckList;
                final cartController = ShoppingCartController.get();
                cartController.addToCart(item, amount);
                // Get.back();
              },
              icon: Icon(Icons.shopping_cart),
              label: Text("Thêm vào giỏ hàng"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}