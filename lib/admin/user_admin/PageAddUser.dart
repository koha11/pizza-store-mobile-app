import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/user_role.model.dart';

import '../../controllers/controller_admin_user.dart';
import '../../controllers/controller_user.dart';

class PageAddUser extends StatefulWidget {
  const PageAddUser({super.key});

  @override
  State<PageAddUser> createState() => _PageAddUserState();
}

class _PageAddUserState extends State<PageAddUser> {
  final AdminUserController _controller = Get.find<AdminUserController>();

  final TextEditingController txtId = TextEditingController();
  final TextEditingController txtUserName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadRoles();
  }

  Future<void> _pickImage() async {
    await _controller.pickAndUploadImage();
  }

  Future<void> _addUser() async {
    if (txtId.text.isEmpty ||
        txtUserName.text.isEmpty ||
        txtEmail.text.isEmpty ||
        txtPhone.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin.');
      return;
    }

    if (!GetUtils.isEmail(txtEmail.text)) {
      Get.snackbar('Lỗi', 'Email không hợp lệ.');
      return;
    }

    // final bool emailExists = await _controller.checkEmailExists(txtEmail.text);
    // if (emailExists) {
    //   Get.snackbar('Lỗi', 'Email này đã được sử dụng. Vui lòng chọn email khác.');
    //   return;
    // }

    if (_controller.selectedRole == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn vai trò.');
      return;
    }

    if (_controller.uploadedImageUrl == null || _controller.uploadedImageUrl!.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng tải lên ảnh đại diện.');
      return;
    }

    final newUser = AppUser(
      userId: txtId.text,
      userName: txtUserName.text,
      email: txtEmail.text,
      phoneNumber: txtPhone.text,
      roleId: _controller.selectedRole!.roleId,
      avatar: _controller.uploadedImageUrl!,
      isActive: true,
    );

    await _controller.addUser(newUser);

    _resetForm();
  }

  void _resetForm() {
    txtId.clear();
    txtUserName.clear();
    txtEmail.clear();
    txtPhone.clear();
    _controller.resetImageState();
    _controller.setSelectedRole(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Thêm người dùng mới",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
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
                          hintText: "Nhập ID duy nhất",
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
                      GetBuilder<AdminUserController>(
                        builder: (controller) {
                          return DropdownButtonFormField<Role>(
                            value: controller.selectedRole,
                            decoration: const InputDecoration(
                              labelText: "Vai trò",
                              border: OutlineInputBorder(),
                            ),
                            items: controller.role?.map((Role role) {
                              return DropdownMenuItem<Role>(
                                value: role,
                                child: Text(role.roleId),
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
                      GetBuilder<AdminUserController>(
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
              onPressed: _addUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Thêm người dùng"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(AdminUserController controller) {
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
    super.dispose();
  }
}