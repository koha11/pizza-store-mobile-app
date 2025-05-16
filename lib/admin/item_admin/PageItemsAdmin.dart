import 'package:flutter/material.dart';
import '../controllers/item_controller.dart';

class PageItemsAdmin extends StatefulWidget {
  const PageItemsAdmin({super.key});

  @override
  State<PageItemsAdmin> createState() => _PageItemsAdminState();
}

class _PageItemsAdminState extends State<PageItemsAdmin> {
  late final ItemAdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ItemAdminController(context: context, setStateCallback: setState);
    _controller.fetchItemsAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const SizedBox(height: 10),
            Row(children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Quản lý Sản phẩm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: _controller.handleSearch,
                ),
              ),
              const Expanded(flex: 1, child: Text("")),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: _controller.showAddItemDialog,
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue[200]!),
                  ),
                  tooltip: 'Thêm sản phẩm',
                  icon: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Thêm'),
                      SizedBox(width: 8.0),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              )
            ]),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const SizedBox(height: 2),
            _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.errorMessage != null
                ? Center(child: Text('Lỗi: ${_controller.errorMessage}'))
                : _controller.items.isEmpty
                ? const Center(child: Text('Không có sản phẩm nào'))
                : Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Text('ID',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('Hình ảnh',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)))),
                          const Expanded(
                              flex: 4,
                              child: Text('Tên sản phẩm',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 2,
                              child: Text('Loại',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 2,
                              child: Text('Giá',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 2,
                              child: Text('Thao tác',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.items.length,
                      separatorBuilder: (context, index) =>
                      const Divider(),
                      itemBuilder: (context, index) {
                        final item = _controller.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text(item.itemId)),
                              Expanded(
                                flex: 2,
                                child: item.itemImage != null &&
                                    item.itemImage!.isNotEmpty
                                    ? Image.network(
                                  item.itemImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                )
                                    : const Icon(Icons.image_not_supported),
                              ),
                              Expanded(flex: 4, child: Text(item.itemName)),
                              Expanded(
                                  flex: 2, child: Text(item.category.categoryName)),
                              Expanded(
                                  flex: 2,
                                  child: Text('${item.price.toStringAsFixed(0)} đ')),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () =>
                                          _controller.showUpdateItemDialog(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () =>
                                          _controller.showDeleteItemDialog(item),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                          _controller.currentPage > 1 ? _controller.previousPage : null,
                        ),
                        Text('Trang ${_controller.currentPage}/${_controller.totalPages}'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _controller.currentPage < _controller.totalPages
                              ? _controller.nextPage
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}