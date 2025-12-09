import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_web/models/customer.dart';
import 'package:manager_web/models/transaction.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';

class CompletedTransaction {
  final String id;
  final Customer customer;
  final List<Transaction> transactions;
  final DateTime completedDate;
  final String? transactionNumber;

  CompletedTransaction({
    required this.id,
    required this.customer,
    required this.transactions,
    required this.completedDate,
    this.transactionNumber,
  });
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<CompletedTransaction> _completedTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedTransactions();
  }

  void _loadCompletedTransactions() {
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // Mock data
          _completedTransactions = [
            CompletedTransaction(
              id: '1',
              customer: Customer(
                id: '1',
                name: 'أحمد محمد علي',
                phoneNumber: '0912345678',
                accountNumber: '123456789',
                passportNumber: 'P123456',
              ),
              transactions: [
                Transaction(
                  id: '1',
                  customerId: '1',
                  type: TransactionType.localCard,
                  description: 'بطاقة محلية - معاملة رقم 1',
                  amount: 0.0,
                  readyDate: DateTime.now().subtract(const Duration(days: 5)),
                  completedDate: DateTime.now().subtract(const Duration(days: 5)),
                  transactionNumber: 'TXN-001',
                ),
              ],
              completedDate: DateTime.now().subtract(const Duration(days: 5)),
              transactionNumber: 'TXN-001',
            ),
            CompletedTransaction(
              id: '2',
              customer: Customer(
                id: '2',
                name: 'فاطمة أحمد حسن',
                phoneNumber: '0923456789',
                accountNumber: '987654321',
                passportNumber: 'P789012',
              ),
              transactions: [
                Transaction(
                  id: '2',
                  customerId: '2',
                  type: TransactionType.visaCard,
                  description: 'بطاقة Visa - معاملة رقم 2',
                  amount: 0.0,
                  readyDate: DateTime.now().subtract(const Duration(days: 3)),
                  completedDate: DateTime.now().subtract(const Duration(days: 3)),
                  transactionNumber: 'TXN-002',
                ),
                Transaction(
                  id: '3',
                  customerId: '2',
                  type: TransactionType.masterCard,
                  description: 'بطاقة Mastercard - معاملة رقم 3',
                  amount: 0.0,
                  readyDate: DateTime.now().subtract(const Duration(days: 3)),
                  completedDate: DateTime.now().subtract(const Duration(days: 3)),
                  transactionNumber: 'TXN-002',
                ),
              ],
              completedDate: DateTime.now().subtract(const Duration(days: 3)),
              transactionNumber: 'TXN-002',
            ),
            CompletedTransaction(
              id: '3',
              customer: Customer(
                id: '3',
                name: 'محمد خالد إبراهيم',
                phoneNumber: '0934567890',
                accountNumber: '456789123',
                passportNumber: 'P456789',
              ),
              transactions: [
                Transaction(
                  id: '4',
                  customerId: '3',
                  type: TransactionType.namCard,
                  description: 'بطاقة نمو - معاملة رقم 4',
                  amount: 0.0,
                  readyDate: DateTime.now().subtract(const Duration(days: 1)),
                  completedDate: DateTime.now().subtract(const Duration(days: 1)),
                  transactionNumber: 'TXN-003',
                ),
              ],
              completedDate: DateTime.now().subtract(const Duration(days: 1)),
              transactionNumber: 'TXN-003',
            ),
          ];
          _isLoading = false;
        });
      }
    });
  }

  String _getTransactionTypeName(TransactionType type) {
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

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.localCard:
        return Icons.credit_card;
      case TransactionType.namCard:
        return Icons.credit_card;
      case TransactionType.visaCard:
        return Icons.credit_card;
      case TransactionType.masterCard:
        return Icons.credit_card;
      case TransactionType.certifiedCheck:
        return Icons.description;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاملات مستلمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', 'ar');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _completedTransactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 3,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'معاملة مكتملة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 8),
              _buildInfoRow('الاسم', transaction.customer.name),
              _buildInfoRow('رقم الهاتف', transaction.customer.phoneNumber),
              _buildInfoRow('رقم الحساب', transaction.customer.accountNumber),
              if (transaction.transactionNumber != null)
                _buildInfoRow('رقم المعاملة', transaction.transactionNumber!),
              _buildInfoRow(
                'تاريخ الإنجاز',
                dateFormat.format(transaction.completedDate),
              ),
              const SizedBox(height: 12),
              Text(
                'المعاملات:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              ...transaction.transactions.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTransactionTypeIcon(t.type),
                          size: 20,
                          color: const Color(0xFF1a5d2e),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTransactionTypeName(t.type),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              if (t.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  t.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a5d2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/logo.png',
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a5d2e),
              Color(0xFF2d7a47),
              Color(0xFF1a5d2e),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _completedTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionsList(),
        ),
      ),
      bottomNavigationBar: const PoweredByCactus(),
    );
  }
}


