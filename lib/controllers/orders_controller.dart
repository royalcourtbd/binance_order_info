import 'dart:developer';

import 'package:get/get.dart';
import '../models/date_section_model.dart';
import '../models/month_section_model.dart';
import '../models/transaction_item_model.dart';
import '../models/api_response_model.dart';
import '../models/balance_model.dart';
import '../services/orders_api_service.dart';
import '../services/manual_charge_service.dart';

class OrdersController extends GetxController {
  final OrdersApiService _apiService = OrdersApiService();
  final ManualChargeService _chargeService = ManualChargeService();

  // Observable state
  final RxList<DateSectionModel> dateSections = <DateSectionModel>[].obs;
  final RxList<MonthSectionModel> monthSections = <MonthSectionModel>[].obs;
  final Rx<SummaryResponse> summary = SummaryResponse.empty().obs;
  final Rx<BalanceResponse> balance = BalanceResponse.empty().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Changed to 90 days for last 3 months data
  final int days = 90;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    log('🔄 [Controller] Starting fetchOrders...');
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Fetch completed orders first so summary adjustments use latest data
      await _fetchCompletedOrders();
      await Future.wait([_fetchSummary(), _fetchBalance()]);
      log('✅ [Controller] fetchOrders completed successfully');
    } catch (e, stackTrace) {
      log('❌ [Controller] fetchOrders failed: $e');
      log('❌ [Controller] Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCompletedOrders() async {
    log('🔄 [Controller] Fetching completed orders with days=$days');
    final response = await _apiService.getCompletedOrders(days: days);

    log('📊 [Controller] Response success: ${response.success}');
    log('📊 [Controller] Response message: ${response.message}');
    log('📊 [Controller] Response data null: ${response.data == null}');

    if (response.success && response.data != null) {
      log('✅ [Controller] Processing ${response.data!.length} orders');
      try {
        // Load manual charges from storage
        log('📥 [Controller] Fetching all manual charges from API...');
        final manualCharges = await _chargeService.getAllCharges();
        log('📥 [Controller] Loaded ${manualCharges.length} manual charges');
        if (manualCharges.isNotEmpty) {
          log('📥 [Controller] Manual charges: $manualCharges');
        }

        // Parse JSON to TransactionItemModel objects with error handling
        final List<TransactionItemModel> transactions = [];
        final ordersList = response.data as List;

        for (int i = 0; i < ordersList.length; i++) {
          try {
            final json = ordersList[i];
            final orderNumber = json['orderNumber']?.toString() ?? '';

            // Get manual charge for this order (if exists)
            final manualCharge = manualCharges[orderNumber];

            if (manualCharge != null) {
              log(
                '💰 [Controller] Found manual charge for order $orderNumber: $manualCharge',
              );
            }

            // Add manual charge to the JSON before creating the model
            final transaction = TransactionItemModel.fromJson({
              ...json,
              'manualCharge': manualCharge,
            });
            transactions.add(transaction);
          } catch (e, stackTrace) {
            log('🔍 Stack trace: $stackTrace');
            // Continue processing other orders instead of failing completely
          }
        }

        // Group transactions by date
        dateSections.value = _groupTransactionsByDate(transactions);
        log('✅ [Controller] Created ${dateSections.length} date sections');

        // Group date sections by month for PageView
        monthSections.value = _groupDateSectionsByMonth(dateSections);
        log('✅ [Controller] Created ${monthSections.length} month sections');
      } catch (e, stackTrace) {
        log('❌ [Controller] Error processing orders: $e');
        log('❌ [Controller] Stack trace: $stackTrace');
        errorMessage.value = 'Error processing orders: $e';
      }
    } else {
      log('❌ [Controller] Failed to fetch orders: ${response.message}');
      errorMessage.value = response.message;
    }
  }

  Future<void> _fetchSummary() async {
    final response = await _apiService.getSummary(days: days);

    if (response.success && response.data != null) {
      // Adjust summary to include manual charges
      final adjustedSummary = await _adjustSummaryWithManualCharges(
        response.data!,
      );
      summary.value = adjustedSummary;
    } else {
      // Don't override error message if orders fetch already failed
      if (errorMessage.value.isEmpty) {
        errorMessage.value = response.message;
      }
    }
  }

  Future<void> _fetchBalance() async {
    log('🔄 [Controller] Fetching balance');
    final response = await _apiService.getBalance();

    if (response.success && response.data != null) {
      balance.value = response.data!;
      log(
        '✅ [Controller] Balance fetched: USDT ${balance.value.summary.usdtBalance}',
      );
    } else {
      log('❌ [Controller] Failed to fetch balance: ${response.message}');
      // Don't override error message if other fetches already failed
      if (errorMessage.value.isEmpty) {
        errorMessage.value = response.message;
      }
    }
  }

  /// Adjust summary to include manual charges from API-backed orders
  Future<SummaryResponse> _adjustSummaryWithManualCharges(
    SummaryResponse apiSummary,
  ) async {
    double totalBuyCharges = 0.0;
    double totalSellCharges = 0.0;

    // Sum up all manual charges for buy and sell transactions
    // We need to iterate through transactions to know which type each order is
    for (final section in dateSections) {
      for (final transaction in section.transactions) {
        final charge = transaction.manualCharge;

        if (charge != null) {
          if (transaction.category.toUpperCase() == 'BUY') {
            totalBuyCharges += charge;
          } else if (transaction.category.toUpperCase() == 'SELL') {
            totalSellCharges += charge;
          }
        }
      }
    }

    // Adjust the buy and sell values with manual charges
    final adjustedBuyValue = apiSummary.totalBuyValue + totalBuyCharges;
    final adjustedSellValue = apiSummary.totalSellValue + totalSellCharges;

    // Recalculate profit: profit = sell - buy
    final adjustedProfit = adjustedSellValue - adjustedBuyValue;

    return SummaryResponse(
      totalBuyOrders: apiSummary.totalBuyOrders,
      totalSellOrders: apiSummary.totalSellOrders,
      totalCompletedOrders: apiSummary.totalCompletedOrders,
      totalBuyAmount: apiSummary.totalBuyAmount,
      totalSellAmount: apiSummary.totalSellAmount,
      totalBuyValue: adjustedBuyValue,
      totalSellValue: adjustedSellValue,
      totalBuyFees: apiSummary.totalBuyFees,
      totalSellFees: apiSummary.totalSellFees,
      totalFees: apiSummary.totalFees,
      averageBuyPrice: apiSummary.averageBuyPrice,
      averageSellPrice: apiSummary.averageSellPrice,
      netProfitBdt: adjustedProfit,
      netProfitPercentage: adjustedBuyValue > 0
          ? (adjustedProfit / adjustedBuyValue) * 100
          : 0.0,
    );
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  /// Save manual charge for a specific order and refresh the data
  Future<bool> saveManualCharge(String orderNumber, double charge) async {
    log(
      '💾 [Controller] Saving manual charge for order: $orderNumber, charge: $charge',
    );
    final success = await _chargeService.saveManualCharge(orderNumber, charge);
    log(
      success
          ? '✅ [Controller] Save returned success'
          : '❌ [Controller] Save returned failure',
    );
    if (success) {
      log('🔄 [Controller] Refreshing orders after save');
      await refreshOrders();
    }
    return success;
  }

  /// Remove manual charge for a specific order and refresh the data
  Future<bool> removeManualCharge(String orderNumber) async {
    final success = await _chargeService.removeManualCharge(orderNumber);
    if (success) {
      await refreshOrders();
    }
    return success;
  }

  /// Get a specific transaction by order number (for real-time updates in details page)
  TransactionItemModel? getTransactionByOrderNumber(String orderNumber) {
    for (final section in dateSections) {
      for (final transaction in section.transactions) {
        final txOrderNumber = transaction.title.replaceFirst('#', '');
        if (txOrderNumber == orderNumber) {
          return transaction;
        }
      }
    }
    return null;
  }

  List<DateSectionModel> _groupTransactionsByDate(
    List<TransactionItemModel> transactions,
  ) {
    // Group transactions by date
    final Map<String, List<TransactionItemModel>> grouped = {};

    for (var transaction in transactions) {
      if (transaction.createTime != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(
          transaction.createTime!,
        );
        final dateKey =
            '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(transaction);
      }
    }

    // Convert to DateSectionModel list
    final List<DateSectionModel> sections = [];
    grouped.forEach((dateKey, transactionList) {
      final dateTime = DateTime.parse(dateKey);
      sections.add(
        DateSectionModel.fromTransactions(dateTime, transactionList),
      );
    });

    // Sort by date descending (newest first)
    sections.sort((a, b) {
      final dateA = DateTime(
        int.parse(a.year.split('.')[1]),
        int.parse(a.year.split('.')[0]),
        int.parse(a.date),
      );
      final dateB = DateTime(
        int.parse(b.year.split('.')[1]),
        int.parse(b.year.split('.')[0]),
        int.parse(b.date),
      );
      return dateB.compareTo(dateA);
    });

    return sections;
  }

  /// Group date sections by month for PageView
  List<MonthSectionModel> _groupDateSectionsByMonth(
    List<DateSectionModel> dateSections,
  ) {
    // Group date sections by year-month
    final Map<String, List<DateSectionModel>> grouped = {};

    for (var dateSection in dateSections) {
      // Extract year and month from the year field (format: "MM.yyyy")
      final monthKey =
          '${dateSection.year.split('.')[1]}-${dateSection.year.split('.')[0]}'; // "yyyy-MM"

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(dateSection);
    }

    // Convert to MonthSectionModel list
    final List<MonthSectionModel> sections = [];
    grouped.forEach((monthKey, dateSectionList) {
      // Parse monthKey "yyyy-MM" to DateTime (first day of month)
      final parts = monthKey.split('-');
      final monthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);

      sections.add(
        MonthSectionModel.fromDateSections(monthDate, dateSectionList),
      );
    });

    // Sort by month descending (newest first)
    sections.sort((a, b) {
      final dateA = DateTime(int.parse(a.year), int.parse(a.month), 1);
      final dateB = DateTime(int.parse(b.year), int.parse(b.month), 1);
      return dateB.compareTo(dateA);
    });

    return _applyMonthlyProfitFallback(sections);
  }

  List<MonthSectionModel> _applyMonthlyProfitFallback(
    List<MonthSectionModel> sections,
  ) {
    if (sections.isEmpty) return sections;

    final List<MonthSectionModel> updated = [];

    for (int i = 0; i < sections.length; i++) {
      final current = sections[i];
      final currentBuyUsdt = double.tryParse(current.monthBuyUsdt) ?? 0.0;
      final currentSellUsdt = double.tryParse(current.monthSellUsdt) ?? 0.0;
      final currentAvgBuyRate = double.tryParse(current.avgBuyRate) ?? 0.0;
      final currentAvgSellRate = double.tryParse(current.avgSellRate) ?? 0.0;

      double effectiveBuyRate = currentAvgBuyRate;
      bool usedPreviousBuyRate = false;

      if (currentBuyUsdt <= 0) {
        final previous = (i + 1 < sections.length) ? sections[i + 1] : null;
        final previousBuyRate = previous != null
            ? (double.tryParse(previous.avgBuyRate) ?? 0.0)
            : 0.0;
        if (previousBuyRate > 0) {
          effectiveBuyRate = previousBuyRate;
          usedPreviousBuyRate = true;
        }
      }

      double profit = 0.0;
      if (currentSellUsdt > 0 &&
          currentAvgSellRate > 0 &&
          effectiveBuyRate > 0) {
        profit = (currentAvgSellRate - effectiveBuyRate) * currentSellUsdt;
      }

      updated.add(
        current.copyWith(
          profitTk: profit.toStringAsFixed(2),
          profitBuyRate: effectiveBuyRate.toStringAsFixed(2),
          profitSellRate: currentAvgSellRate.toStringAsFixed(2),
          usedPreviousBuyRate: usedPreviousBuyRate,
        ),
      );
    }

    return updated;
  }

  /// Get the index of the current month in monthSections (for initial PageView page)
  int getCurrentMonthIndex() {
    if (monthSections.isEmpty) return 0;

    final now = DateTime.now();
    final currentMonthKey =
        '${now.month.toString().padLeft(2, '0')}-${now.year}';

    for (int i = 0; i < monthSections.length; i++) {
      final section = monthSections[i];
      final sectionKey = '${section.month}-${section.year}';
      if (sectionKey == currentMonthKey) {
        return i;
      }
    }

    // If current month not found, return 0 (latest month)
    return 0;
  }
}
