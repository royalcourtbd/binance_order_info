import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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

      log('📡 [API] Fetching completed orders...');
      log('📡 [API] URL: $url');
      log('📡 [API] Days: $days, UseCache: $useCache');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('📡 [API] Response Status Code: ${response.statusCode}');
      log('📡 [API] Response Body Length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        log('✅ [API] JSON decoded successfully');
        log('📊 [API] Response keys: ${jsonData.keys.toList()}');

        // Handle the response structure: data has buy_orders and sell_orders
        final data = jsonData['data'];
        log('📊 [API] Data type: ${data.runtimeType}');
        List<dynamic> allOrders = [];

        if (data is Map) {
          // Combine buy_orders and sell_orders
          log('📊 [API] Data is a Map, checking for buy_orders and sell_orders');
          if (data['buy_orders'] != null) {
            final buyOrders = data['buy_orders'] as List;
            log('✅ [API] Found ${buyOrders.length} buy orders');
            allOrders.addAll(buyOrders);
          }
          if (data['sell_orders'] != null) {
            final sellOrders = data['sell_orders'] as List;
            log('✅ [API] Found ${sellOrders.length} sell orders');
            allOrders.addAll(sellOrders);
          }
        } else if (data is List) {
          log('📊 [API] Data is a List with ${data.length} items');
          allOrders = data;
        }

        // Safely parse count field
        int? count;
        final countValue = jsonData['count'];

        if (countValue is int) {
          count = countValue;
        } else if (countValue is String) {
          count = int.tryParse(countValue);
        } else if (countValue is Map) {
          count = allOrders.length; // Fallback to actual length
        } else {
          count = allOrders.length; // Default fallback
        }

        // Safely parse cached field
        bool? cached;
        final cachedValue = jsonData['cached'];

        if (cachedValue is bool) {
          cached = cachedValue;
        } else if (cachedValue is String) {
          cached = cachedValue.toLowerCase() == 'true';
        } else if (cachedValue is Map) {}

        log('✅ [API] Total orders fetched: ${allOrders.length}');
        log('✅ [API] Count: $count, Cached: $cached');

        return ApiResponse<List<dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Orders fetched successfully',
          data: allOrders,
          count: count,
          cached: cached,
        );
      } else {
        log('❌ [API] Error: Status code ${response.statusCode}');
        log('❌ [API] Response body: ${response.body}');

        // Try to parse error message from API
        try {
          final jsonData = json.decode(response.body);
          // Check for both 'message' and 'detail' fields
          final errorMsg = jsonData['message'] ?? jsonData['detail'] ?? 'Failed to fetch orders';
          log('❌ [API] Error message from API: $errorMsg');

          // If it's a Binance restricted location error, show a friendly message
          if (errorMsg.toString().contains('restricted location')) {
            return ApiResponse.error('API server blocked by Binance. Try using VPN or different region.');
          }

          return ApiResponse.error(errorMsg);
        } catch (_) {
          return ApiResponse.error('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      log('❌ [API] SocketException: $e');
      return ApiResponse.error('No internet connection. Check WiFi.');
    } on TimeoutException catch (e) {
      log('❌ [API] TimeoutException: $e');
      return ApiResponse.error('Server not responding. Is the API running?');
    } on FormatException catch (e) {
      log('❌ [API] FormatException: $e');
      return ApiResponse.error('Invalid response from server');
    } catch (e, stackTrace) {
      log('❌ [API] Unexpected error: $e');
      log('❌ [API] Stack trace: $stackTrace');
      return ApiResponse.error('Unexpected error: $e');
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

      log('📡 [API] Fetching summary...');
      log('📡 [API] URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('📡 [API] Summary Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        log('✅ [API] Summary JSON decoded successfully');

        final summaryData = SummaryResponse.fromJson(jsonData['data']);
        log('✅ [API] Summary data parsed successfully');

        return ApiResponse<SummaryResponse>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Summary fetched successfully',
          data: summaryData,
          cached: jsonData['cached'],
        );
      } else {
        log('❌ [API] Summary Error: Status ${response.statusCode}');
        log('❌ [API] Response body: ${response.body}');

        // Try to parse error message from API
        try {
          final jsonData = json.decode(response.body);
          // Check for both 'message' and 'detail' fields
          final errorMsg = jsonData['message'] ?? jsonData['detail'] ?? 'Failed to fetch summary';
          log('❌ [API] Error message: $errorMsg');

          // If it's a Binance restricted location error, show a friendly message
          if (errorMsg.toString().contains('restricted location')) {
            return ApiResponse.error('API server blocked by Binance. Try using VPN or different region.');
          }

          return ApiResponse.error(errorMsg);
        } catch (_) {
          return ApiResponse.error('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      log('❌ [API] Summary SocketException: $e');
      return ApiResponse.error('No internet connection. Check WiFi.');
    } on TimeoutException catch (e) {
      log('❌ [API] Summary TimeoutException: $e');
      return ApiResponse.error('Server not responding. Is the API running?');
    } on FormatException catch (e) {
      log('❌ [API] Summary FormatException: $e');
      return ApiResponse.error('Invalid response from server');
    } catch (e, stackTrace) {
      log('❌ [API] Summary Unexpected error: $e');
      log('❌ [API] Stack trace: $stackTrace');
      return ApiResponse.error('Unexpected error: $e');
    }
  }
}
