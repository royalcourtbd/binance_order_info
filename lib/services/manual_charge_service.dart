import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for storing and retrieving manual charges for P2P transactions
/// Manual charges are extra costs (for BUY) or extra income (for SELL) in BDT
class ManualChargeService {
  /// Save manual charge for a specific order
  /// orderNumber: The order number (without #)
  /// charge: The charge amount in BDT (can be positive or negative)
  Future<bool> saveManualCharge(
    String orderNumber,
    double charge, {
    String? comment,
  }) async {
    try {
      final url = ApiConfig.getManualChargesUrl();
      final payload = {
        'order_number': orderNumber,
        'charge': charge,
        if (comment != null) 'comment': comment,
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      log(
        '❌ [ManualCharge] Save failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return false;
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get manual charge for a specific order
  /// Returns null if no charge is set for this order
  Future<double?> getManualCharge(String orderNumber) async {
    try {
      final url = ApiConfig.getManualChargeUrl(orderNumber);
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as Map<String, dynamic>?;
        final charge = data?['charge'];
        if (charge is num) {
          return charge.toDouble();
        }
        if (charge is String) {
          return double.tryParse(charge);
        }
        return null;
      }

      if (response.statusCode == 404) {
        return null;
      }

      log(
        '❌ [ManualCharge] Get failed: ${response.statusCode} ${response.body}',
      );
      return null;
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return null;
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return null;
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Remove manual charge for a specific order
  Future<bool> removeManualCharge(String orderNumber) async {
    try {
      final url = ApiConfig.getManualChargeUrl(orderNumber);
      final response = await http
          .delete(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return true;
      }

      log(
        '❌ [ManualCharge] Delete failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return false;
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get all manual charges
  /// Returns a map of orderNumber -> charge amount
  Future<Map<String, double>> getAllCharges() async {
    try {
      final url = ApiConfig.getManualChargesUrl();
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];

        if (data is List) {
          final Map<String, double> charges = {};
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final orderNumber = item['order_number']?.toString();
              final charge = item['charge'];
              if (orderNumber != null && orderNumber.isNotEmpty) {
                if (charge is num) {
                  charges[orderNumber] = charge.toDouble();
                } else if (charge is String) {
                  final parsed = double.tryParse(charge);
                  if (parsed != null) {
                    charges[orderNumber] = parsed;
                  }
                }
              }
            }
          }
          return charges;
        }
        return {};
      }

      log(
        '❌ [ManualCharge] Get all failed: ${response.statusCode} ${response.body}',
      );
      return {};
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return {};
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return {};
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return {};
    }
  }

  /// Clear all manual charges
  Future<bool> clearAllCharges() async {
    try {
      final url = ApiConfig.getManualChargesUrl();
      final response = await http
          .delete(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return true;
      }

      log(
        '❌ [ManualCharge] Delete all failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return false;
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Update manual charge (partial update)
  Future<bool> updateManualCharge(
    String orderNumber, {
    double? charge,
    String? comment,
  }) async {
    try {
      final url = ApiConfig.getManualChargeUrl(orderNumber);
      final payload = {
        if (charge != null) 'charge': charge,
        if (comment != null) 'comment': comment,
      };

      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return true;
      }

      log(
        '❌ [ManualCharge] Update failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } on SocketException catch (e) {
      log('❌ [ManualCharge] SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      log('❌ [ManualCharge] TimeoutException: $e');
      return false;
    } catch (e, stackTrace) {
      log('❌ [ManualCharge] Unexpected error: $e');
      log('❌ [ManualCharge] Stack trace: $stackTrace');
      return false;
    }
  }
}
