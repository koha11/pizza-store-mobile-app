import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/category.model.dart';

import '../dialogs/dialog.dart';
import '../helpers/supabase.helper.dart' as SupabaseHelper;

class ItemAdminController extends GetxController {
  List<Item> items = [];
  List<Category>? category = [];
  Category? selectedCategory;
  Item? currentEditingItem;

  bool isLoadingItem = true;
  bool isLoadingCategory = true;
  bool isEditingMode = true;
  bool isUploadingImage = true;

  int currentPage = 1;
  final int itemsPerPage = 5;
  int totalPages = 0;
  String? searchQuery;
  String? uploadedImageUrl;
  PlatformFile? selectedImageFile;

  static ItemAdminController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> refreshData() async {
    await getItems();
    await loadCategories();
    calculateTotalPages();
  }

  Future<void> _initData() async {
    await getItems();
    await loadCategories();
    calculateTotalPages();
  }

  Future<void> getItems() async {
    items = await ItemSnapshot.getItems();
    calculateTotalPages();
    isLoadingItem = false;
    update();
  }

  void calculateTotalPages() {
    totalPages = (items.length / itemsPerPage).ceil();
    update();
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      update();
      fetchItems(searchQuery: searchQuery);
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      update();
      fetchItems(searchQuery: searchQuery);
    }
  }

  void handleSearch(String value) {
    searchQuery = value;
    currentPage = 1;
    update();
    fetchItems(searchQuery: searchQuery);
  }

  List<Item> get paginatedItems {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );
  }

  Future<void> fetchItems({String? searchQuery}) async {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      items = await ItemSnapshot.searchItems(searchQuery);
    } else {
      items = await ItemSnapshot.getItems();
    }

    calculateTotalPages();
    isLoadingItem = false;
    update();
  }

  Future<void> loadCategories() async {
    isLoadingCategory = true;
    category = await CategorySnapshot.getCategories();
    isLoadingCategory = false;
    update();
  }

  void setSelectedCategory(Category? category) {
    selectedCategory = category;
    update();
  }

  Future<void> addItem(Item item) async {
    try {
      isLoadingItem = true;
      update();
      await ItemSnapshot.createItem(item: item);
      await refreshData();
      Get.back();
      Get.snackbar('Thành công', 'Đã thêm món mới');
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm món thất bại: ${e.toString()}');
    } finally {
      isLoadingItem = false;
      update();
      resetImageState();
    }
  }

  Future<void> removeItem(Item itemId) async {
    try {
      isLoadingItem = true;
      update();
      await ItemSnapshot.deleteItem(item: itemId);
      await refreshData();
      Get.snackbar('Thành công', 'Đã xóa món');
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa món thất bại: ${e.toString()}');
    } finally {
      isLoadingItem = false;
      update();
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      isLoadingItem = true;
      update();
      await ItemSnapshot.updateItem(item: item);
      await refreshData();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật món');
    } catch (e) {
      Get.snackbar('Lỗi', 'Cập nhật món thất bại: ${e.toString()}');
    } finally {
      isLoadingItem = false;
      update();
      resetImageState();
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedImageFile = result.files.first;
        await uploadImage(selectedImageFile!);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: ${e.toString()}');
    }
  }

  Future<void> uploadImage(PlatformFile file) async {
    if (file.bytes == null) {
      Get.snackbar('Lỗi', 'Không có dữ liệu ảnh');
      return;
    }

    uploadedImageUrl = null;
    update();

    try {
      final String path =
          'item/${DateTime.now().millisecondsSinceEpoch}-${file.name}';

      String publicUrl;

      if (kIsWeb) {
        publicUrl = await SupabaseHelper.uploadImage(
          bytes: file.bytes!,
          bucket: 'item',
          path: path,
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${file.name}');
        await tempFile.writeAsBytes(file.bytes!);

        publicUrl = await SupabaseHelper.uploadImage(
          image: tempFile,
          bucket: 'item',
          path: path,
        );

        await tempFile.delete();
      }

      uploadedImageUrl = publicUrl;
    } catch (e) {
      Get.snackbar('Lỗi', 'Tải ảnh lên thất bại: ${e.toString()}');
      uploadedImageUrl = null;
      selectedImageFile = null;
    } finally {
      isUploadingImage = false;
      update();
    }
  }

  Future<void> confirmAndRemoveItem(BuildContext context, Item item) async {
    final confirm = await showDeleteItemDialog(context, item.itemName);
    if (confirm != true) return;

    try {
      // Xóa ảnh (nếu có)
      if (item.itemImage != null && item.itemImage!.isNotEmpty) {
        try {
          String imagePath = item.itemImage!;
          if (imagePath.startsWith('http')) {
            final uri = Uri.parse(imagePath);
            final segments = uri.pathSegments;
            final index = segments.indexOf('item');
            if (index != -1) {
              imagePath = segments.sublist(index).join('/');
              await SupabaseHelper.removeImage(bucket: 'item', path: imagePath);
            }
          }
        } catch (e) {
          print("Lỗi khi xóa ảnh: $e");
        }
      }
      // Xóa sản phẩm
      await ItemSnapshot.deleteItem(item: item);
      await refreshData();

      Get.snackbar('Thành công', 'Đã xóa món');
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa món thất bại: ${e.toString()}');
      rethrow;
    } finally {
      isLoadingItem = false;
      update();
    }
  }

  void resetImageState() {
    uploadedImageUrl = null;
    isUploadingImage = false;
    selectedImageFile = null;
    update();
  }

  void setupForEditing(Item item) {
    isEditingMode = true;
    currentEditingItem = item;
    selectedCategory = item.category;
    uploadedImageUrl = item.itemImage;
    update();
  }

  void resetEditingState() {
    isEditingMode = false;
    currentEditingItem = null;
    selectedCategory = null;
    resetImageState();
    update();
  }

  void resetSearchState() {
    searchQuery = null;
    currentPage = 1;
    fetchItems();
    update();
  }
}

class BindingItems extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemAdminController>(() => ItemAdminController());
  }
}
