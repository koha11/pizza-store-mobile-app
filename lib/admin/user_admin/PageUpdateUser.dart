import 'package:flutter/material.dart';
import 'package:pizza_store_app/admin/model/app_user.admin.model.dart';
import '../controllers/user_controller.dart';

class PageUpdateUser extends StatefulWidget {
  final UserAdmin user;

  const PageUpdateUser({super.key, required this.user});

  @override
  State<PageUpdateUser> createState() => _PageUpdateUserState();
}

class _PageUpdateUserState extends State<PageUpdateUser> {
  late final UserUpdateController _controller;
  final _userNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  Future<List<String>>? _rolesFuture;

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.user.userName;
    _phoneNumberController.text = widget.user.phoneNumber;
    _controller = UserUpdateController(
      user: widget.user,
      userNameController: _userNameController,
      phoneNumberController: _phoneNumberController,
      selectedRoleId: widget.user.roleId,
    );
    _rolesFuture = _controller.fetchRoles();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    final success = await _controller.updateUser(context);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Chỉnh Sửa Thông Tin Người Dùng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User ID (Không cho phép chỉnh sửa)
            TextFormField(
              initialValue: widget.user.userId,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "User ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // User Name
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: "Tên người dùng",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Phone Number
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Role ID Dropdown
            FutureBuilder<List<String>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Lỗi tải Roles: ${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Text('Không có Role nào.');
                } else {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Role ID",
                      border: OutlineInputBorder(),
                    ),
                    value: _controller.selectedRoleId,
                    items: snapshot.data!.map((roleId) {
                      return DropdownMenuItem<String>(
                        value: roleId,
                        child: Text(roleId),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _controller.selectedRoleId = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn Role ID';
                      }
                      return null;
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(flex: 3, child: Text("")),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Cập nhật",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 3, child: Text("")),
              ],
            )
          ],
        ),
      ),
    );
  }
}