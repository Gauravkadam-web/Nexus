class UserModel {
  final String id;
  final String email;
  final String name;
  final String? organizationId;
  final String? organizationName;
  final List<String> roles;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.organizationId,
    this.organizationName,
    required this.roles,
    this.avatarUrl,
  });

  bool get isRequester => roles.contains('REQUESTER');
  bool get isOperator => roles.contains('OPERATOR') || roles.contains('CASE_OPERATOR');
  bool get isTeamLead => roles.contains('TEAM_LEAD');
  bool get isManager => roles.contains('MANAGER');
  bool get isAdmin => roles.contains('ADMIN') || roles.contains('ADMINISTRATOR');

  String get role => primaryRole;

  String get primaryRole {
    if (isAdmin) return 'ADMIN';
    if (isManager) return 'MANAGER';
    if (isTeamLead) return 'TEAM_LEAD';
    if (isOperator) return 'OPERATOR';
    return 'REQUESTER';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['email'] as String? ?? '',
      organizationId: json['organizationId'] as String?,
      organizationName: json['organizationName'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['REQUESTER'],
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'roles': roles,
      'avatarUrl': avatarUrl,
    };
  }
}
