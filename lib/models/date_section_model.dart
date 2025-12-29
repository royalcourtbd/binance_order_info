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
}
