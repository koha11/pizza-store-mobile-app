import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/dialogs/dialog.dart';

import '../../controllers/controller_user_admin.dart';

class PageAppUserAdmin extends StatefulWidget {
  PageAppUserAdmin({super.key});

  @override
  State<PageAppUserAdmin> createState() => _PageAppUserAdminState();
}

class _PageAppUserAdminState extends State<PageAppUserAdmin> {
  final adminUserController = Get.put(UserAdminController());

  @override
  void initState() {
    super.initState();
    adminUserController.resetSearchState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserAdminController>(
      init: UserAdminController.get(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Quản lý Khách hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm khách hàng...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: controller.handleSearch,
                      ),
                    ),
                    const Expanded(flex: 1, child: Text("")),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () => showAddUserDialog(context),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue[200]!,
                          ),
                        ),
                        tooltip: 'Thêm khách hàng',
                        icon: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Thêm'),
                            SizedBox(width: 8.0),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const SizedBox(height: 2),
                  controller.isLoadingUser
                      ? const Center(child: CircularProgressIndicator())
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
                                      child: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          'Ảnh đại diện',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Tên người dùng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Số điện thoại',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Vai trò',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Thao tác',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.paginatedUser.length,
                                itemBuilder: (context, index) {
                                  final user = controller.paginatedUser[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(user.userId),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child:
                                              user.avatar != null &&
                                                      user.avatar!.isNotEmpty
                                                  ? CircleAvatar(
                                                    radius: 25,
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        user.avatar!,
                                                        fit: BoxFit.cover,
                                                        width: 50,
                                                        height: 50,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons.person,
                                                            size: 30,
                                                          );
                                                        },
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return const CircularProgressIndicator();
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                  : const CircleAvatar(
                                                    radius: 25,
                                                    child: Icon(Icons.person),
                                                  ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(user.userName),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(user.phoneNumber),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(user.email ?? ""),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(user.roleId),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                color: Colors.blue,
                                                onPressed:
                                                    () => showUpdateUserDialog(
                                                      context,
                                                      user,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () async {
                                                  await controller
                                                      .confirmAndRemoveUser(
                                                        context,
                                                        user,
                                                      );
                                                },
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
                                        controller.currentPage > 1
                                            ? controller.previousPage
                                            : null,
                                  ),
                                  Text(
                                    'Trang ${controller.currentPage}/${controller.totalPages}',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed:
                                        controller.currentPage <
                                                controller.totalPages
                                            ? controller.nextPage
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
          ),
        );
      },
    );
  }
}
