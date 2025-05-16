import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../helpers/supabase.helper.dart' as SupabaseHelper; // Import with alias
import '../admin_dialogs/admin_dialogs.dart'; // Ensure this path is correct
import '../model/app_user.admin.model.dart';
import '../user_admin/PageAddUser.dart';
import '../user_admin/PageUpdateUser.dart'; // Ensure this path is correct

class UserAdminController extends ChangeNotifier {
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  int _totalPages = 0;
  List<UserAdmin> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchQuery;
  final BuildContext context; // Add context

  UserAdminController(this.context) { // Constructor to receive context
    fetchUsers();
  }

  List<UserAdmin> get users => _users;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Use a consistent naming convention (async/await)
  Future<void> fetchUsers({String? searchQuery}) async {
    setLoading(true);
    setErrorMessage(null); // Clear previous errors

    try {
      final int startIndex = (_currentPage - 1) * _itemsPerPage;
      final List<UserAdmin> fetchedUsers =
      await UserAdminSnapshot.getUserAdminWithPagination(
        startIndex: startIndex,
        limit: _itemsPerPage,
        searchQuery: searchQuery,
      );

      final int totalUsers = await UserAdminSnapshot.getTotalUserAdmin(
          searchQuery: searchQuery);

      setUsers(fetchedUsers);
      setTotalPages((totalUsers / _itemsPerPage).ceil());
    } catch (error) {
      setErrorMessage(error.toString());
    } finally {
      setLoading(false);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      setCurrentPage(_currentPage - 1);
      fetchUsers(searchQuery: _searchQuery);
    }
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      setCurrentPage(_currentPage + 1);
      fetchUsers(searchQuery: _searchQuery);
    }
  }

  void handleSearch(String value) {
    setSearchQuery(value);
    setCurrentPage(1); // Reset to first page on search
    fetchUsers(searchQuery: _searchQuery);
  }

  // Encapsulate state updates
  void setUsers(List<UserAdmin> users) {
    _users = users;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setTotalPages(int pages) {
    _totalPages = pages;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Use async/await for dialogs and database operations
  Future<void> showAddUserDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return const Dialog( // Corrected const
          child: SizedBox(
            width: 600, // Use a constant for better readability and maintainability
            child: PageAddUser(),
          ),
        );
      },
    );
    if (result == true) {
      await fetchUsers(); // Await the completion of _fetchUsers
    }
  }

  Future<void> showUpdateUserDialog(UserAdmin user) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 600, // Use the same constant
            child: PageUpdateUser(user: user),
          ),
        );
      },
    );
    if (result == true) {
      await fetchUsers(); // Await
    }
  }

  // Improved error handling and clarity
  Future<void> showDeleteUserDialog(UserAdmin user) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      "Bạn có muốn xóa người dùng ${user.userName}?",
    );
    if (confirmed == true) {
      setLoading(true);
      try {
        final supabase = SupabaseHelper.supabase;
        // Delete related data
        await deleteRelatedData(supabase, user.userId);
        // Delete the user
        await UserAdminSnapshot.delete(user.userId);
        await fetchUsers(); // Refresh the list
        showSnackBar("Đã xóa người dùng ${user.userName}"); // Use the helper
      } catch (error) {
        handleDeleteError(error);
      } finally {
        setLoading(false);
      }
    }
  }

  // Helper function to delete related data
  Future<void> deleteRelatedData(SupabaseClient supabase, String userId) async {
    // Delete addresses first
    await supabase.from('user_address').delete().eq('user_id', userId);
    // Delete order variants associated with the user's orders
    final List<Map<String, dynamic>> userOrders = await supabase
        .from('customer_order')
        .select('order_id')
        .eq('customer_id', userId);
    for (var order in userOrders) {
      await supabase.from('order_variant').delete().eq('order_id', order['order_id']);
    }
    // Delete order details associated with the user's orders
    for (var order in userOrders) {
      await supabase.from('order_detail').delete().eq('order_id', order['order_id']);
    }
    // Delete orders associated with the user.
    await supabase.from('customer_order').delete().eq('customer_id', userId);
  }
  // Helper function to handle delete errors
  void handleDeleteError(dynamic error) {
    String errorMessage = "Lỗi khi xóa: $error";
    if (error is PostgrestException) {
      errorMessage = "Lỗi xóa người dùng: ${error.message}";
    }
    setErrorMessage(errorMessage);
    showSnackBar(errorMessage); // Show error message
  }

  // Helper method to show snackbar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // important to prevent memory leaks
    super.dispose();
  }
}

class AddUserController {
  final userIdController = TextEditingController();
  final userNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String? selectedRoleId;

  Future<List<String>> fetchRoles() async {
    try {
      final res = await SupabaseHelper.supabase.from('role').select('role_id');
      if (res == null) return [];
      return (res as List).map((e) => e['role_id'] as String).toList();
    } catch (e) {
      print('Lỗi khi tải danh sách role: $e');
      return [];
    }
  }

  Future<bool> addUser(BuildContext context) async {
    if (userIdController.text.isEmpty ||
        userNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Vui lòng nhập đầy đủ thông tin người dùng và chọn Role!')),
      );
      return false;
    }
    final newUser = UserAdmin(
      userId: userIdController.text,
      userName: userNameController.text,
      phoneNumber: phoneNumberController.text,
      roleId: selectedRoleId!,
    );

    final result = await UserAdminSnapshot.insert(newUser);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm người dùng thành công!')),
      );
      clearFields();
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi khi thêm người dùng vào cơ sở dữ liệu.')),
      );
      return false;
    }
  }

  void clearFields() {
    userIdController.clear();
    userNameController.clear();
    phoneNumberController.clear();
    selectedRoleId = null;
  }

  void dispose() {
    userIdController.dispose();
    userNameController.dispose();
    phoneNumberController.dispose();
  }
}

class UserUpdateController {
  final UserAdmin user;
  final TextEditingController userNameController;
  final TextEditingController phoneNumberController;
  String? selectedRoleId;

  UserUpdateController({
    required this.user,
    required this.userNameController,
    required this.phoneNumberController,
    required this.selectedRoleId,
  });

  // Hàm lấy danh sách các role từ database
  Future<List<String>> fetchRoles() async {
    try {
      final res = await SupabaseHelper.supabase.from('role').select('role_id');
      if (res == null) {
        return [];
      }
      return (res as List).map((json) => json['role_id'] as String).toList();
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách role: $e');
      return [];
    }
  }

  // Hàm kiểm tra dữ liệu đầu vào
  bool validateInput(BuildContext context) {
    if (userNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin người dùng và chọn Role!'),
        ),
      );
      return false;
    }
    return true;
  }

  // Hàm cập nhật thông tin người dùng
  Future<bool> updateUser(BuildContext context) async {
    if (!validateInput(context)) return false;

    final updatedUser = UserAdmin(
      userId: user.userId,
      userName: userNameController.text,
      phoneNumber: phoneNumberController.text,
      roleId: selectedRoleId!,
    );

    try {
      await UserAdminSnapshot.update(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin người dùng thành công!'),
        ),
      );
      return true;
    } catch (error) {
      debugPrint('Lỗi khi cập nhật người dùng: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi cập nhật thông tin người dùng.'),
        ),
      );
      return false;
    }
  }
}

