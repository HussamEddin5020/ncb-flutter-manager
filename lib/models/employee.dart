class Employee {
  final int id;
  final String employeeId;
  final String name;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isActive: (json['is_active'] as int? ?? json['is_active'] as bool? ?? 1) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get roleName {
    switch (role) {
      case 'manager':
        return 'مدير';
      case 'employee':
        return 'موظف';
      default:
        return role;
    }
  }
}


