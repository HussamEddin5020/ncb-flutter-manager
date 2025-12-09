import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://ncb-back-api.onrender.com/api';
  static const String tokenKey = 'auth_token';
  static const String employeeKey = 'employee_data';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Save employee data
  static Future<void> saveEmployeeData(Map<String, dynamic> employee) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(employeeKey, jsonEncode(employee));
  }

  // Get employee data
  static Future<Map<String, dynamic>?> getEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(employeeKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear all stored data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(employeeKey);
  }

  // Get headers with token
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Login
  static Future<Map<String, dynamic>> login(String employeeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await getHeaders(includeAuth: false),
        body: jsonEncode({
          'employee_id': employeeId,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and employee data
        await saveToken(data['data']['token']);
        await saveEmployeeData(data['data']['employee']);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Search customer
  static Future<Map<String, dynamic>> searchCustomer(
    String type,
    String value,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/search?type=$type&value=$value'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'لم يتم العثور على العميل',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Get completed transactions
  static Future<Map<String, dynamic>> getCompletedTransactions({
    String? startDate,
    String? endDate,
    int? employeeId,
    int? branchId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (employeeId != null) queryParams['employeeId'] = employeeId.toString();
      if (branchId != null) queryParams['branchId'] = branchId.toString();

      final uri = Uri.parse('$baseUrl/transactions/completed')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل جلب المعاملات المكتملة',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Get completed transaction details
  static Future<Map<String, dynamic>> getCompletedTransactionDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/completed/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'لم يتم العثور على المعاملة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // ============================================
  // Employee Management APIs
  // ============================================

  // Get all employees
  static Future<Map<String, dynamic>> getAllEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل جلب الموظفين',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Get employee by ID
  static Future<Map<String, dynamic>> getEmployeeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'لم يتم العثور على الموظف',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Create employee
  static Future<Map<String, dynamic>> createEmployee({
    required String employeeId,
    required String name,
    required String password,
    required String role,
    required int branchId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: await getHeaders(),
        body: jsonEncode({
          'employee_id': employeeId,
          'name': name,
          'password': password,
          'role': role,
          'branch_id': branchId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم إضافة الموظف بنجاح',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل إضافة الموظف',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Update employee
  static Future<Map<String, dynamic>> updateEmployee({
    required int id,
    String? name,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (password != null) body['password'] = password;
      if (role != null) body['role'] = role;
      if (isActive != null) body['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: await getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث الموظف بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تحديث الموظف',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Delete employee
  static Future<Map<String, dynamic>> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/employees/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف الموظف بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل حذف الموظف',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // ============================================
  // Branch Management APIs
  // ============================================

  // Get all branches
  static Future<Map<String, dynamic>> getAllBranches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/branches'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل جلب الفروع',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
        'data': [],
      };
    }
  }

  // Get branch by ID
  static Future<Map<String, dynamic>> getBranchById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/branches/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'لم يتم العثور على الفرع',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Create branch
  static Future<Map<String, dynamic>> createBranch({
    required String name,
    required String code,
    String? address,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branches'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'code': code,
          'address': address,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم إضافة الفرع بنجاح',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل إضافة الفرع',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Update branch
  static Future<Map<String, dynamic>> updateBranch({
    required int id,
    String? name,
    String? code,
    String? address,
    String? phone,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;
      if (address != null) body['address'] = address;
      if (phone != null) body['phone'] = phone;
      if (isActive != null) body['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/branches/$id'),
        headers: await getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم تحديث الفرع بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تحديث الفرع',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }

  // Delete branch
  static Future<Map<String, dynamic>> deleteBranch(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/branches/$id'),
        headers: await getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف الفرع بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل حذف الفرع',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال: ${e.toString()}',
      };
    }
  }
}

