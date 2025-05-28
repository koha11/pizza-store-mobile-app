import '../helpers/supabase.helper.dart';

class Role{
  String roleId;
  String? roleName, description;

  static const String tableName = "role";

  Role({
    required this.roleId,
    required this.roleName,
    required this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json){
    return Role(
        roleId: json['role_id'],
        roleName: json['role_name'],
        description: json['description'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'role_id': roleId,
      'role_name': roleName,
      'description': description,
    };
  }
}

class RoleSnapshot {
  Role role;

  RoleSnapshot(this.role);

  static Future<List<Role>> getRoles() async {
    return SupabaseSnapshot.getList(
      table: Role.tableName,
      fromJson: Role.fromJson,
    );
  }

  static Future<Map<String, Role>> getMapRoles() {
    return SupabaseSnapshot.getMapT<String, Role>(
      table: Role.tableName,
      fromJson: Role.fromJson,
      getId: (p0) => p0.roleId!,
    );
  }
}