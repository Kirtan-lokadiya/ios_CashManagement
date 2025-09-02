import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/add_cash_income/add_cash_income.dart';
import '../presentation/settings/settings.dart';
import '../presentation/record_payment/record_payment.dart';
import '../presentation/reminders/reminders_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String dashboard = '/dashboard';
  static const String transactionHistory = '/transaction-history';
  static const String addCashIncome = '/add-cash-income';
  static const String settings = '/settings';
  static const String recordPayment = '/record-payment';
  static const String reminders = '/reminders';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    dashboard: (context) => const Dashboard(),
    transactionHistory: (context) => const TransactionHistory(),
    addCashIncome: (context) => const AddCashIncome(),
    settings: (context) => const Settings(),
    recordPayment: (context) => const RecordPayment(),
    reminders: (context) => const RemindersScreen(),
    // TODO: Add your other routes here
  };
}
