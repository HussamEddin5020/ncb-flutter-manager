import 'package:flutter/material.dart';
import 'package:manager_web/screens/filtered_transactions_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate directly to filtered transactions screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const FilteredTransactionsScreen(),
        ),
      );
    });

    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

