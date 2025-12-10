import 'package:flutter/material.dart';
import 'package:manager_web/services/api_service.dart';
import 'package:manager_web/theme/app_theme.dart';

class Branch {
  final int id;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final bool isActive;
  final String? createdByName;

  Branch({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    required this.isActive,
    this.createdByName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdByName: json['created_by_name'] as String?,
    );
  }
}

class BranchesManagementScreen extends StatefulWidget {
  const BranchesManagementScreen({super.key});

  @override
  State<BranchesManagementScreen> createState() => _BranchesManagementScreenState();
}

class _BranchesManagementScreenState extends State<BranchesManagementScreen> {
  List<Branch> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAllBranches();

      if (mounted) {
        if (result['success'] == true) {
          final branchesData = result['data'] as List;
          setState(() {
            _branches = branchesData
                .map((json) => Branch.fromJson(json))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل جلب الفروع'),
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

  Future<void> _showAddBranchDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      'إضافة فرع جديد',
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
                          controller: nameController,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.body.copyWith(color: AppTheme.label),
                          decoration: InputDecoration(
                            labelText: 'اسم الفرع',
                            labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسم الفرع';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        TextFormField(
                          controller: codeController,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.body.copyWith(color: AppTheme.label),
                          decoration: InputDecoration(
                            labelText: 'رمز الفرع',
                            hintText: 'مثل: BR001',
                            labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال رمز الفرع';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        TextFormField(
                          controller: addressController,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.body.copyWith(color: AppTheme.label),
                          decoration: InputDecoration(
                            labelText: 'العنوان (اختياري)',
                            labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        TextFormField(
                          controller: phoneController,
                          textDirection: TextDirection.rtl,
                          keyboardType: TextInputType.phone,
                          style: AppTheme.body.copyWith(color: AppTheme.label),
                          decoration: InputDecoration(
                            labelText: 'الهاتف (اختياري)',
                            labelStyle: AppTheme.subhead.copyWith(color: AppTheme.secondaryLabel),
                          ),
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
                          await _createBranch(
                            name: nameController.text.trim(),
                            code: codeController.text.trim(),
                            address: addressController.text.trim().isEmpty
                                ? null
                                : addressController.text.trim(),
                            phone: phoneController.text.trim().isEmpty
                                ? null
                                : phoneController.text.trim(),
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
    );
  }

  Future<void> _createBranch({
    required String name,
    required String code,
    String? address,
    String? phone,
  }) async {
    try {
      final result = await ApiService.createBranch(
        name: name,
        code: code,
        address: address,
        phone: phone,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم إضافة الفرع بنجاح'),
              backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
          _loadBranches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل إضافة الفرع'),
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

  Future<void> _showEditBranchDialog(Branch branch) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: branch.name);
    final codeController = TextEditingController(text: branch.code);
    final addressController = TextEditingController(text: branch.address ?? '');
    final phoneController = TextEditingController(text: branch.phone ?? '');
    bool isActive = branch.isActive;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل الفرع'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الفرع',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم الفرع';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'رمز الفرع',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رمز الفرع';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('نشط'),
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
                  await _updateBranch(
                    id: branch.id,
                    name: nameController.text.trim(),
                    code: codeController.text.trim(),
                    address: addressController.text.trim().isEmpty
                        ? null
                        : addressController.text.trim(),
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                    isActive: isActive,
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

  Future<void> _updateBranch({
    required int id,
    required String name,
    required String code,
    String? address,
    String? phone,
    required bool isActive,
  }) async {
    try {
      final result = await ApiService.updateBranch(
        id: id,
        name: name,
        code: code,
        address: address,
        phone: phone,
        isActive: isActive,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم تحديث الفرع بنجاح'),
              backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
          _loadBranches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل تحديث الفرع'),
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

  Future<void> _deleteBranch(Branch branch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الفرع "${branch.name}"؟'),
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

    if (confirmed == true) {
      try {
        final result = await ApiService.deleteBranch(branch.id);

        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'تم حذف الفرع بنجاح'),
                backgroundColor: AppTheme.systemGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              ),
            );
            _loadBranches();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'فشل حذف الفرع'),
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
          'إدارة الفروع',
          style: AppTheme.headline.copyWith(color: AppTheme.label),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBranchDialog,
            tooltip: 'إضافة فرع',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBranches,
              child: _branches.isEmpty
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
                                final branch = _branches[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing16,
                                    vertical: AppTheme.spacing4,
                                  ),
                                  child: _buildBranchCard(branch),
                                );
                              },
                              childCount: _branches.length,
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
            Icons.business_outlined,
            size: 80,
            color: AppTheme.gray3,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'لا توجد فروع',
            style: AppTheme.title3.copyWith(color: AppTheme.secondaryLabel),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'ابدأ بإضافة فرع جديد',
            style: AppTheme.footnote.copyWith(color: AppTheme.tertiaryLabel),
          ),
          const SizedBox(height: AppTheme.spacing24),
          ElevatedButton.icon(
            onPressed: _showAddBranchDialog,
            icon: const Icon(Icons.add),
            label: Text('إضافة فرع جديد', style: AppTheme.headline.copyWith(color: Colors.white)),
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

  Widget _buildBranchCard(Branch branch) {
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
                  backgroundColor: branch.isActive
                      ? AppTheme.systemGreen
                      : AppTheme.gray3,
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: AppTheme.headline.copyWith(
                          color: branch.isActive ? AppTheme.label : AppTheme.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        branch.code,
                        style: AppTheme.footnote.copyWith(color: AppTheme.secondaryLabel),
                      ),
                      if (branch.address != null) ...[
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          branch.address!,
                          style: AppTheme.footnote.copyWith(color: AppTheme.tertiaryLabel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacing4),
                      Row(
                        children: [
                          Icon(
                            branch.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: branch.isActive
                                ? AppTheme.systemGreen
                                : AppTheme.systemRed,
                          ),
                          const SizedBox(width: AppTheme.spacing4),
                          Text(
                            branch.isActive ? 'نشط' : 'غير نشط',
                            style: AppTheme.footnote.copyWith(
                              color: branch.isActive
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
                      _showEditBranchDialog(branch);
                    } else if (value == 'delete') {
                      _deleteBranch(branch);
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

