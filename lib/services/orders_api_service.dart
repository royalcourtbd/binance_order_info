import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response_model.dart';

class OrdersApiService {
  Future<ApiResponse<List<dynamic>>> getCompletedOrders({
    int days = ApiConfig.defaultDays,
    bool useCache = ApiConfig.defaultUseCache,
  }) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.completedOrdersEndpoint,
        days: days,
        useCache: useCache,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print('✅ API Response received successfully');
        print('📦 Full Response: ${jsonData.toString()}');

        // Handle the response structure: data has buy_orders and sell_orders
        final data = jsonData['data'];
        List<dynamic> allOrders = [];

        if (data is Map) {
          print('📊 Data is Map - combining buy_orders and sell_orders');
          // Combine buy_orders and sell_orders
          if (data['buy_orders'] != null) {
            final buyOrders = data['buy_orders'] as List;
            print('💰 Buy orders count: ${buyOrders.length}');
            allOrders.addAll(buyOrders);
          }
          if (data['sell_orders'] != null) {
            final sellOrders = data['sell_orders'] as List;
            print('💸 Sell orders count: ${sellOrders.length}');
            allOrders.addAll(sellOrders);
          }
        } else if (data is List) {
          print('📊 Data is List');
          allOrders = data;
        }

        print('📝 Total orders: ${allOrders.length}');
        if (allOrders.isNotEmpty) {
          print('🔍 First order sample: ${allOrders.first}');
        }

        // Safely parse count field
        int? count;
        final countValue = jsonData['count'];
        print('🔢 count type: ${countValue?.runtimeType}');
        print('🔢 count value: $countValue');

        if (countValue is int) {
          count = countValue;
        } else if (countValue is String) {
          count = int.tryParse(countValue);
        } else if (countValue is Map) {
          print('⚠️ WARNING: count is a Map!');
          print('📦 count Map content: $countValue');
          count = allOrders.length; // Fallback to actual length
        } else {
          count = allOrders.length; // Default fallback
        }

        // Safely parse cached field
        bool? cached;
        final cachedValue = jsonData['cached'];
        print('💾 cached type: ${cachedValue?.runtimeType}');
        print('💾 cached value: $cachedValue');

        if (cachedValue is bool) {
          cached = cachedValue;
        } else if (cachedValue is String) {
          cached = cachedValue.toLowerCase() == 'true';
        } else if (cachedValue is Map) {
          print('⚠️ WARNING: cached is a Map!');
          print('📦 cached Map content: $cachedValue');
        }

        return ApiResponse<List<dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Orders fetched successfully',
          data: allOrders,
          count: count,
          cached: cached,
        );
      } else {
        // Try to parse error message from API
        try {
          final jsonData = json.decode(response.body);
          return ApiResponse.error(
            jsonData['message'] ?? 'Failed to fetch orders',
          );
        } catch (_) {
          return ApiResponse.error(
            'Server error: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Check WiFi.',
      );
    } on TimeoutException {
      return ApiResponse.error(
        'Server not responding. Is the API running?',
      );
    } on FormatException {
      return ApiResponse.error(
        'Invalid response from server',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: $e',
      );
    }
  }

  Future<ApiResponse<SummaryResponse>> getSummary({
    int days = ApiConfig.defaultDays,
    bool useCache = ApiConfig.defaultUseCache,
  }) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.summaryEndpoint,
        days: days,
        useCache: useCache,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Summary API Response received');
        print('📊 Summary data: ${jsonData['data']}');

        final summaryData = SummaryResponse.fromJson(jsonData['data']);
        print('✅ Summary parsed successfully');

        return ApiResponse<SummaryResponse>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Summary fetched successfully',
          data: summaryData,
          cached: jsonData['cached'],
        );
      } else {
        // Try to parse error message from API
        try {
          final jsonData = json.decode(response.body);
          return ApiResponse.error(
            jsonData['message'] ?? 'Failed to fetch summary',
          );
        } catch (_) {
          return ApiResponse.error(
            'Server error: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Check WiFi.',
      );
    } on TimeoutException {
      return ApiResponse.error(
        'Server not responding. Is the API running?',
      );
    } on FormatException {
      return ApiResponse.error(
        'Invalid response from server',
      );
    } catch (e) {
      return ApiResponse.error(
        'Unexpected error: $e',
      );
    }
  }
}
