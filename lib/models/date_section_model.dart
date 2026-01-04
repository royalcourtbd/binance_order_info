import 'package:intl/intl.dart';
import 'transaction_item_model.dart';

class DateSectionModel {
  final String date;
  final String day;
  final String year;
  final String dayBuy; // Total buy without manual charges
  final String daySell; // Total sell without manual charges
  final String dayBuyWithCharge; // Total buy with manual charges
  final String daySellWithCharge; // Total sell with manual charges
  final List<TransactionItemModel> transactions;

  DateSectionModel({
    required this.date,
    required this.day,
    required this.year,
    required this.dayBuy,
    required this.daySell,
    required this.dayBuyWithCharge,
    required this.daySellWithCharge,
    required this.transactions,
  });

  factory DateSectionModel.fromTransactions(
    DateTime dateTime,
    List<TransactionItemModel> transactions,
  ) {
    // Calculate daily buy and sell totals (with and without manual charges)
    double totalBuy = 0.0;
    double totalSell = 0.0;
    double totalBuyWithCharge = 0.0;
    double totalSellWithCharge = 0.0;

    for (var transaction in transactions) {
      final amount = double.tryParse(transaction.amount) ?? 0.0;
      final manualCharge = transaction.manualCharge ?? 0.0;

      if (transaction.category.toUpperCase() == 'BUY') {
        totalBuy += amount;
        totalBuyWithCharge += amount + manualCharge;
      } else if (transaction.category.toUpperCase() == 'SELL') {
        totalSell += amount;
        totalSellWithCharge += amount + manualCharge;
      }
    }

    return DateSectionModel(
      date: DateFormat('dd').format(dateTime),
      day: DateFormat('EEE').format(dateTime),
      year: DateFormat('MM.yyyy').format(dateTime),
      dayBuy: totalBuy.toStringAsFixed(2),
      daySell: totalSell.toStringAsFixed(2),
      dayBuyWithCharge: totalBuyWithCharge.toStringAsFixed(2),
      daySellWithCharge: totalSellWithCharge.toStringAsFixed(2),
      transactions: transactions,
    );
  }
}
