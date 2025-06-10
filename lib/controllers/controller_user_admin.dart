import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../dialogs/dialog.dart';
import '../helpers/supabase.helper.dart' as SupabaseHelper;
import '../models/app_user.model.dart';
import '../models/user_role.model.dart';

class UserAdminController extends GetxController {
  List<AppUser> user = [];
  List<Role>? role = [];
  Role? selectedRole;
  AppUser? currentEditingUser;

  bool isLoadingUser = true;
  bool isLoadingRole = true;
  bool isEditingMode = true;
  bool isUploadingImage = true;

  int currentPage = 1;
  final int usersPerPage = 5;
  int totalPages = 0;
  String? searchQuery;
  String? uploadedImageUrl;
  PlatformFile? selectedImageFile;

  static UserAdminController get() => Get.find();

  Future<void> refreshData() async {
    await getUsers();
    await loadRoles();
    calculateTotalPages();
  }

  Future<void> _initData() async {
    await getUsers();
    await loadRoles();
    calculateTotalPages();
  }

  Future<void> getUsers() async {
    user = await AppUserSnapshot.getAppUsers();
    calculateTotalPages();
    isLoadingUser = false;
    update();
  }

  void calculateTotalPages() {
    totalPages = (user.length / usersPerPage).ceil();
    update();
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      update();
      fetchUsersAdmin(searchQuery: searchQuery);
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      update();
      fetchUsersAdmin(searchQuery: searchQuery);
    }
  }

  void handleSearch(String value) {
    searchQuery = value;
    currentPage = 1;
    update();
    fetchUsersAdmin(searchQuery: searchQuery);
  }

  List<AppUser> get paginatedUser {
    final startIndex = (currentPage - 1) * usersPerPage;
    final endIndex = startIndex + usersPerPage;
    return user.sublist(
      startIndex,
      endIndex > user.length ? user.length : endIndex,
    );
  }

  Future<void> fetchUsersAdmin({String? searchQuery}) async {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      user = await AppUserSnapshot.searchUsers(searchQuery);
    } else {
      user = await AppUserSnapshot.getAppUsers();
    }

    calculateTotalPages();
    isLoadingUser = false;
    update();
  }

  Future<void> loadRoles() async {
    role = await RoleSnapshot.getRoles();
    isLoadingRole = false;
    update();
  }

  void setSelectedRole(Role? role) {
    selectedRole = role;
    update();
  }

  Future<void> addUser(AppUser user) async {
    try {
      await AppUserSnapshot.createUser(user: user);
      await refreshData();
      Get.back();
      Get.snackbar('Thành công', 'Đã thêm khách hàng mới');
    } catch (e) {
      Get.snackbar('Lỗi', 'Thêm khách hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingUser = false;
      update();
      resetImageState();
    }
  }

  Future<void> removeUser(AppUser userId) async {
    try {
      await AppUserSnapshot.deleteUser(user: userId);
      await refreshData();
      Get.snackbar('Thành công', 'Đã xóa khách hàng');
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa khách hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingUser = false;
      update();
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await AppUserSnapshot.updateUser(user: user);
      await refreshData();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật khách hàng');
    } catch (e) {
      Get.snackbar('Lỗi', 'Cập nhật khách hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingUser = false;
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

    isUploadingImage = true;
    uploadedImageUrl = null;
    update();

    try {
      final String path =
          'profile/${DateTime.now().millisecondsSinceEpoch}-${file.name}';

      String publicUrl;

      if (kIsWeb) {
        publicUrl = await SupabaseHelper.uploadImage(
          bytes: file.bytes!,
          bucket: 'profile',
          path: path,
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${file.name}');
        await tempFile.writeAsBytes(file.bytes!);

        publicUrl = await SupabaseHelper.uploadImage(
          image: tempFile,
          bucket: 'profile',
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

  // Future<bool> checkEmailExists(String email) async {
  //   try {
  //     final List<AppUser> existingUsers = await AppUserSnapshot.getAppUsers(
  //       equalObject: {"email": email},
  //     );
  //     return existingUsers.isNotEmpty;
  //   } catch (e) {
  //     print("Lỗi khi kiểm tra email: $e");
  //     Get.snackbar('Lỗi', 'Không thể kiểm tra email: ${e.toString()}');
  //     return true;
  //   }
  // }

  Future<void> confirmAndRemoveUser(BuildContext context, AppUser user) async {
    final confirm = await showDeleteUserDialog(context, user.userName);
    if (confirm != true) return;

    try {
      isLoadingUser = true;
      update();
      // Xóa ảnh (nếu có)
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        try {
          String imagePath = user.avatar!;
          if (imagePath.startsWith('http')) {
            final uri = Uri.parse(imagePath);
            final segments = uri.pathSegments;
            final index = segments.indexOf('profile');
            if (index != -1) {
              imagePath = segments.sublist(index).join('/');
              await SupabaseHelper.removeImage(
                bucket: 'profile',
                path: imagePath,
              );
            }
          }
        } catch (e) {
          print("Lỗi khi xóa ảnh: $e");
        }
      }
      // Xóa sản phẩm
      await AppUserSnapshot.deleteUser(user: user);
      await refreshData();

      Get.snackbar('Thành công', 'Đã xóa khách hàng');
    } catch (e) {
      Get.snackbar('Lỗi', 'Xóa khách hàng thất bại: ${e.toString()}');
      rethrow;
    } finally {
      isLoadingUser = false;
      update();
    }
  }

  void resetImageState() {
    uploadedImageUrl = null;
    isUploadingImage = false;
    selectedImageFile = null;
    update();
  }

  void setupForEditing(AppUser user) {
    isEditingMode = true;
    currentEditingUser = user;
    selectedRole = user.roleId as Role?;
    uploadedImageUrl = user.avatar;
    update();
  }

  void resetEditingState() {
    isEditingMode = false;
    currentEditingUser = null;
    selectedRole = null;
    resetImageState();
    update();
  }

  void resetSearchState() {
    searchQuery = null;
    currentPage = 1;
    fetchUsersAdmin();
    update();
  }
}
