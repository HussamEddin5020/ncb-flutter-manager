import 'package:flutter/material.dart';
import 'package:manager_web/models/customer.dart';
import 'package:manager_web/models/transaction.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';
import 'package:manager_web/services/api_service.dart';

class CustomerTransactionsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerTransactionsScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerTransactionsScreen> createState() => _CustomerTransactionsScreenState();
}

class _CustomerTransactionsScreenState extends State<CustomerTransactionsScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get completed transactions for this customer
      final result = await ApiService.getCompletedTransactions();

      if (mounted) {
        if (result['success'] == true && result['data'] != null) {
          final transactionsData = result['data'] as List;
          final customerTransactions = <Transaction>[];

          // Filter transactions for this customer
          for (var item in transactionsData) {
            if (item['customer_id'].toString() == widget.customer.id) {
              // Get full details
              final detailsResult = await ApiService.getCompletedTransactionDetails(
                int.parse(item['id'].toString()),
              );

              if (detailsResult['success'] == true && detailsResult['data'] != null) {
                final detail = detailsResult['data'];
                if (detail['details'] != null) {
                  for (var t in detail['details']) {
                    customerTransactions.add(Transaction.fromJson(t));
                  }
                }
              }
            }
          }

          setState(() {
            _transactions = customerTransactions;
            _isLoading = false;
          });
        } else {
          setState(() {
            _transactions = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transactions = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Info Card
                Container(
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'بيانات العميل',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontFamily: 'Tajawal',
                              ),
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      _buildCustomerInfoRow('الاسم', widget.customer.name),
                      const Divider(height: 1, thickness: 0.5),
                      _buildCustomerInfoRow(
                        'رقم الحساب',
                        widget.customer.accountNumber,
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      _buildCustomerInfoRow(
                        'رقم الهاتف',
                        widget.customer.phoneNumber,
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      _buildCustomerInfoRow(
                        'رقم جواز السفر',
                        widget.customer.passportNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transactions Card
                Container(
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المعاملات المستلمة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_transactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'لا توجد معاملات مستلمة',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        )
                      else
                        ..._transactions.map((transaction) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getTransactionTypeIcon(transaction.type),
                                        size: 24,
                                        color: const Color(0xFF1a5d2e),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          transaction.typeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (transaction.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      transaction.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                  if (transaction.transactionNumber != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'رقم المعاملة: ${transaction.transactionNumber}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                  if (transaction.completedDate != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'تاريخ الاستلام: ${_formatDate(transaction.completedDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const PoweredByCactus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
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
        return Icons.receipt_long;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}


