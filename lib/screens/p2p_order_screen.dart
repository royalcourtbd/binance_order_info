import 'package:flutter/material.dart';
import '../models/date_section_model.dart';
import '../models/transaction_item_model.dart';
import '../widgets/summary_item.dart';
import '../widgets/date_section.dart';

class P2POrderScreen extends StatelessWidget {
  P2POrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Binance P2P Orders',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Summary Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryItem(
                  label: "Buy",
                  amount: "35,000.00",
                  color: Colors.blue,
                ),
                SummaryItem(
                  label: "Sell",
                  amount: "30,220.00",
                  color: Colors.red,
                ),
                SummaryItem(
                  label: "Total",
                  amount: "4,780.00",
                  color: Colors.black87,
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: dateSections.length,
              itemBuilder: (context, index) {
                return DateSection(model: dateSections[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  final List<DateSectionModel> dateSections = [
    DateSectionModel(
      date: "26",
      day: "Fri",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "80.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#1234567896",
          method: "Cash",
          amount: "80.00",
        ),
      ],
    ),
    DateSectionModel(
      date: "25",
      day: "Thu",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "215.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#1234567897",
          method: "Cash",
          amount: "85.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1234567898",
          method: "Cash",
          amount: "80.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1234567899",
          method: "Cash",
          amount: "50.00",
        ),
      ],
    ),
    DateSectionModel(
      date: "24",
      day: "Wed",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "1,005.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#123456789",
          method: "Cash",
          amount: "130.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#987654321",
          method: "Cash",
          amount: "620.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1122334455",
          method: "Cash",
          amount: "40.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#215487963",
          method: "Cash",
          amount: "215.00",
        ),
      ],
    ),

    DateSectionModel(
      date: "24",
      day: "Wed",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "1,005.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#123456789",
          method: "Cash",
          amount: "130.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#987654321",
          method: "Cash",
          amount: "620.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1122334455",
          method: "Cash",
          amount: "40.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#215487963",
          method: "Cash",
          amount: "215.00",
        ),
      ],
    ),

    DateSectionModel(
      date: "24",
      day: "Wed",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "1,005.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#123456789",
          method: "Cash",
          amount: "130.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#987654321",
          method: "Cash",
          amount: "620.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1122334455",
          method: "Cash",
          amount: "40.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#215487963",
          method: "Cash",
          amount: "215.00",
        ),
      ],
    ),

    DateSectionModel(
      date: "24",
      day: "Wed",
      year: "12.2025",
      dayBuy: "0.00",
      daySell: "1,005.00",
      transactions: [
        TransactionItemModel(
          category: "Sell",
          title: "#123456789",
          method: "Cash",
          amount: "130.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#987654321",
          method: "Cash",
          amount: "620.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#1122334455",
          method: "Cash",
          amount: "40.00",
        ),
        TransactionItemModel(
          category: "Sell",
          title: "#215487963",
          method: "Cash",
          amount: "215.00",
        ),
      ],
    ),
  ];
}
