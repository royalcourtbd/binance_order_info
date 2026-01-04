import 'package:flutter/material.dart';
import '../models/month_section_model.dart';
import 'date_section.dart';

class MonthSection extends StatelessWidget {
  final MonthSectionModel model;

  const MonthSection({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Month header with summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                model.monthName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Buy column
                  Column(
                    children: [
                      const Text(
                        'Buy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${model.monthBuyUsdt} USDT',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '৳ ${model.monthBuyWithCharge}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (model.monthBuy != model.monthBuyWithCharge)
                        Text(
                          '৳ ${model.monthBuy}',
                          style: TextStyle(
                            color: Colors.blue.withValues(alpha: 0.5),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (double.tryParse(model.avgBuyRate) != null &&
                          double.parse(model.avgBuyRate) > 0)
                        Text(
                          '@${model.avgBuyRate}',
                          style: TextStyle(
                            color: Colors.blue.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  // Sell column
                  Column(
                    children: [
                      const Text(
                        'Sell',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${model.monthSellUsdt} USDT',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '৳ ${model.monthSellWithCharge}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (model.monthSell != model.monthSellWithCharge)
                        Text(
                          '৳ ${model.monthSell}',
                          style: TextStyle(
                            color: Colors.red.withValues(alpha: 0.5),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (double.tryParse(model.avgSellRate) != null &&
                          double.parse(model.avgSellRate) > 0)
                        Text(
                          '@${model.avgSellRate}',
                          style: TextStyle(
                            color: Colors.red.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Date sections for this month
        ...model.dateSections.map((dateSection) {
          return DateSection(model: dateSection);
        }),

        // Empty state if no transactions
        if (model.dateSections.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions this month',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
