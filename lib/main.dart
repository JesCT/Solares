import 'package:flutter/material.dart';
import 'package:solares/navigator_bar.dart';
import 'package:solares/pages/dashboard/minimun_stock.dart';
import 'package:solares/pages/dashboard/orders_day.dart';
import 'package:solares/pages/dashboard/pending_indents.dart';
import 'package:solares/pages/dashboard/total_orders_day.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solares',
      home: const BottomNavBar(),
      routes: <String, WidgetBuilder>{
        '/fist': (BuildContext context) => const OrdersDay(),
        '/second': (BuildContext context) => const PendingIndents(),
        '/third': (BuildContext context) => const TotalOrders(),
        '/fouth': (BuildContext context) => const MinStock(),
      },
    );
  }
}
