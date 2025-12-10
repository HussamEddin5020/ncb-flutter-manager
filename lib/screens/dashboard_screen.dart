import 'package:flutter/material.dart';
import 'package:manager_web/screens/filtered_transactions_screen.dart';
import 'package:manager_web/screens/employees_management_screen.dart';
import 'package:manager_web/screens/branches_management_screen.dart';
import 'package:manager_web/widgets/ios_grouped_card.dart';
import 'package:manager_web/widgets/ios_section_header.dart';
import 'package:manager_web/theme/app_theme.dart';
import 'package:manager_web/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalTransactions = 0;
  int _totalEmployees = 0;
  int _totalBranches = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load transactions count
      final transactionsResult = await ApiService.getCompletedTransactions();
      if (transactionsResult['success'] == true && transactionsResult['data'] != null) {
        _totalTransactions = (transactionsResult['data'] as List).length;
      }

      // Load employees count
      final employeesResult = await ApiService.getAllEmployees();
      if (employeesResult['success'] == true && employeesResult['data'] != null) {
        _totalEmployees = (employeesResult['data'] as List).length;
      }

      // Load branches count
      final branchesResult = await ApiService.getAllBranches();
      if (branchesResult['success'] == true && branchesResult['data'] != null) {
        _totalBranches = (branchesResult['data'] as List).length;
      }
    } catch (e) {
      // Silently fail
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'لوحة التحكم',
          style: AppTheme.headline.copyWith(color: AppTheme.label),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacing8),

                    // Quick Stats Section
                    IOSSectionHeader(title: 'الإحصائيات السريعة'),
                    _buildStatsCards(),

                    // Quick Actions Section
                    IOSSectionHeader(title: 'الإجراءات السريعة'),
                    _buildQuickActions(),

                    // Management Section
                    IOSSectionHeader(title: 'الإدارة'),
                    _buildManagementSection(),

                    const SizedBox(height: AppTheme.spacing24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long,
              title: 'المعاملات',
              value: _totalTransactions.toString(),
              color: AppTheme.systemBlue,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _StatCard(
              icon: Icons.people,
              title: 'الموظفين',
              value: _totalEmployees.toString(),
              color: AppTheme.systemGreen,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: _StatCard(
              icon: Icons.business,
              title: 'الفروع',
              value: _totalBranches.toString(),
              color: AppTheme.systemOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return IOSInsetGroupedCard(
      children: [
        IOSListRow(
          leading: const Icon(Icons.receipt, color: AppTheme.systemBlue),
          title: Text('عرض جميع المعاملات', style: AppTheme.body),
          trailing: const Icon(Icons.chevron_left, color: AppTheme.tertiaryLabel),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FilteredTransactionsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagementSection() {
    return IOSInsetGroupedCard(
      children: [
        IOSListRow(
          leading: const Icon(Icons.people_outline, color: AppTheme.systemGreen),
          title: Text('إدارة الموظفين', style: AppTheme.body),
          subtitle: Text(
            'إضافة وتعديل وحذف الموظفين والمديرين',
            style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
          ),
          trailing: const Icon(Icons.chevron_left, color: AppTheme.tertiaryLabel),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmployeesManagementScreen(),
              ),
            );
          },
        ),
        IOSListRow(
          leading: const Icon(Icons.business_outlined, color: AppTheme.systemOrange),
          title: Text('إدارة الفروع', style: AppTheme.body),
          subtitle: Text(
            'إضافة وتعديل وحذف فروع المصرف',
            style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
          ),
          trailing: const Icon(Icons.chevron_left, color: AppTheme.tertiaryLabel),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BranchesManagementScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: AppTheme.title2.copyWith(
              color: AppTheme.label,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}
