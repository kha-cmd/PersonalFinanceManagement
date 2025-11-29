import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fixed_expense/fixed_expense_screen.dart';
import 'screens/money_left/money_left_screen.dart';
import 'screens/daily_spending/add_daily_spending_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expense Manager',
      theme: ThemeData(primaryColor: AppColors.primary, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/fixed_expense': (_) => const FixedExpenseScreen(),
        '/money_left': (_) => const MoneyLeftScreen(),
        '/add_daily': (_) => const AddDailySpendingScreen(),
      },
    );
  }
}