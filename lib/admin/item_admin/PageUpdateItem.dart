import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/category.model.dart';

import '../../controllers/controller_item.dart';
import '../../models/Item.model.dart';

class PageUpdateItem extends StatefulWidget {

  final Item item;

  const PageUpdateItem({super.key, required this.item});

  @override
  State<PageUpdateItem> createState() => _PageUpdateItemState();
}

class _PageUpdateItemState extends State<PageUpdateItem> {
  final ItemController _controller = Get.find<ItemController>();
  late TextEditingController txtId;
  late TextEditingController txtTen;
  late TextEditingController txtGia;
  late TextEditingController txtMota;

  @override
  void initState() {
    super.initState();
    txtId = TextEditingController(text: widget.item.itemId);
    txtTen = TextEditingController(text: widget.item.itemName);
    txtGia = TextEditingController(text: widget.item.price.toString());
    txtMota = TextEditingController(text: widget.item.description);

    _controller.selectedCategory = widget.item.category;
    _controller.uploadedImageUrl = widget.item.itemImage;

    _controller.loadCategories();
  }

  @override
  void dispose() {
    txtId.dispose();
    txtTen.dispose();
    txtGia.dispose();
    txtMota.dispose();
    _controller.resetEditingState();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await _controller.pickAndUploadImage();
  }

  Future<void> _updateItem() async {
    if (txtId.text.isEmpty || txtTen.text.isEmpty || txtGia.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (_controller.selectedCategory == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn danh mục.');
      return;
    }

    final updatedItem = Item(
      itemId: txtId.text,
      itemName: txtTen.text,
      price: int.parse(txtGia.text),
      description: txtMota.text,
      itemImage: _controller.uploadedImageUrl ?? widget.item.itemImage,
      category: _controller.selectedCategory!,
    );

    await _controller.updateItem(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
              "Cập nhật sản phẩm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: txtId,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Id",
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtTen,
                          decoration: const InputDecoration(
                            labelText: "Tên sản phẩm",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtGia,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Giá",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtMota,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Mô tả",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GetBuilder<ItemController>(
                          builder: (controller) {
                            return DropdownButtonFormField<Category>(
                              value: controller.selectedCategory,
                              decoration: const InputDecoration(
                                labelText: "Danh mục",
                                border: OutlineInputBorder(),
                              ),
                              items: controller.category?.map((Category category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.categoryName),
                                );
                              }).toList(),
                              onChanged: (Category? newValue) {
                                controller.setSelectedCategory(newValue);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn danh mục';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    children: [
                      GetBuilder<ItemController>(
                        builder: (controller) {
                          return _buildImagePreview(controller);
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Chọn ảnh"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Cập nhật sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ItemController controller) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: controller.isUploadingImage
          ? const Center(child: CircularProgressIndicator())
          : controller.uploadedImageUrl != null && controller.uploadedImageUrl!.isNotEmpty
          ? Image.network(
        controller.uploadedImageUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.error, color: Colors.red),
      )
          : const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.grey),
          Text('Chưa có ảnh', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pizza_store_app/models/Item.model.dart';
// import 'package:pizza_store_app/models/category.model.dart';
//
// class PageUpdateItem extends StatefulWidget {
//   PageUpdateItem({super.key, required this.item});
//
//   Item item;
//
//   @override
//   State<PageUpdateItem> createState() => _PageUpdateItemState();
// }
//
// class _PageUpdateItemState extends State<PageUpdateItem> {
//   TextEditingController txtId = TextEditingController();
//   TextEditingController txtTen = TextEditingController();
//   TextEditingController txtGia = TextEditingController();
//   TextEditingController txtMota = TextEditingController();
//   XFile? xFile;
//   List<Category> categories = [];
//   String? category = 'Pizza';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//             child: Text(
//               "Thêm sản phẩm",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                     child: Column(
//                       children: [
//                         // Input Fields
//                         TextFormField(
//                           controller: txtId,
//                           keyboardType:
//                           const TextInputType.numberWithOptions(signed: false, decimal: false),
//                           decoration: const InputDecoration(
//                             labelText: "Id",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: txtTen,
//                           decoration: const InputDecoration(
//                             labelText: "Tên sản phẩm",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: txtGia,
//                           keyboardType:
//                           const TextInputType.numberWithOptions(signed: false, decimal: false),
//                           decoration: const InputDecoration(
//                             labelText: "Giá",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: txtMota,
//                           maxLines: 3,
//                           decoration: const InputDecoration(
//                             labelText: "Mô tả",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButton<String>(
//                             value: category,
//                             items: categories.map(
//                                   (e){
//                                 return DropdownMenuItem<String>(
//                                   value: category,
//                                   child: Text("${categories}"),
//                                 );
//                               },
//                             ).toList(),
//                             onChanged: (value){
//                               setState(() {
//                                 category = value;
//                               });
//                             }),
//                         const SizedBox(height: 24),
//                       ],
//                     )),
//                 const SizedBox(
//                   width: 20,
//                 ),
//
//                 //Thêm hình ảnh tại đây
//                 Expanded(
//                   // child: Center(child: const Text("Thêm chức năng upload ảnh Web App")),
//                   child: ElevatedButton(
//                       onPressed: () async{
//                         var imagePicker = await ImagePicker()
//                             .pickImage(source: ImageSource.gallery);
//                         if (imagePicker != null){
//                           setState(() {
//                             xFile = imagePicker;
//                           });
//                         }
//                       },
//                       child: Text("Chọn ảnh")
//                   ),
//                   // child: GestureDetector(
//                   //   onTap: () {
//                   //     showModalBottomSheet(
//                   //       context: context,
//                   //       builder: (BuildContext context) {
//                   //         return SafeArea(
//                   //           child: Column(
//                   //             mainAxisSize: MainAxisSize.min,
//                   //             children: <Widget>[
//                   //               ListTile(
//                   //                 leading: const Icon(Icons.photo_library),
//                   //                 title: const Text('Chọn từ thư viện'),
//                   //                 onTap: () {
//                   //                   _controller.pickImage(ImageSource.gallery);
//                   //                   Navigator.pop(context);
//                   //                 },
//                   //               ),
//                   //               ListTile(
//                   //                 leading: const Icon(Icons.camera_alt),
//                   //                 title: const Text('Chụp ảnh'),
//                   //                 onTap: () {
//                   //                   _controller.pickImage(ImageSource.camera);
//                   //                   Navigator.pop(context);
//                   //                 },
//                   //               ),
//                   //             ],
//                   //           ),
//                   //         );
//                   //       },
//                   //     );
//                   //   },
//                   //   child: Container(
//                   //     height: 200,
//                   //     decoration: BoxDecoration(
//                   //       border: Border.all(color: Colors.grey),
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //     ),
//                   //     child: _controller.pickedImageFile == null
//                   //         ? const Center(
//                   //             child: Icon(
//                   //               Icons.image_outlined,
//                   //               size: 60,
//                   //               color: Colors.grey,
//                   //             ),
//                   //           )
//                   //         : ClipRRect(
//                   //             borderRadius: BorderRadius.circular(8.0),
//                   //             child: Image.file(
//                   //               File(_controller.pickedImageFile!.path),
//                   //               fit: BoxFit.cover,
//                   //               width: double.infinity,
//                   //               height: double.infinity,
//                   //             ),
//                   //           ),
//                   //   ),
//                   // ),
//                 ),
//               ],
//             ),
//             // Image Section
//             const SizedBox(height: 20),
//
//             // Add Button
//             ElevatedButton(
//               onPressed: () {
//
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 textStyle: const TextStyle(fontSize: 18),
//               ),
//               child: const Text("Thêm sản phẩm"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
