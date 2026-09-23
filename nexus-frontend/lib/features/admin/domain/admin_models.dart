class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? organizationId;
  final String? teamName;
  final bool isActive;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.organizationId,
    this.teamName,
    this.isActive = true,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? (json['roles'] != null && (json['roles'] as List).isNotEmpty ? (json['roles'] as List).first.toString() : 'REQUESTER'),
      organizationId: json['organizationId'] as String?,
      teamName: json['teamName'] as String? ?? 'Operations',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

class SlaPolicyModel {
  final String id;
  final String name;
  final String priority; // CRITICAL, HIGH, MEDIUM, LOW
  final int responseTimeMinutes;
  final int resolutionTimeMinutes;
  final bool isDefault;
  final bool isActive;

  const SlaPolicyModel({
    required this.id,
    required this.name,
    required this.priority,
    required this.responseTimeMinutes,
    required this.resolutionTimeMinutes,
    this.isDefault = false,
    this.isActive = true,
  });

  factory SlaPolicyModel.fromJson(Map<String, dynamic> json) {
    return SlaPolicyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['policyName'] as String? ?? 'Standard SLA',
      priority: json['priority'] as String? ?? json['severity'] as String? ?? 'MEDIUM',
      responseTimeMinutes: (json['responseTimeMinutes'] as num?)?.toInt() ?? 60,
      resolutionTimeMinutes: (json['resolutionTimeMinutes'] as num?)?.toInt() ?? 240,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class EscalationRuleModel {
  final String id;
  final String name;
  final String triggerCondition;
  final String escalateToRole;

  const EscalationRuleModel({
    required this.id,
    required this.name,
    required this.triggerCondition,
    required this.escalateToRole,
  });

  factory EscalationRuleModel.fromJson(Map<String, dynamic> json) {
    return EscalationRuleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['ruleName'] as String? ?? 'Tier 1 Escalation',
      triggerCondition: json['triggerCondition'] as String? ?? json['condition'] as String? ?? '75% SLA threshold',
      escalateToRole: json['escalateToRole'] as String? ?? json['targetRole'] as String? ?? 'SHIFT_LEAD',
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class TeamModel {
  final String id;
  final String name;
  final String? description;
  final int memberCount;

  const TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}
