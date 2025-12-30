import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final TransactionItemModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.category.toUpperCase() == 'BUY';
    final transactionColor = isBuy ? Colors.blue : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: transactionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transaction.category,
              style: TextStyle(
                color: transactionColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                Text(
                  transaction.method,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "৳ ${double.tryParse(transaction.amount)?.toStringAsFixed(2) ?? transaction.amount}",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: transactionColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
