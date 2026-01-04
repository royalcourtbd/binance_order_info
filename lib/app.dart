import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/p2p_order_screen.dart';

class BinanceP2PApp extends StatelessWidget {
  const BinanceP2PApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const P2POrderScreen(),
    );
  }
}
