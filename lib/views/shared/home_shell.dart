import 'package:flutter/material.dart';

import '../invoices/invoices_screen.dart';
import '../pos/pos_screen.dart';
import '../products/products_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PosScreen(),
    ProductsScreen(),
    InvoicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale),
                  label: Text('البيع'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2),
                  label: Text('المنتجات'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long),
                  label: Text('الفواتير'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
