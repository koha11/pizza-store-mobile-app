import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_store_app/admin/model/item.admin.model.dart';
import 'package:pizza_store_app/admin/item_admin/PageAddItem.dart';
import 'package:pizza_store_app/admin/item_admin/PageUpdateItem.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.model.dart';
import '../admin_dialogs/admin_dialogs.dart';
import '../helpers/supabase_helper.dart';
import '../model/app_user.admin.model.dart';

class ItemAdminController {
  final BuildContext context;
  final Function(void Function()) setStateCallback;
  int currentPage = 1;
  final int itemsPerPage = 5;
  int totalPages = 0;
  List<ItemAdmin> items = [];
  bool isLoading = false;
  String? errorMessage;
  String? searchQuery;

  ItemAdminController({required this.context, required this.setStateCallback});

  Future<void> fetchItemsAdmin({String? searchQuery}) async {
    setStateCallback(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final int startIndex = (currentPage - 1) * itemsPerPage;
      final List<ItemAdmin> fetchedItemsAdmin =
      await ItemAdminSnapshot.getItemsAdminWithPagination(
        startIndex: startIndex,
        limit: itemsPerPage,
        searchQuery: searchQuery,
      );
      final int totalItems = await ItemAdminSnapshot.getTotalItemsAdmin(
          searchQuery: searchQuery);

      setStateCallback(() {
        items = fetchedItemsAdmin;
        totalPages = (totalItems / itemsPerPage).ceil();
        isLoading = false;
      });
    } catch (error) {
      setStateCallback(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setStateCallback(() {
        currentPage--;
      });
      fetchItemsAdmin(searchQuery: searchQuery);
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      setStateCallback(() {
        currentPage++;
      });
      fetchItemsAdmin(searchQuery: searchQuery);
    }
  }

  void handleSearch(String value) {
    setStateCallback(() {
      searchQuery = value;
      currentPage = 1;
    });
    fetchItemsAdmin(searchQuery: searchQuery);
  }

  Future<void> showAddItemDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: const PageAddItem(),
          ),
        );
      },
    );
    if (result == true) {
      fetchItemsAdmin();
    }
  }

  Future<void> showUpdateItemDialog(ItemAdmin item) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: PageUpdateItem(item: item),
          ),
        );
      },
    );
    if (result == true) {
      fetchItemsAdmin();
    }
  }

  Future<void> showDeleteItemDialog(ItemAdmin item) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      "Bạn có muốn xóa sảm phẩm ${item.itemName} không?",
    );
    if (confirmed == true) {
      setStateCallback(() {
        isLoading = true;
      });
      try {
        final supabase = SupabaseHelper.supabase;
        // Xóa các bản ghi liên quan trong bảng order_detail trước
        await supabase
            .from('order_detail')
            .delete()
            .eq('item_id', item.itemId);

        await ItemAdminSnapshot.delete(item.itemId);
        fetchItemsAdmin(); // Làm mới danh sách
        showSnackBar(
          context,
          message: "Đã xóa sản phẩm ${item.itemName}",
        );
      } catch (error) {
        String errorMessage = "Lỗi khi xóa: $error";
        if (error is PostgrestException) {
          errorMessage = "Lỗi xóa sản phẩm: ${error.message}";
        }
        showSnackBar(
          context,
          message: errorMessage,
          backgroundColor: Colors.red,
        );
        print("Lỗi xóa sản phẩm: $error");
      } finally {
        setStateCallback(() {
          isLoading = false;
        });
      }
    }
  }
}

class AddItemController {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Category? selectedCategory;
  XFile? pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  final BuildContext context;
  final Function(void Function()) setStateCallback;

  AddItemController({required this.context, required this.setStateCallback});

  Future<List<Category>> fetchCategories() async {
    try {
      final res = await SupabaseHelper.supabase.from('category').select('category_id, category_name');
      if (res == null) {
        return [];
      }
      return (res as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi tải danh mục: $e');
      return [];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setStateCallback(() {
        pickedImageFile = pickedFile;
      });
    }
  }

  Future<void> addItem() async {
    if (idController.text.isEmpty ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedCategory == null ||
        pickedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin, chọn danh mục và ảnh!')),
      );
      return;
    }

    final supabaseHelper = SupabaseHelper();
    String? imageUrl;
    String? imageName;

    try {
      imageName = 'item_image/${idController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await supabaseHelper.uploadImage(
        image: File(pickedImageFile!.path),
        bucket: 'images',
        path: imageName,
      );

      if (imageUrl != null) {
        final newItemAdmin = ItemAdmin(
          itemId: idController.text,
          itemName: nameController.text,
          price: int.parse(priceController.text),
          description: descriptionController.text,
          category: selectedCategory!,
          itemImage: imageUrl,
        );

        final result = await ItemAdminSnapshot.insert(newItemAdmin);

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm sản phẩm thành công!')),
          );
          idController.clear();
          nameController.clear();
          priceController.clear();
          descriptionController.clear();
          setStateCallback(() {
            selectedCategory = null;
            pickedImageFile = null;
          });
          Navigator.pop(context, true); // Trả về true để thông báo thành công
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi thêm sản phẩm vào cơ sở dữ liệu.')),
          );
          if (imageUrl != null) {
            await supabaseHelper.removeImage(bucket: 'images', path: imageName);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi tải ảnh lên.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  void dispose() {
    idController.dispose();
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}

class UpdateItemController {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Category? selectedCategory;
  XFile? pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  final BuildContext context;
  final Function(void Function()) setStateCallback;
  final ItemAdmin initialItem;
  String? currentImageUrl;

  UpdateItemController({
    required this.context,
    required this.setStateCallback,
    required this.initialItem,
  }) : currentImageUrl = initialItem.itemImage {
    itemNameController.text = initialItem.itemName;
    descriptionController.text = initialItem.description ?? '';
    priceController.text = initialItem.price.toString();
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final res = await SupabaseHelper.supabase
          .from('category')
          .select('category_id, category_name');

      if (res == null || res.isEmpty) {
        return [];
      }

      return (res as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi tải danh mục: $e');
      return [];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setStateCallback(() {
        pickedImageFile = pickedFile;
      });
    }
  }

  Future<void> updateItem() async {
    if (itemNameController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin và chọn danh mục!')),
      );
      return;
    }

    final supabaseHelper = SupabaseHelper();
    String? imageUrl = currentImageUrl; // Mặc định giữ nguyên ảnh cũ
    String? imageName;

    try {
      if (pickedImageFile != null) {
        // Nếu người dùng chọn ảnh mới, tiến hành upload
        imageName = 'item_image/${initialItem.itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await supabaseHelper.uploadImage(
          image: File(pickedImageFile!.path),
          bucket: 'images',
          path: imageName,
        );
      }

      final updatedItem = ItemAdmin(
        itemId: initialItem.itemId,
        itemName: itemNameController.text,
        price: int.tryParse(priceController.text) ?? 0,
        description: descriptionController.text,
        category: selectedCategory!,
        itemImage: imageUrl,
      );

      final success = await ItemAdminSnapshot.update(updatedItem);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật sản phẩm thành công!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi cập nhật sản phẩm vào cơ sở dữ liệu.')),
        );
        // Nếu upload ảnh mới thất bại, có thể cần xóa ảnh đã upload (tùy logic)
        if (pickedImageFile != null && imageUrl != null && imageUrl != currentImageUrl) {
          await supabaseHelper.removeImage(bucket: 'images', path: imageName!);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  void dispose() {
    itemNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}

