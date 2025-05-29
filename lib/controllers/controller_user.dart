import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
import 'package:path_provider/path_provider.dart';
=======
>>>>>>> bdf80e6490ea89d8843106692d227d1b2c2ed344
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/user_address.model.dart';
import 'package:pizza_store_app/models/user_role.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dialogs/dialog.dart';
import '../helpers/supabase.helper.dart' as SupabaseHelper;

class UserController extends GetxController {
  AppUser? appUser;
  List<UserAddress>? userAddress;
  bool isLoading = false;

  static UserController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> fetchUser() async {
    isLoading = true;
    update(["user"]);
    User? user = getCurrentUser();
    if (user != null) {
      List<AppUser> res = await AppUserSnapshot.getAppUsers(
        equalObject: {"user_id": user.id},
      );
      if (res.isNotEmpty) {
        appUser = res.first;
        await fetchAddress();
      }
    }
    isLoading = false;
    update(["user"]);
  }

  Future<void> fetchAddress() async {
    if (appUser != null) {
      userAddress = await UserAddressSnapshot.getUserAddress(
        equalObject: {"user_id": appUser!.userId},
      );

      update(["address"]);
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await SupabaseSnapshot.update(
      table: AppUser.tableName,
      updateObject: {"is_active": false},
      equalObject: {"user_id": appUser!.userId},
    );

    // Reset các controller
    if (Get.isRegistered<HistoryCartController>()) {
      Get.find<HistoryCartController>().reset();
    }
    if (Get.isRegistered<ShoppingCartController>()) {
      Get.find<ShoppingCartController>().reset();
    }

    appUser = null;
    update(["1"]);
  }

  Future<void> updateInfo({
    required BuildContext context,
    required TextEditingController txtUserName,
    required TextEditingController txtPhoneNumber,
  }) async {
    await AppUserSnapshot.updateInfoAppUser(
      context: context,
      txtUserName: txtUserName,
      txtPhoneNumber: txtPhoneNumber,
      userId: appUser!.userId,
    );
    await fetchUser();
    update(["changeInfo"]);
  }

  Future<void> changePassword({
    required BuildContext context,
    required TextEditingController txtCurrPw,
    required TextEditingController txtNewPw,
    required TextEditingController txtConfirmNewPw,
  }) async {
    await AppUserSnapshot.updatePassword(
      context: context,
      txtCurrPw: txtCurrPw,
      txtNewPw: txtNewPw,
      txtConfirmNewPw: txtConfirmNewPw,
    );
    update(["changePassword"]);
  }

  Future<void> addNewAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
    required TextEditingController txtNickName,
  }) async {
    await UserAddressSnapshot.addNewAddress(
      context: context,
      txtAddress: txtAddress,
      txtNickName: txtNickName,
      userId: appUser!.userId,
    );
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
  }

  Future<void> updateAddress({
    required BuildContext context,
    required TextEditingController txtNewAddress,
    required TextEditingController txtNickName,
    required TextEditingController txtCurrAddress,
  }) async {
    await UserAddressSnapshot.updateAddress(
      context: context,
      txtNewAddress: txtNewAddress,
      txtCurrAddress: txtCurrAddress,
      txtNickName: txtNickName,
      userId: appUser!.userId,
    );
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
  }

  Future<void> deleteAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
  }) async {
    await UserAddressSnapshot.deleteAddress(
      context: context,
      txtAddress: txtAddress,
      userId: appUser!.userId,
    );
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
  }

  // Viết phần User Admin

  List<AppUser> user = [];
  List<Role>? role = [];
  Role? selectedRole;
  AppUser? currentEditingUser;

  bool isLoadingUser = false;
  bool isLoadingRole = false;
  bool isEditingMode = false;
  bool isUploadingImage = false;

  int currentPage = 1;
  final int usersPerPage = 5;
  int totalPages = 0;
  String? searchQuery;
  String? uploadedImageUrl;
  PlatformFile? selectedImageFile;

  Future<void> refreshData() async {
    await getUsers();
    await loadRoles();
    calculateTotalPages();
  }

  Future<void> _initData() async {
    await getUsers();
    await loadRoles();
    calculateTotalPages();
    fetchUser();
  }

  Future<void> getUsers() async {
    isLoadingUser = true;
    update();
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
    isLoadingUser = true;
    update();

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
    isLoadingRole = true;
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
      isLoadingUser = true;
      update();
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
      isLoadingUser = true;
      update();
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
      isLoadingUser = true;
      update();
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
      final String path = 'profile/${DateTime.now().millisecondsSinceEpoch}-${file.name}';

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
              await SupabaseHelper.removeImage(bucket: 'profile', path: imagePath);
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

class BindingsUserController extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(UserController());
  }
}