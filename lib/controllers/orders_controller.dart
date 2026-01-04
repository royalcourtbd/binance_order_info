import 'dart:developer';

import 'package:get/get.dart';
import '../models/date_section_model.dart';
import '../models/transaction_item_model.dart';
import '../models/api_response_model.dart';
import '../services/orders_api_service.dart';
import '../services/manual_charge_service.dart';

class OrdersController extends GetxController {
  final OrdersApiService _apiService = OrdersApiService();
  final ManualChargeService _chargeService = ManualChargeService();

  // Observable state
  final RxList<DateSectionModel> dateSections = <DateSectionModel>[].obs;
  final Rx<SummaryResponse> summary = SummaryResponse.empty().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Fixed to 30 days (no filter needed)
  final int days = 30;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Fetch both completed orders and summary in parallel
      await Future.wait([_fetchCompletedOrders(), _fetchSummary()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCompletedOrders() async {
    final response = await _apiService.getCompletedOrders(days: days);

    if (response.success && response.data != null) {
      try {
        // Load manual charges from storage
        final manualCharges = await _chargeService.getAllCharges();

        // Parse JSON to TransactionItemModel objects with error handling
        final List<TransactionItemModel> transactions = [];
        final ordersList = response.data as List;

        for (int i = 0; i < ordersList.length; i++) {
          try {
            final json = ordersList[i];
            final orderNumber = json['orderNumber']?.toString() ?? '';

            // Get manual charge for this order (if exists)
            final manualCharge = manualCharges[orderNumber];

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
      } catch (e, stackTrace) {
        log('🔍 Stack trace: $stackTrace');
        errorMessage.value = 'Error processing orders: $e';
      }
    } else {
      errorMessage.value = response.message;
    }
  }

  Future<void> _fetchSummary() async {
    final response = await _apiService.getSummary(days: days);

    if (response.success && response.data != null) {
      // Adjust summary to include manual charges
      final adjustedSummary = await _adjustSummaryWithManualCharges(response.data!);
      summary.value = adjustedSummary;
    } else {
      // Don't override error message if orders fetch already failed
      if (errorMessage.value.isEmpty) {
        errorMessage.value = response.message;
      }
    }
  }

  /// Adjust summary to include manual charges from local storage
  Future<SummaryResponse> _adjustSummaryWithManualCharges(
      SummaryResponse apiSummary) async {
    final manualCharges = await _chargeService.getAllCharges();

    double totalBuyCharges = 0.0;
    double totalSellCharges = 0.0;

    // Sum up all manual charges for buy and sell transactions
    // We need to iterate through transactions to know which type each order is
    for (final section in dateSections) {
      for (final transaction in section.transactions) {
        final orderNumber = transaction.title.replaceFirst('#', '');
        final charge = manualCharges[orderNumber];

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
    final success = await _chargeService.saveManualCharge(orderNumber, charge);
    if (success) {
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
}
