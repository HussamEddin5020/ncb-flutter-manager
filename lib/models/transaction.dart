enum TransactionType {
  localCard,    // بطاقة محلية
  namCard,      // بطاقة نمو
  visaCard,     // بطاقة Visa
  masterCard,   // بطاقة Mastercard
  certifiedCheck, // صك مصدق
}

class Transaction {
  final String id;
  final String customerId;
  final TransactionType type;
  final String description;
  final double amount;
  final DateTime readyDate;
  final DateTime? completedDate;
  final String? transactionNumber;

  Transaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.description,
    required this.amount,
    required this.readyDate,
    this.completedDate,
    this.transactionNumber,
  });

  String get typeName {
    switch (type) {
      case TransactionType.localCard:
        return 'بطاقة محلية';
      case TransactionType.namCard:
        return 'بطاقة نمو';
      case TransactionType.visaCard:
        return 'بطاقة Visa';
      case TransactionType.masterCard:
        return 'بطاقة Mastercard';
      case TransactionType.certifiedCheck:
        return 'صك مصدق';
    }
  }

  // Helper function to safely convert to double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Convert from API JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    TransactionType type;
    switch (json['transaction_type']) {
      case 'localCard':
        type = TransactionType.localCard;
        break;
      case 'namCard':
        type = TransactionType.namCard;
        break;
      case 'visaCard':
        type = TransactionType.visaCard;
        break;
      case 'masterCard':
        type = TransactionType.masterCard;
        break;
      case 'certifiedCheck':
        type = TransactionType.certifiedCheck;
        break;
      default:
        type = TransactionType.localCard;
    }

    return Transaction(
      id: json['id'].toString(),
      customerId: json['customer_id']?.toString() ?? json['transaction_id']?.toString() ?? '',
      type: type,
      description: json['description'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      readyDate: json['ready_date'] != null
          ? DateTime.parse(json['ready_date'])
          : DateTime.now(),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      transactionNumber: json['transaction_number'],
    );
  }
}


