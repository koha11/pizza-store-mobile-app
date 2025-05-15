import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class PageAddUser extends StatefulWidget {
  const PageAddUser({Key? key}) : super(key: key);

  @override
  State<PageAddUser> createState() => _PageAddUserState();
}

class _PageAddUserState extends State<PageAddUser> {
  final _controller = AddUserController();
  Future<List<String>>? _rolesFuture;

  @override
  void initState() {
    super.initState();
    _rolesFuture = _controller.fetchRoles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAddUserPressed() async {
    final success = await _controller.addUser(context);
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Thêm Mới Người Dùng",
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
            // User ID
            TextFormField(
              controller: _controller.userIdController,
              decoration: const InputDecoration(
                labelText: "User ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // User Name
            TextFormField(
              controller: _controller.userNameController,
              decoration: const InputDecoration(
                labelText: "Tên người dùng",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Phone Number
            TextFormField(
              controller: _controller.phoneNumberController,
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
                    onPressed: _onAddUserPressed,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Thêm mới",
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