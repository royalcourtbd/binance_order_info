import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving manual charges for P2P transactions
/// Manual charges are extra costs (for BUY) or extra income (for SELL) in BDT
class ManualChargeService {
  static const String _storageKey = 'manual_charges';

  /// Save manual charge for a specific order
  /// orderNumber: The order number (without #)
  /// charge: The charge amount in BDT (can be positive or negative)
  Future<bool> saveManualCharge(String orderNumber, double charge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charges = await getAllCharges();

      // Update or add the charge
      charges[orderNumber] = charge;

      // Save back to storage
      final jsonString = jsonEncode(charges);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get manual charge for a specific order
  /// Returns null if no charge is set for this order
  Future<double?> getManualCharge(String orderNumber) async {
    try {
      final charges = await getAllCharges();
      return charges[orderNumber];
    } catch (e) {
      return null;
    }
  }

  /// Remove manual charge for a specific order
  Future<bool> removeManualCharge(String orderNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final charges = await getAllCharges();

      charges.remove(orderNumber);

      final jsonString = jsonEncode(charges);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get all manual charges
  /// Returns a map of orderNumber -> charge amount
  Future<Map<String, double>> getAllCharges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      return {};
    }
  }

  /// Clear all manual charges
  Future<bool> clearAllCharges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }
}
