import 'dart:developer';
import 'package:get/get.dart';
import '../models/optimal_pricing_model.dart';
import '../models/transaction_item_model.dart';
import '../models/month_section_model.dart';
import 'orders_controller.dart';

/// Controller for Optimal Pricing Calculator
/// Manages pricing calculations and target profit adjustments
class PricingCalculatorController extends GetxController {
  final OrdersController ordersController = Get.find<OrdersController>();

  // Observable state
  final Rx<OptimalPricingModel?> pricingModel = Rx<OptimalPricingModel?>(null);
  final RxDouble targetProfit = 1.0.obs; // Default target: 1 BDT per USDT
  final RxBool isCalculating = false.obs;
  final RxString selectedMonth = ''.obs; // Empty means current month

  @override
  void onInit() {
    super.onInit();
    // Listen to orders controller updates
    ever(ordersController.monthSections, (_) => calculatePricing());
    calculatePricing();
  }

  /// Calculate optimal pricing from current/selected month data
  void calculatePricing() {
    log('🧮 [PricingCalculator] Starting calculation...');
    isCalculating.value = true;

    try {
      // Get current month or selected month transactions
      final transactions = _getTransactionsForCalculation();

      if (transactions.isEmpty) {
        log('⚠️ [PricingCalculator] No transactions found');
        pricingModel.value = null;
        return;
      }

      // Create pricing model from transactions
      final model = OptimalPricingModel.fromTransactions(
        transactions,
        targetProfitPerUsdt: targetProfit.value,
      );

      pricingModel.value = model;

      log('✅ [PricingCalculator] Calculation complete');
      log('   Average Buy Rate: ৳${model.avgBuyRate.toStringAsFixed(2)}');
      log('   Required Sell Rate: ৳${model.requiredSellRate.toStringAsFixed(2)}');
      log('   Target Profit: ৳${model.targetProfitPerUsdt.toStringAsFixed(2)} per USDT');
    } catch (e, stackTrace) {
      log('❌ [PricingCalculator] Calculation failed: $e');
      log('❌ [PricingCalculator] Stack trace: $stackTrace');
      pricingModel.value = null;
    } finally {
      isCalculating.value = false;
    }
  }

  /// Get transactions for the selected period
  List<TransactionItemModel> _getTransactionsForCalculation() {
    final monthSections = ordersController.monthSections;

    if (monthSections.isEmpty) {
      return [];
    }

    // If no month selected or month doesn't exist, use current month (first in list)
    MonthSectionModel? selectedMonthSection;

    if (selectedMonth.value.isEmpty) {
      // Use current month (first month in list)
      selectedMonthSection = monthSections.first;
    } else {
      // Find selected month
      try {
        selectedMonthSection = monthSections.firstWhere(
          (m) => m.monthName == selectedMonth.value,
        );
      } catch (e) {
        // If not found, use current month
        selectedMonthSection = monthSections.first;
      }
    }

    // Extract all transactions from date sections
    final allTransactions = <TransactionItemModel>[];
    for (var dateSection in selectedMonthSection.dateSections) {
      allTransactions.addAll(dateSection.transactions);
    }

    log('📊 [PricingCalculator] Found ${allTransactions.length} transactions');
    log('   Buy: ${allTransactions.where((t) => t.category.toUpperCase() == "BUY").length}');
    log('   Sell: ${allTransactions.where((t) => t.category.toUpperCase() == "SELL").length}');

    return allTransactions;
  }

  /// Update target profit and recalculate
  void updateTargetProfit(double newTarget) {
    if (newTarget < 0) {
      log('⚠️ [PricingCalculator] Invalid target profit: $newTarget');
      return;
    }

    log('🎯 [PricingCalculator] Updating target profit to: ৳$newTarget per USDT');
    targetProfit.value = newTarget;

    // Recalculate with new target
    if (pricingModel.value != null) {
      pricingModel.value =
          pricingModel.value!.copyWithTargetProfit(newTarget);
    }
  }

  /// Change selected month
  void selectMonth(String monthName) {
    log('📅 [PricingCalculator] Selecting month: $monthName');
    selectedMonth.value = monthName;
    calculatePricing();
  }

  /// Reset to current month
  void resetToCurrentMonth() {
    log('🔄 [PricingCalculator] Resetting to current month');
    selectedMonth.value = '';
    calculatePricing();
  }

  /// Get available months for selection
  List<String> getAvailableMonths() {
    return ordersController.monthSections
        .map((m) => m.monthName)
        .toList();
  }

  /// Calculate required sell rate for custom profit target
  double? calculateCustomSellRate(double profitTarget) {
    if (pricingModel.value == null) return null;
    return pricingModel.value!.calculateRequiredSellRate(profitTarget);
  }

  /// Calculate expected profit for a given sell rate
  double? calculateProfitForRate(double sellRate) {
    if (pricingModel.value == null) return null;
    return pricingModel.value!.calculateExpectedProfit(sellRate);
  }

  /// Calculate total profit for given quantity and rate
  double? calculateTotalProfit(double quantity, double sellRate) {
    if (pricingModel.value == null) return null;
    return pricingModel.value!.calculateTotalProfit(quantity, sellRate);
  }

  /// Get current month name
  String getCurrentMonthName() {
    if (ordersController.monthSections.isEmpty) return '';
    return ordersController.monthSections.first.monthName;
  }
}
