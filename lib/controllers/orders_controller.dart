import 'package:get/get.dart';
import '../models/date_section_model.dart';
import '../models/transaction_item_model.dart';
import '../models/api_response_model.dart';
import '../services/orders_api_service.dart';

class OrdersController extends GetxController {
  final OrdersApiService _apiService = OrdersApiService();

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
      await Future.wait([
        _fetchCompletedOrders(),
        _fetchSummary(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCompletedOrders() async {
    print('🚀 Fetching completed orders...');
    final response = await _apiService.getCompletedOrders(days: days);

    if (response.success && response.data != null) {
      print('✅ Orders fetched successfully');
      print('📊 Processing ${(response.data as List).length} orders...');

      try {
        // Parse JSON to TransactionItemModel objects with error handling
        final List<TransactionItemModel> transactions = [];
        final ordersList = response.data as List;

        for (int i = 0; i < ordersList.length; i++) {
          try {
            print('📋 Processing order ${i + 1}/${ordersList.length}');
            final transaction = TransactionItemModel.fromJson(ordersList[i]);
            transactions.add(transaction);
            print('✅ Order ${i + 1} parsed successfully');
          } catch (e, stackTrace) {
            print('❌ Error parsing order ${i + 1}: $e');
            print('📦 Failed order data: ${ordersList[i]}');
            print('🔍 Stack trace: $stackTrace');
            // Continue processing other orders instead of failing completely
          }
        }

        print('✅ Parsed ${transactions.length} transactions successfully');

        // Group transactions by date
        dateSections.value = _groupTransactionsByDate(transactions);
        print('✅ Grouped into ${dateSections.length} date sections');
      } catch (e, stackTrace) {
        print('❌ Error during transaction processing: $e');
        print('🔍 Stack trace: $stackTrace');
        errorMessage.value = 'Error processing orders: $e';
      }
    } else {
      print('❌ Failed to fetch orders: ${response.message}');
      errorMessage.value = response.message;
    }
  }

  Future<void> _fetchSummary() async {
    print('🚀 Fetching summary...');
    final response = await _apiService.getSummary(days: days);

    if (response.success && response.data != null) {
      print('✅ Summary fetched successfully');
      summary.value = response.data!;
    } else {
      print('❌ Failed to fetch summary: ${response.message}');
      // Don't override error message if orders fetch already failed
      if (errorMessage.value.isEmpty) {
        errorMessage.value = response.message;
      }
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  List<DateSectionModel> _groupTransactionsByDate(
    List<TransactionItemModel> transactions,
  ) {
    // Group transactions by date
    final Map<String, List<TransactionItemModel>> grouped = {};

    for (var transaction in transactions) {
      if (transaction.createTime != null) {
        final dateTime =
            DateTime.fromMillisecondsSinceEpoch(transaction.createTime!);
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
