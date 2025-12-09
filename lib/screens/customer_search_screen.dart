import 'package:flutter/material.dart';
import 'package:manager_web/models/customer.dart';
import 'package:manager_web/screens/customer_transactions_screen.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';
import 'package:manager_web/services/api_service.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  String _searchType = 'phone'; // phone, account, passport
  Customer? _foundCustomer;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSearching = true;
        _foundCustomer = null;
      });

      try {
        final result = await ApiService.searchCustomer(
          _searchType,
          _searchController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isSearching = false;
          });

          if (result['success'] == true && result['data'] != null) {
            final customerData = result['data'];
            final customer = Customer.fromJson(customerData);
            setState(() {
              _foundCustomer = customer;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'لم يتم العثور على العميل'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
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
  }

  void _navigateToTransactions() {
    if (_foundCustomer != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CustomerTransactionsScreen(customer: _foundCustomer!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Type Selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSearchTypeButton(
                          'phone',
                          'رقم الهاتف',
                          Icons.phone_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildSearchTypeButton(
                          'account',
                          'رقم الحساب',
                          Icons.account_balance_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildSearchTypeButton(
                          'passport',
                          'جواز السفر',
                          Icons.badge_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Field Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 17),
                    keyboardType:
                        _searchType == 'phone' || _searchType == 'account'
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: _searchType == 'phone'
                          ? 'رقم الهاتف'
                          : _searchType == 'account'
                          ? 'رقم الحساب'
                          : 'رقم جواز السفر',
                      hintText: _searchType == 'phone'
                          ? 'أدخل رقم الهاتف'
                          : _searchType == 'account'
                          ? 'أدخل رقم الحساب'
                          : 'أدخل رقم جواز السفر',
                      hintTextDirection: TextDirection.rtl,
                      prefixIcon: const Icon(Icons.search_outlined, size: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال ${_searchType == 'phone'
                            ? 'رقم الهاتف'
                            : _searchType == 'account'
                            ? 'رقم الحساب'
                            : 'رقم جواز السفر'}';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Search Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a5d2e),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'بحث',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Info Card
                if (_foundCustomer != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'بيانات العميل',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: 'Tajawal',
                                ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _buildInfoRow('الاسم', _foundCustomer!.name),
                        const Divider(height: 1, thickness: 0.5),
                        _buildInfoRow(
                          'رقم الهاتف',
                          _foundCustomer!.phoneNumber,
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _buildInfoRow(
                          'رقم الحساب',
                          _foundCustomer!.accountNumber,
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _buildInfoRow(
                          'رقم جواز السفر',
                          _foundCustomer!.passportNumber,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _navigateToTransactions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1a5d2e),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'عرض المعاملات',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const PoweredByCactus(),
    );
  }

  Widget _buildSearchTypeButton(String value, String label, IconData icon) {
    final isSelected = _searchType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchType = value;
          _foundCustomer = null;
          _searchController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1a5d2e)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}


