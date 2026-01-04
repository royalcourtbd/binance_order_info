import 'package:flutter/material.dart';
import '../models/date_section_model.dart';
import 'transaction_item.dart';

class DateSection extends StatelessWidget {
  final DateSectionModel model;

  const DateSection({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Text(
                model.date,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      model.day,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    model.year,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              // Buy column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳ ${model.dayBuyWithCharge}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (model.dayBuy != model.dayBuyWithCharge)
                    Text(
                      "৳ ${model.dayBuy}",
                      style: TextStyle(
                        color: Colors.blue.withValues(alpha: 0.6),
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Sell column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳ ${model.daySellWithCharge}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (model.daySell != model.daySellWithCharge)
                    Text(
                      "৳ ${model.daySell}",
                      style: TextStyle(
                        color: Colors.red.withValues(alpha: 0.6),
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: model.transactions.length,
          itemBuilder: (context, index) {
            final dateModel = model.transactions[index];

            return TransactionItem(transaction: dateModel);
          },
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
