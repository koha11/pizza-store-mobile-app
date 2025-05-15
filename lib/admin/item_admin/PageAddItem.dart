import 'package:flutter/material.dart';
import 'package:pizza_store_app/models/category.model.dart';

import '../controllers/item_controller.dart';

class PageAddItem extends StatefulWidget {
  const PageAddItem({Key? key}) : super(key: key);

  @override
  State<PageAddItem> createState() => _PageAddItemState();
}

class _PageAddItemState extends State<PageAddItem> {
  late final AddItemController _controller;
  Future<List<Category>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _controller = AddItemController(context: context, setStateCallback: setState);
    _categoriesFuture = _controller.fetchCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
              "Thêm sản phẩm",
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
              children: [
                Expanded(
                    child: Column(
                      children: [
                        // Input Fields
                        TextFormField(
                          controller: _controller.idController,
                          keyboardType:
                          const TextInputType.numberWithOptions(signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Id",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.nameController,
                          decoration: const InputDecoration(
                            labelText: "Tên sản phẩm",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.priceController,
                          keyboardType:
                          const TextInputType.numberWithOptions(signed: false, decimal: false),
                          decoration: const InputDecoration(
                            labelText: "Giá",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Mô tả",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<Category>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Lỗi tải danh mục: ${snapshot.error}');
                            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                              return const Text('Không có danh mục nào.');
                            } else {
                              return DropdownButtonFormField<Category>(
                                decoration: const InputDecoration(
                                  labelText: "Danh mục",
                                  border: OutlineInputBorder(),
                                ),
                                value: _controller.selectedCategory,
                                items: snapshot.data!.map((category) {
                                  return DropdownMenuItem<Category>(
                                    value: category,
                                    child: Text(category.categoryName),
                                  );
                                }).toList(),
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    _controller.selectedCategory = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Vui lòng chọn danh mục';
                                  }
                                  return null;
                                },
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    )),
                const SizedBox(
                  width: 20,
                ),

                //Thêm hình ảnh tại đây
                Expanded(
                  child: Center(child: const Text("Thêm chức năng upload ảnh Web App")),
                  // child: GestureDetector(
                  //   onTap: () {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return SafeArea(
                  //           child: Column(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: <Widget>[
                  //               ListTile(
                  //                 leading: const Icon(Icons.photo_library),
                  //                 title: const Text('Chọn từ thư viện'),
                  //                 onTap: () {
                  //                   _controller.pickImage(ImageSource.gallery);
                  //                   Navigator.pop(context);
                  //                 },
                  //               ),
                  //               ListTile(
                  //                 leading: const Icon(Icons.camera_alt),
                  //                 title: const Text('Chụp ảnh'),
                  //                 onTap: () {
                  //                   _controller.pickImage(ImageSource.camera);
                  //                   Navigator.pop(context);
                  //                 },
                  //               ),
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  //   child: Container(
                  //     height: 200,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.grey),
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: _controller.pickedImageFile == null
                  //         ? const Center(
                  //             child: Icon(
                  //               Icons.image_outlined,
                  //               size: 60,
                  //               color: Colors.grey,
                  //             ),
                  //           )
                  //         : ClipRRect(
                  //             borderRadius: BorderRadius.circular(8.0),
                  //             child: Image.file(
                  //               File(_controller.pickedImageFile!.path),
                  //               fit: BoxFit.cover,
                  //               width: double.infinity,
                  //               height: double.infinity,
                  //             ),
                  //           ),
                  //   ),
                  // ),
                ),
              ],
            ),
            // Image Section
            const SizedBox(height: 20),

            // Add Button
            ElevatedButton(
              onPressed: _controller.addItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Thêm sản phẩm"),
            ),
          ],
        ),
      ),
    );
  }
}