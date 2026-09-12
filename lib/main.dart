import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/invoice_repository.dart';
import 'data/repositories/product_repository.dart';
import 'viewmodels/invoices_view_model.dart';
import 'viewmodels/pos_view_model.dart';
import 'viewmodels/products_view_model.dart';
import 'views/shared/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CleaningPosApp());
}

class CleaningPosApp extends StatelessWidget {
  const CleaningPosApp({super.key});

  @override
  Widget build(BuildContext context) {

    final productRepository = ProductRepository();
    final invoiceRepository = InvoiceRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PosViewModel(
            productRepository: productRepository,
            invoiceRepository: invoiceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsViewModel(repository: productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => InvoicesViewModel(repository: invoiceRepository),
        ),
      ],
      child: MaterialApp(
        title: 'مبيعات محل المنظفات',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [Locale('ar', 'EG')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
