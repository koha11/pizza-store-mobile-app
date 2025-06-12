import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user_admin.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/user_role.model.dart';

class PageUpdateUserAdmin extends StatefulWidget {
  final AppUser user;

  const PageUpdateUserAdmin({super.key, required this.user});

  @override
  State<PageUpdateUserAdmin> createState() => _PageUpdateUserAdminState();
}

class _PageUpdateUserAdminState extends State<PageUpdateUserAdmin> {
  final UserAdminController _controller = Get.find<UserAdminController>();

  // Khai báo TextEditingController
  late TextEditingController txtId;
  late TextEditingController txtUserName;
  late TextEditingController txtEmail;
  late TextEditingController txtPhone;

  String? initialImageUrl;

  @override
  void initState() {
    super.initState();

    txtId = TextEditingController(text: widget.user.userId);
    txtUserName = TextEditingController(text: widget.user.userName);
    txtEmail = TextEditingController(text: widget.user.email);
    txtPhone = TextEditingController(text: widget.user.phoneNumber);

    initialImageUrl = widget.user.avatar;

    _controller.loadRoles().then((_) {
      final initialRole = _controller.role?.firstWhereOrNull(
        (role) => role.roleId == widget.user.roleId,
      );
      _controller.setSelectedRole(initialRole);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.uploadedImageUrl = initialImageUrl;
      _controller.isUploadingImage = false;
      _controller.selectedImageFile = null;
      _controller.update();
    });
  }

  Future<void> _pickImage() async {
    await _controller.pickAndUploadImage();
  }

  Future<void> _updateUser() async {
    if (txtId.text.isEmpty ||
        txtUserName.text.isEmpty ||
        txtEmail.text.isEmpty ||
        txtPhone.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return;
    }

    // Kiểm tra định dạng email cơ bản
    if (!GetUtils.isEmail(txtEmail.text)) {
      Get.snackbar('Lỗi', 'Email không hợp lệ.');
      return;
    }

    if (_controller.selectedRole == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn vai trò.');
      return;
    }

    // Đảm bảo có ảnh đại diện (sử dụng ảnh cũ nếu không có ảnh mới)
    final String finalAvatarUrl =
        _controller.uploadedImageUrl ?? initialImageUrl ?? '';
    if (finalAvatarUrl.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng tải lên ảnh đại diện.');
      return;
    }

    final updatedUser = AppUser(
      userId: txtId.text,
      userName: txtUserName.text,
      email: txtEmail.text,
      phoneNumber: txtPhone.text,
      roleId: _controller.selectedRole!.roleId,
      avatar: finalAvatarUrl,
      isActive: widget.user.isActive, // Giữ nguyên trạng thái active
    );

    await _controller.updateUser(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Cập nhật người dùng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
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
                        decoration: const InputDecoration(
                          labelText: "ID người dùng",
                          border: OutlineInputBorder(),
                          hintText: "ID duy nhất",
                          enabled: false, // ID thường không được phép sửa
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: txtUserName,
                        decoration: const InputDecoration(
                          labelText: "Tên người dùng",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: txtEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: txtPhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GetBuilder<UserAdminController>(
                        builder: (controller) {
                          return DropdownButtonFormField<Role>(
                            value:
                                controller.selectedRole != null &&
                                        controller.role != null &&
                                        controller.role!.contains(
                                          controller.selectedRole!,
                                        )
                                    ? controller.selectedRole
                                    : null,
                            decoration: const InputDecoration(
                              labelText: "Vai trò",
                              border: OutlineInputBorder(),
                            ),
                            items:
                                controller.role?.map((Role role) {
                                  return DropdownMenuItem<Role>(
                                    value: role,
                                    child: Text(role.roleName ?? ""),
                                  );
                                }).toList(),
                            onChanged: (Role? newValue) {
                              controller.setSelectedRole(newValue);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn vai trò';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      GetBuilder<UserAdminController>(
                        builder: (controller) => _buildImagePreview(controller),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Chọn ảnh đại diện"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Cập nhật người dùng"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(UserAdminController controller) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child:
          controller.isUploadingImage
              ? const Center(child: CircularProgressIndicator())
              : controller.uploadedImageUrl != null &&
                  controller.uploadedImageUrl!.isNotEmpty
              ? Image.network(
                controller.uploadedImageUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red),
              )
              : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.grey),
                  Text('Chưa có ảnh', style: TextStyle(color: Colors.grey)),
                ],
              ),
    );
  }

  @override
  void dispose() {
    txtId.dispose();
    txtUserName.dispose();
    txtEmail.dispose();
    txtPhone.dispose();
    // _controller.resetImageState();
    super.dispose();
  }
}
