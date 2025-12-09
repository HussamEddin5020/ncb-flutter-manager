import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_web/models/customer.dart';
import 'package:manager_web/models/transaction.dart';
import 'package:manager_web/screens/login_screen.dart';
import 'package:manager_web/screens/employees_management_screen.dart';
import 'package:manager_web/screens/branches_management_screen.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';
import 'package:manager_web/services/api_service.dart';

class CompletedTransaction {
  final String id;
  final Customer customer;
  final List<Transaction> transactions;
  final DateTime completedDate;
  final String? transactionNumber;
  final String? signatureBase64;
  final String? passportImageBase64;

  CompletedTransaction({
    required this.id,
    required this.customer,
    required this.transactions,
    required this.completedDate,
    this.transactionNumber,
    this.signatureBase64,
    this.passportImageBase64,
  });

  int get totalTransactions => transactions.length;
}

class FilteredTransactionsScreen extends StatefulWidget {
  const FilteredTransactionsScreen({super.key});

  @override
  State<FilteredTransactionsScreen> createState() => _FilteredTransactionsScreenState();
}

class _FilteredTransactionsScreenState extends State<FilteredTransactionsScreen> {
  List<CompletedTransaction> _allTransactions = [];
  List<CompletedTransaction> _filteredTransactions = [];
  bool _isLoading = true;

  // Filter controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int? _selectedBranchId;
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadTransactions();
  }

  Future<void> _loadBranches() async {
    try {
      final result = await ApiService.getAllBranches();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _branches = (result['data'] as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      // Silently fail - branches filter is optional
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getCompletedTransactions();

      if (mounted) {
        if (result['success'] == true && result['data'] != null) {
          final transactionsData = result['data'] as List;
          final completedTransactions = <CompletedTransaction>[];

          for (var item in transactionsData) {
            // Get full details for each completed transaction
            final detailsResult = await ApiService.getCompletedTransactionDetails(
              int.parse(item['id'].toString()),
            );

            if (detailsResult['success'] == true && detailsResult['data'] != null) {
              final detail = detailsResult['data'];
              final customer = Customer.fromJson({
                'id': detail['customer_id'],
                'name': detail['customer_name'] ?? '',
                'phone_number': detail['phone_number'] ?? '',
                'account_number': detail['account_number'] ?? '',
                'passport_number': detail['passport_number'] ?? '',
              });

              final transactions = <Transaction>[];
              if (detail['details'] != null) {
                for (var t in detail['details']) {
                  transactions.add(Transaction.fromJson(t));
                }
              }

              completedTransactions.add(
                CompletedTransaction(
                  id: detail['id'].toString(),
                  customer: customer,
                  transactions: transactions,
                  completedDate: DateTime.parse(detail['completed_date']),
                  transactionNumber: detail['transaction_number'],
                  signatureBase64: detail['signature_base64'],
                  passportImageBase64: detail['passport_image_base64'],
                ),
              );
            }
          }

          setState(() {
            _allTransactions = completedTransactions;
            _filteredTransactions = completedTransactions;
            _isLoading = false;
          });
        } else {
          setState(() {
            _allTransactions = [];
            _filteredTransactions = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allTransactions = [];
          _filteredTransactions = [];
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

  void _applyFilters() {
    // Apply local filters
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Phone filter
        if (_phoneController.text.isNotEmpty) {
          if (!transaction.customer.phoneNumber.contains(_phoneController.text)) {
            return false;
          }
        }

        // Account filter
        if (_accountController.text.isNotEmpty) {
          if (!transaction.customer.accountNumber.contains(_accountController.text)) {
            return false;
          }
        }

        // Passport filter
        if (_passportController.text.isNotEmpty) {
          if (!transaction.customer.passportNumber.contains(_passportController.text)) {
            return false;
          }
        }

        // Date filter
        if (_dateFrom != null) {
          if (transaction.completedDate.isBefore(_dateFrom!)) {
            return false;
          }
        }
        if (_dateTo != null) {
          final dateToEnd = DateTime(
            _dateTo!.year,
            _dateTo!.month,
            _dateTo!.day,
            23,
            59,
            59,
          );
          if (transaction.completedDate.isAfter(dateToEnd)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  // Reload with API filters (for date range)
  Future<void> _reloadWithFilters() async {
    if (_dateFrom == null && _dateTo == null && 
        _phoneController.text.isEmpty && 
        _accountController.text.isEmpty && 
        _passportController.text.isEmpty &&
        _selectedBranchId == null) {
      // No filters, just reload all
      await _loadTransactions();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? startDate;
      String? endDate;

      if (_dateFrom != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_dateFrom!);
      }
      if (_dateTo != null) {
        endDate = DateFormat('yyyy-MM-dd').format(_dateTo!);
      }

      final result = await ApiService.getCompletedTransactions(
        startDate: startDate,
        endDate: endDate,
        branchId: _selectedBranchId,
      );

      if (mounted) {
        if (result['success'] == true && result['data'] != null) {
          final transactionsData = result['data'] as List;
          final completedTransactions = <CompletedTransaction>[];

          for (var item in transactionsData) {
            // Get full details for each completed transaction
            final detailsResult = await ApiService.getCompletedTransactionDetails(
              int.parse(item['id'].toString()),
            );

            if (detailsResult['success'] == true && detailsResult['data'] != null) {
              final detail = detailsResult['data'];
              final customer = Customer.fromJson({
                'id': detail['customer_id'],
                'name': detail['customer_name'] ?? '',
                'phone_number': detail['phone_number'] ?? '',
                'account_number': detail['account_number'] ?? '',
                'passport_number': detail['passport_number'] ?? '',
              });

              final transactions = <Transaction>[];
              if (detail['details'] != null) {
                for (var t in detail['details']) {
                  transactions.add(Transaction.fromJson(t));
                }
              }

              completedTransactions.add(
                CompletedTransaction(
                  id: detail['id'].toString(),
                  customer: customer,
                  transactions: transactions,
                  completedDate: DateTime.parse(detail['completed_date']),
                  transactionNumber: detail['transaction_number'],
                  signatureBase64: detail['signature_base64'],
                  passportImageBase64: detail['passport_image_base64'],
                ),
              );
            }
          }

          setState(() {
            _allTransactions = completedTransactions;
            _isLoading = false;
          });

          // Apply local filters (phone, account, passport)
          _applyFilters();
        } else {
          setState(() {
            _allTransactions = [];
            _filteredTransactions = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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

  void _clearFilters() {
    setState(() {
      _phoneController.clear();
      _accountController.clear();
      _passportController.clear();
      _dateFrom = null;
      _dateTo = null;
      _selectedBranchId = null;
      _filteredTransactions = _allTransactions;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_dateFrom ?? DateTime.now()) : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      // Reload with new date filters
      _reloadWithFilters();
    }
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
    return Icons.credit_card;
  }

  void _showTransactionDetails(BuildContext context, CompletedTransaction transaction) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.52, // تقليل العرض بمقدار 35% (من 80% إلى 52%)
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'تفاصيل المعاملات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Customer Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('الاسم', transaction.customer.name),
                    const SizedBox(height: 8),
                    _buildDetailRow('رقم الهاتف', transaction.customer.phoneNumber),
                    const SizedBox(height: 8),
                    _buildDetailRow('رقم الحساب', transaction.customer.accountNumber),
                    const SizedBox(height: 8),
                    _buildDetailRow('رقم جواز السفر', transaction.customer.passportNumber),
                    if (transaction.transactionNumber != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('رقم المعاملة', transaction.transactionNumber!),
                    ],
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'تاريخ الإنجاز',
                      dateFormat.format(transaction.completedDate),
                    ),
                  ],
                ),
              ),
              // Signature and Passport Image Buttons
              if (transaction.signatureBase64 != null || transaction.passportImageBase64 != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (transaction.signatureBase64 != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImageDialog(
                            context,
                            transaction.signatureBase64!,
                            'التوقيع',
                          ),
                          icon: const Icon(Icons.draw, size: 18),
                          label: const Text('عرض التوقيع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a5d2e),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (transaction.signatureBase64 != null && transaction.passportImageBase64 != null)
                      const SizedBox(width: 8),
                    if (transaction.passportImageBase64 != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImageDialog(
                            context,
                            transaction.passportImageBase64!,
                            'صورة جواز السفر',
                          ),
                          icon: const Icon(Icons.credit_card, size: 18),
                          label: const Text('صورة الجواز'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a5d2e),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'المعاملات:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 12),
              // Transactions List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transaction.transactions.length,
                  itemBuilder: (context, index) {
                    final t = transaction.transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getTransactionTypeIcon(t.type),
                            size: 24,
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
                                    fontSize: 16,
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
                                      fontSize: 14,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a5d2e),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontFamily: 'Tajawal'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String base64Image, String title) {
    try {
      // Remove data URI prefix if present
      String cleanBase64 = base64Image.trim();
      
      // Check if it contains data URI prefix
      if (cleanBase64.contains('data:')) {
        // Extract base64 part after comma
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        } else {
          // If no comma, try to extract after base64
          final base64Index = cleanBase64.indexOf('base64');
          if (base64Index != -1) {
            cleanBase64 = cleanBase64.substring(base64Index + 6).trim();
            // Remove any remaining prefix characters
            if (cleanBase64.startsWith(':')) {
              cleanBase64 = cleanBase64.substring(1).trim();
            }
          }
        }
      }
      
      // Decode and show image
      final imageBytes = base64Decode(cleanBase64);
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a5d2e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Show error dialog if decoding fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('خطأ'),
          content: Text('فشل عرض الصورة: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'فلاتر البحث',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 16),
          // Filters Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Phone Filter
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _phoneController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: 'ابحث برقم الهاتف',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: const Color(0xFFF2F2F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              // Account Filter
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _accountController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'رقم الحساب',
                    hintText: 'ابحث برقم الحساب',
                    prefixIcon: const Icon(Icons.account_balance_outlined, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: const Color(0xFFF2F2F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              // Passport Filter
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _passportController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'رقم جواز السفر',
                    hintText: 'ابحث برقم جواز السفر',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: const Color(0xFFF2F2F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              // Date From
              SizedBox(
                width: 180,
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dateFrom == null
                                ? 'من تاريخ'
                                : DateFormat('yyyy-MM-dd').format(_dateFrom!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _dateFrom == null ? Colors.grey[600] : Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Date To
              SizedBox(
                width: 180,
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dateTo == null
                                ? 'إلى تاريخ'
                                : DateFormat('yyyy-MM-dd').format(_dateTo!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _dateTo == null ? Colors.grey[600] : Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Branch Filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int>(
                  value: _selectedBranchId,
                  decoration: InputDecoration(
                    labelText: 'الفرع',
                    hintText: 'اختر الفرع',
                    prefixIcon: const Icon(Icons.business_outlined, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: const Color(0xFFF2F2F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('جميع الفروع'),
                    ),
                    ..._branches.map((branch) => DropdownMenuItem<int>(
                      value: branch['id'] as int,
                      child: Text(branch['name'] as String),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBranchId = value;
                    });
                    _reloadWithFilters();
                  },
                ),
              ),
              // Clear Button
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'مسح',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_filteredTransactions.isEmpty) {
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
              'لا توجد معاملات',
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: const Text(
                    'البيانات الأساسية',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: const Text(
                    'إجمالي المعاملات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: const Text(
                    'الإجراءات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.customer.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${transaction.customer.phoneNumber} | ${transaction.customer.accountNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '${transaction.totalTransactions}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => _showTransactionDetails(context, transaction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a5d2e),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'تفاصيل',
                            style: TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1a5d2e),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لوحة التحكم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFF1a5d2e)),
              title: const Text('المعاملات المكتملة'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF1a5d2e)),
              title: const Text('إدارة الموظفين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeesManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.business, color: Color(0xFF1a5d2e)),
              title: const Text('إدارة الفروع'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BranchesManagementScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ApiService.clearAll();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () {
              _reloadWithFilters();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ApiService.clearAll();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed Filters Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildFiltersSection(),
                ),
                // Table Section
                Expanded(
                  child: _buildTable(),
                ),
                const PoweredByCactus(),
              ],
            ),
    );
  }
}
