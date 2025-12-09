import 'package:flutter/material.dart';
import 'package:manager_web/models/employee.dart';
import 'package:manager_web/services/api_service.dart';

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
              content: Text(result['message'] ?? 'فشل جلب الموظفين'),
              backgroundColor: Colors.red,
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
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        builder: (context, setDialogState) => AlertDialog(
          title: Text(selectedRole == 'manager' ? 'إضافة مدير جديد' : 'إضافة موظف جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: ValueKey('employee_id_$selectedRole'),
                    controller: employeeIdController,
                    decoration: InputDecoration(
                      labelText: selectedRole == 'manager' ? 'رقم المدير' : 'رقم الموظف',
                      hintText: selectedRole == 'manager' ? 'مثل: MGR002' : 'مثل: EMP002',
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey('name_$selectedRole'),
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: selectedRole == 'manager' ? 'اسم المدير' : 'اسم الموظف',
                      border: const OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey('password_$selectedRole'),
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey('confirm_password_$selectedRole'),
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'نوع الموظف',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedBranchId,
                    decoration: const InputDecoration(
                      labelText: 'الفرع *',
                      border: OutlineInputBorder(),
                    ),
                    items: _branches.map((branch) => DropdownMenuItem<int>(
                      value: branch['id'] as int,
                      child: Text(branch['name'] as String),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedBranchId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار الفرع'),
                        backgroundColor: Colors.red,
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
              child: const Text('إضافة'),
            ),
          ],
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
              backgroundColor: Colors.green,
            ),
          );
          _loadEmployees();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل إضافة الموظف'),
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل بيانات الموظف'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('رقم الموظف: ${employee.employeeId}'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الموظف',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم الموظف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور (اتركه فارغاً إذا لم ترد تغييره)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'نوع الموظف',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('حساب نشط'),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
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
              child: const Text('حفظ'),
            ),
          ],
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
              backgroundColor: Colors.green,
            ),
          );
          _loadEmployees();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل تحديث الموظف'),
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
                backgroundColor: Colors.green,
              ),
            );
            _loadEmployees();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'فشل حذف الموظف'),
                backgroundColor: Colors.red,
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
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        backgroundColor: const Color(0xFF1a5d2e),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              child: _employees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'لا يوجد موظفين',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _showAddEmployeeDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة موظف جديد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1a5d2e),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: employee.role == 'manager'
                                  ? Colors.orange
                                  : Colors.blue,
                              child: Text(
                                employee.name[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              employee.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('رقم الموظف: ${employee.employeeId}'),
                                Text('النوع: ${employee.roleName}'),
                                Row(
                                  children: [
                                    Icon(
                                      employee.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: employee.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      employee.isActive ? 'نشط' : 'غير نشط',
                                      style: TextStyle(
                                        color: employee.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('تعديل'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('حذف', style: TextStyle(color: Colors.red)),
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
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: const Color(0xFF1a5d2e),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

