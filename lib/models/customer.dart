class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String accountNumber;
  final String passportNumber;
  final String? email;
  final int? branchId;
  final String? branchName;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.accountNumber,
    required this.passportNumber,
    this.email,
    this.branchId,
    this.branchName,
  });

  // Convert from API JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? json['customer_id']?.toString() ?? '',
      name: json['name'] ?? json['customer_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      accountNumber: json['account_number'] ?? '',
      passportNumber: json['passport_number'] ?? '',
      email: json['email'],
      branchId: json['branch_id'] != null ? int.tryParse(json['branch_id'].toString()) : null,
      branchName: json['branch_name'] ?? json['branch']?['name'],
    );
  }
}


