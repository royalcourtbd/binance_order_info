import 'package:intl/intl.dart';
import 'transaction_item_model.dart';

class DateSectionModel {
  final String date;
  final String day;
  final String year;
  final String dayBuy;
  final String daySell;
  final List<TransactionItemModel> transactions;

  DateSectionModel({
    required this.date,
    required this.day,
    required this.year,
    required this.dayBuy,
    required this.daySell,
    required this.transactions,
  });

  factory DateSectionModel.fromTransactions(
    DateTime dateTime,
    List<TransactionItemModel> transactions,
  ) {
    // Calculate daily buy and sell totals (including manual charges)
    double totalBuy = 0.0;
    double totalSell = 0.0;

    for (var transaction in transactions) {
      final amount = double.tryParse(transaction.amount) ?? 0.0;
      final manualCharge = transaction.manualCharge ?? 0.0;

      if (transaction.category.toUpperCase() == 'BUY') {
        // For BUY: add base amount + manual charge (extra cost)
        totalBuy += amount + manualCharge;
      } else if (transaction.category.toUpperCase() == 'SELL') {
        // For SELL: add base amount + manual charge (extra income)
        totalSell += amount + manualCharge;
      }
    }

    return DateSectionModel(
      date: DateFormat('dd').format(dateTime),
      day: DateFormat('EEE').format(dateTime),
      year: DateFormat('MM.yyyy').format(dateTime),
      dayBuy: totalBuy.toStringAsFixed(2),
      daySell: totalSell.toStringAsFixed(2),
      transactions: transactions,
    );
  }
}
