import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_web/models/customer.dart';
import 'package:manager_web/models/transaction.dart';
import 'package:manager_web/screens/dashboard_screen.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';
import 'package:manager_web/widgets/ios_grouped_card.dart';
import 'package:manager_web/widgets/ios_section_header.dart';
import 'package:manager_web/theme/app_theme.dart';
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
  bool _showFilters = false; // Control filters visibility

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
            content: Text(
              'حدث خطأ: ${e.toString()}',
              style: AppTheme.body.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.systemRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
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
            content: Text(
              'حدث خطأ: ${e.toString()}',
              style: AppTheme.body.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.systemRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Row(
                  children: [
                    Text(
                      'تفاصيل المعاملات',
                      style: AppTheme.title2.copyWith(color: AppTheme.label),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppTheme.secondaryLabel,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Info Card
                      IOSInsetGroupedCard(
                        children: [
                          _buildDetailRow('الاسم', transaction.customer.name),
                          _buildDetailRow('رقم الهاتف', transaction.customer.phoneNumber),
                          _buildDetailRow('رقم الحساب', transaction.customer.accountNumber),
                          _buildDetailRow('رقم جواز السفر', transaction.customer.passportNumber),
                          if (transaction.transactionNumber != null)
                            _buildDetailRow('رقم المعاملة', transaction.transactionNumber!),
                          _buildDetailRow(
                            'تاريخ الإنجاز',
                            dateFormat.format(transaction.completedDate),
                          ),
                        ],
                      ),
                      // Signature and Passport Buttons
                      if (transaction.signatureBase64 != null || transaction.passportImageBase64 != null) ...[
                        const SizedBox(height: AppTheme.spacing16),
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
                                  label: Text('عرض التوقيع', style: AppTheme.headline.copyWith(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.systemBlue,
                                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                                  ),
                                ),
                              ),
                            if (transaction.signatureBase64 != null && transaction.passportImageBase64 != null)
                              const SizedBox(width: AppTheme.spacing12),
                            if (transaction.passportImageBase64 != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showImageDialog(
                                    context,
                                    transaction.passportImageBase64!,
                                    'صورة جواز السفر',
                                  ),
                                  icon: const Icon(Icons.credit_card, size: 18),
                                  label: Text('صورة الجواز', style: AppTheme.headline.copyWith(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.systemBlue,
                                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      // Transactions Section
                      const SizedBox(height: AppTheme.spacing24),
                      Text(
                        'المعاملات',
                        style: AppTheme.title3.copyWith(color: AppTheme.label),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      IOSInsetGroupedCard(
                        children: transaction.transactions.map((t) {
                          return IOSListRow(
                            leading: Icon(
                              _getTransactionTypeIcon(t.type),
                              color: AppTheme.systemBlue,
                            ),
                            title: Text(
                              _getTransactionTypeName(t.type),
                              style: AppTheme.body.copyWith(color: AppTheme.label),
                            ),
                            subtitle: t.description.isNotEmpty
                                ? Text(
                                    t.description,
                                    style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.systemBlue,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                    ),
                    child: Text(
                      'إغلاق',
                      style: AppTheme.headline.copyWith(color: Colors.white),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
          ),
          Text(
            value,
            style: AppTheme.body.copyWith(
              color: AppTheme.label,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: AppTheme.title2.copyWith(color: AppTheme.label),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: AppTheme.secondaryLabel,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    child: Center(
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.systemBlue,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                      ),
                      child: Text(
                        'إغلاق',
                        style: AppTheme.headline.copyWith(color: Colors.white),
                      ),
                    ),
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
          title: Text('خطأ', style: AppTheme.title3.copyWith(color: AppTheme.label)),
          content: Text(
            'فشل عرض الصورة: ${e.toString()}',
            style: AppTheme.body.copyWith(color: AppTheme.secondaryLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إغلاق',
                style: AppTheme.headline.copyWith(color: AppTheme.systemBlue),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IOSSectionHeader(title: 'فلاتر البحث'),
        IOSInsetGroupedCard(
          children: [
            // Phone Filter
            TextFormField(
              controller: _phoneController,
              style: AppTheme.body.copyWith(color: AppTheme.label),
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: 'ابحث برقم الهاتف',
                prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.systemBlue),
                labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
              ),
              onChanged: (_) => _applyFilters(),
            ),
            // Account Filter
            TextFormField(
              controller: _accountController,
              style: AppTheme.body.copyWith(color: AppTheme.label),
              decoration: InputDecoration(
                labelText: 'رقم الحساب',
                hintText: 'ابحث برقم الحساب',
                prefixIcon: const Icon(Icons.account_balance_outlined, color: AppTheme.systemBlue),
                labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
              ),
              onChanged: (_) => _applyFilters(),
            ),
            // Passport Filter
            TextFormField(
              controller: _passportController,
              style: AppTheme.body.copyWith(color: AppTheme.label),
              decoration: InputDecoration(
                labelText: 'رقم جواز السفر',
                hintText: 'ابحث برقم جواز السفر',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.systemBlue),
                labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
              ),
              onChanged: (_) => _applyFilters(),
            ),
            // Date From
            IOSListRow(
              leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.systemBlue),
              title: Text(
                _dateFrom == null
                    ? 'من تاريخ'
                    : DateFormat('yyyy-MM-dd').format(_dateFrom!),
                style: AppTheme.body.copyWith(
                  color: _dateFrom == null ? AppTheme.tertiaryLabel : AppTheme.label,
                ),
              ),
              trailing: const Icon(Icons.chevron_left, color: AppTheme.tertiaryLabel),
              onTap: () => _selectDate(context, true),
            ),
            // Date To
            IOSListRow(
              leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.systemBlue),
              title: Text(
                _dateTo == null
                    ? 'إلى تاريخ'
                    : DateFormat('yyyy-MM-dd').format(_dateTo!),
                style: AppTheme.body.copyWith(
                  color: _dateTo == null ? AppTheme.tertiaryLabel : AppTheme.label,
                ),
              ),
              trailing: const Icon(Icons.chevron_left, color: AppTheme.tertiaryLabel),
              onTap: () => _selectDate(context, false),
            ),
            // Branch Filter
            DropdownButtonFormField<int>(
              value: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'الفرع',
                hintText: 'اختر الفرع',
                prefixIcon: const Icon(Icons.business_outlined, color: AppTheme.systemBlue),
                labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
              ),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('جميع الفروع', style: AppTheme.body),
                ),
                ..._branches.map((branch) => DropdownMenuItem<int>(
                      value: branch['id'] as int,
                      child: Text(branch['name'] as String, style: AppTheme.body),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBranchId = value;
                });
                _reloadWithFilters();
              },
            ),
            // Clear Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: Text('مسح الفلاتر', style: AppTheme.headline.copyWith(color: AppTheme.systemRed)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppTheme.gray3,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'لا توجد معاملات',
            style: AppTheme.title3.copyWith(color: AppTheme.secondaryLabel),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'لم يتم العثور على معاملات تطابق الفلاتر المحددة',
            style: AppTheme.footnote.copyWith(color: AppTheme.tertiaryLabel),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(CompletedTransaction transaction) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetails(context, transaction),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.customer.name,
                            style: AppTheme.headline.copyWith(color: AppTheme.label),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            transaction.customer.phoneNumber,
                            style: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.systemBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        '${transaction.totalTransactions}',
                        style: AppTheme.headline.copyWith(
                          color: AppTheme.systemBlue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 16,
                      color: AppTheme.secondaryLabel,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      transaction.customer.accountNumber,
                      style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.secondaryLabel,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      dateFormat.format(transaction.completedDate),
                      style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        title: Text(
          'المعاملات المكتملة',
          style: AppTheme.headline.copyWith(color: AppTheme.label),
        ),
        actions: [
          // Filter Button with colored background
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacing8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.systemBlue,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    _showFilters ? Icons.tune : Icons.tune_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Refresh Button with colored background
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacing8, right: AppTheme.spacing8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _reloadWithFilters,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.systemGreen,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reloadWithFilters,
              child: CustomScrollView(
                slivers: [
                  // Filters Section (Collapsible with Animation)
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          )),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _showFilters
                          ? Padding(
                              key: const ValueKey('filters'),
                              padding: const EdgeInsets.only(
                                top: AppTheme.spacing8,
                                bottom: AppTheme.spacing8,
                              ),
                              child: _buildFiltersSection(),
                            )
                          : const SizedBox(
                              key: ValueKey('empty'),
                              height: AppTheme.spacing16,
                            ),
                    ),
                  ),
                  // Transactions List
                  if (_filteredTransactions.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: _showFilters ? AppTheme.spacing8 : AppTheme.spacing16,
                        left: AppTheme.spacing16,
                        right: AppTheme.spacing16,
                        bottom: AppTheme.spacing24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction = _filteredTransactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.spacing8,
                              ),
                              child: _buildTransactionCard(transaction),
                            );
                          },
                          childCount: _filteredTransactions.length,
                        ),
                      ),
                    ),
                  // Powered by Cactus
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      child: PoweredByCactus(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
