import 'package:flutter/material.dart';
import 'package:manager_web/models/employee.dart';
import 'package:manager_web/services/api_service.dart';
import 'package:manager_web/theme/app_theme.dart';

class EmployeesManagementScreen extends StatefulWidget {
  const EmployeesManagementScreen({super.key});

  @override
  State<EmployeesManagementScreen> createState() => _EmployeesManagementScreenState();
}

class _EmployeesManagementScreenState extends State<EmployeesManagementScreen> {
  List<Employee> _employees = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadEmployees();
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
      // Silently fail - branches will be empty
    }
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAllEmployees();

      if (mounted) {
        if (result['success'] == true) {
          final employeesData = result['data'] as List;
          setState(() {
            _employees = employeesData
                .map((json) => Employee.fromJson(json))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'فشل جلب الموظفين',
                style: AppTheme.body.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
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
          ),
        );
      }
    }
  }

  Future<void> _showAddEmployeeDialog() async {
    final formKey = GlobalKey<FormState>();
    final employeeIdController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String selectedRole = 'employee';
    int? selectedBranchId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            constraints: BoxConstraints(
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
                        selectedRole == 'manager' ? 'إضافة مدير جديد' : 'إضافة موظف جديد',
                        style: AppTheme.title2.copyWith(color: AppTheme.label),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            key: ValueKey('employee_id_$selectedRole'),
                            controller: employeeIdController,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: selectedRole == 'manager' ? 'رقم المدير' : 'رقم الموظف',
                              hintText: selectedRole == 'manager' ? 'مثل: MGR002' : 'مثل: EMP002',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return selectedRole == 'manager' 
                                    ? 'يرجى إدخال رقم المدير' 
                                    : 'يرجى إدخال رقم الموظف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          TextFormField(
                            key: ValueKey('name_$selectedRole'),
                            controller: nameController,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: selectedRole == 'manager' ? 'اسم المدير' : 'اسم الموظف',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return selectedRole == 'manager' 
                                    ? 'يرجى إدخال اسم المدير' 
                                    : 'يرجى إدخال اسم الموظف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          TextFormField(
                            key: ValueKey('password_$selectedRole'),
                            controller: passwordController,
                            obscureText: true,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            onChanged: (_) {
                              if (confirmPasswordController.text.isNotEmpty) {
                                formKey.currentState?.validate();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              if (value.length < 6) {
                                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          TextFormField(
                            key: ValueKey('confirm_password_$selectedRole'),
                            controller: confirmPasswordController,
                            obscureText: true,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى تأكيد كلمة المرور';
                              }
                              if (value != passwordController.text) {
                                return 'كلمة المرور غير متطابقة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'نوع الموظف',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'employee', child: Text('موظف')),
                              DropdownMenuItem(value: 'manager', child: Text('مدير')),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedRole = value!;
                              });
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          DropdownButtonFormField<int>(
                            initialValue: selectedBranchId,
                            decoration: InputDecoration(
                              labelText: 'الفرع *',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            items: _branches.map((branch) => DropdownMenuItem<int>(
                              value: branch['id'] as int,
                              child: Text(branch['name'] as String, style: AppTheme.body),
                            )).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedBranchId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'يرجى اختيار الفرع';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: AppTheme.headline.copyWith(color: AppTheme.systemBlue),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedBranchId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'يرجى اختيار الفرع',
                                    style: AppTheme.body.copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: AppTheme.systemRed,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context);
                            await _addEmployee(
                              employeeIdController.text.trim(),
                              nameController.text.trim(),
                              passwordController.text,
                              selectedRole,
                              selectedBranchId!,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.systemBlue,
                        ),
                        child: Text(
                          'إضافة',
                          style: AppTheme.headline.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addEmployee(
    String employeeId,
    String name,
    String password,
    String role,
    int branchId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.createEmployee(
        employeeId: employeeId,
        name: name,
        password: password,
        role: role,
        branchId: branchId,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم إضافة الموظف بنجاح'),
              backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
          _loadEmployees();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل إضافة الموظف'),
              backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
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
          ),
        );
      }
    }
  }

  Future<void> _showEditEmployeeDialog(Employee employee) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: employee.name);
    final passwordController = TextEditingController();
    String selectedRole = employee.role;
    bool isActive = employee.isActive;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            constraints: BoxConstraints(
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
                        'تعديل بيانات الموظف',
                        style: AppTheme.title2.copyWith(color: AppTheme.label),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'رقم الموظف: ${employee.employeeId}',
                            style: AppTheme.body.copyWith(color: AppTheme.secondaryLabel),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          TextFormField(
                            controller: nameController,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: 'اسم الموظف',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال اسم الموظف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(color: AppTheme.label),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور (اتركه فارغاً إذا لم ترد تغييره)',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'نوع الموظف',
                              labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'employee', child: Text('موظف')),
                              DropdownMenuItem(value: 'manager', child: Text('مدير')),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedRole = value!;
                              });
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          SwitchListTile(
                            title: Text('حساب نشط', style: AppTheme.body.copyWith(color: AppTheme.label)),
                            value: isActive,
                            onChanged: (value) {
                              setDialogState(() {
                                isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: AppTheme.headline.copyWith(color: AppTheme.systemBlue),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            await _updateEmployee(
                              employee.id,
                              nameController.text.trim(),
                              passwordController.text.isEmpty ? null : passwordController.text,
                              selectedRole,
                              isActive,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.systemBlue,
                        ),
                        child: Text(
                          'حفظ',
                          style: AppTheme.headline.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateEmployee(
    int id,
    String name,
    String? password,
    String role,
    bool isActive,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.updateEmployee(
        id: id,
        name: name,
        password: password,
        role: role,
        isActive: isActive,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم تحديث الموظف بنجاح'),
              backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
          _loadEmployees();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل تحديث الموظف'),
              backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
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
          ),
        );
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('تأكيد الحذف', style: AppTheme.title3.copyWith(color: AppTheme.label)),
        content: Text(
          'هل أنت متأكد من حذف الموظف "${employee.name}"؟',
          style: AppTheme.body.copyWith(color: AppTheme.secondaryLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: AppTheme.headline.copyWith(color: AppTheme.systemBlue),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.systemRed),
            child: Text(
              'حذف',
              style: AppTheme.headline.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final result = await ApiService.deleteEmployee(employee.id);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'تم حذف الموظف بنجاح'),
                backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              ),
            );
            _loadEmployees();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'فشل حذف الموظف'),
                backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'إدارة الموظفين',
          style: AppTheme.headline.copyWith(color: AppTheme.label),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEmployeeDialog,
            tooltip: 'إضافة موظف',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              child: _employees.isEmpty
                  ? _buildEmptyState()
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            top: AppTheme.spacing8,
                            bottom: AppTheme.spacing24,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final employee = _employees[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing16,
                                    vertical: AppTheme.spacing4,
                                  ),
                                  child: _buildEmployeeCard(employee),
                                );
                              },
                              childCount: _employees.length,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppTheme.gray3,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'لا يوجد موظفين',
            style: AppTheme.title3.copyWith(color: AppTheme.secondaryLabel),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'ابدأ بإضافة موظف جديد',
            style: AppTheme.footnote.copyWith(color: AppTheme.tertiaryLabel),
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            onPressed: _showAddEmployeeDialog,
            icon: const Icon(Icons.add),
            label: Text('إضافة موظف جديد', style: AppTheme.headline.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.systemBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: employee.role == 'manager'
                      ? AppTheme.systemOrange
                      : AppTheme.systemBlue,
                  child: Text(
                    employee.name[0],
                    style: AppTheme.headline.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: AppTheme.headline.copyWith(color: AppTheme.label),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        '${employee.employeeId} • ${employee.roleName}',
                        style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Row(
                        children: [
                          Icon(
                            employee.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: employee.isActive
                                ? AppTheme.systemGreen
                                : AppTheme.systemRed,
                          ),
                          const SizedBox(width: AppTheme.spacing4),
                          Text(
                            employee.isActive ? 'نشط' : 'غير نشط',
                            style: AppTheme.footnote.copyWith(
                              color: employee.isActive
                                  ? AppTheme.systemGreen
                                  : AppTheme.systemRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppTheme.secondaryLabel),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20, color: AppTheme.systemBlue),
                          const SizedBox(width: AppTheme.spacing8),
                          Text('تعديل', style: AppTheme.body),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: AppTheme.systemRed),
                          const SizedBox(width: AppTheme.spacing8),
                          Text('حذف', style: AppTheme.body.copyWith(color: AppTheme.systemRed)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditEmployeeDialog(employee);
                    } else if (value == 'delete') {
                      _deleteEmployee(employee);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

