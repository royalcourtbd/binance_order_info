import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:binance_order_info/widgets/transaction_details/amount_section.dart';
import 'package:binance_order_info/widgets/transaction_details/transaction_header_section.dart';
import 'package:binance_order_info/widgets/transaction_details/transaction_info_section.dart';
import 'package:flutter/material.dart';

class TransactionDetailsBody extends StatelessWidget {
  final TransactionItemModel transaction;

  const TransactionDetailsBody({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section - Transaction Type Badge
          TransactionHeaderSection(transaction: transaction),

          const SizedBox(height: 12),

          // Amount Section
          AmountSection(transaction: transaction),

          const SizedBox(height: 12),

          // Transaction Details Section
          TransactionInfoSection(transaction: transaction),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
