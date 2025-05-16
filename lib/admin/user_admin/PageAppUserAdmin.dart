import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class PageAppUserAdmin extends StatefulWidget {
  const PageAppUserAdmin({super.key});

  @override
  State<PageAppUserAdmin> createState() => _PageAppUserAdminState();
}

class _PageAppUserAdminState extends State<PageAppUserAdmin> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserAdminController(context)..fetchUsers(),
      child: const _UserAdminView(),
    );
  }
}

class _UserAdminView extends StatelessWidget {
  const _UserAdminView();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserAdminController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const SizedBox(height: 10),
            Row(children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Quản lý Người dùng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
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
                  onPressed: controller.showAddUserDialog,
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue[200]!),
                  ),
                  tooltip: 'Thêm người dùng',
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
            controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMessage != null
                ? Center(child: Text('Lỗi: $controller.errorMessage'))
                : controller.users.isEmpty
                ? const Center(child: Text('Không có người dùng nào'))
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
                              flex: 2,
                              child: Text('ID',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 3,
                              child: Text('Tên người dùng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          const Expanded(
                              flex: 3,
                              child: Text('Số điện thoại',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                          const Expanded(
                              flex: 2,
                              child: Text('Vai trò',
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
                      itemCount: controller.users.length,
                      separatorBuilder: (context, index) =>
                      const Divider(),
                      itemBuilder: (context, index) {
                        final user = controller.users[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(user.userId)),
                              Expanded(
                                  flex: 3,
                                  child: Text(user.userName)),
                              Expanded(
                                  flex: 3, child: Text(user.phoneNumber)),
                              Expanded(
                                  flex: 2, child: Text(user.roleId)),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () =>
                                          controller.showUpdateUserDialog(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () =>
                                          controller.showDeleteUserDialog(user), // Gọi _showDeleteUserDialog
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
                          controller.currentPage > 1 ? controller.previousPage : null,
                        ),
                        Text(
                          'Trang ${Provider.of<UserAdminController>(context).currentPage}/${Provider.of<UserAdminController>(context).totalPages}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: controller.currentPage < controller.totalPages
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
    );
  }
}

