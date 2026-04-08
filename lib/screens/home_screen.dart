import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../services/ocr_service.dart';
import '../models/expense.dart';
import '../services/ai_logic_engine.dart';
import '../services/tts_service.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Main dashboard screen showing recent expenses and the primary action button.
class _HomeScreenState extends State<HomeScreen> {
  final OcrService _ocrService = OcrService();
  final TtsService _ttsService = TtsService();
  bool _isProcessing = false;

  void _scanReceipt() async {
    setState(() => _isProcessing = true);
    
    final result = await _ocrService.scanReceipt();
    
    if (result != null) {
      final expense = Expense(
        amount: result['amount'],
        date: result['date'],
        vendor: result['vendor'],
        category: result['category'],
      );

      if (mounted) {
        context.read<ExpenseProvider>().addExpense(expense);
        _triggerAiSuggestion(expense.amount, expense.category);
      }
    }
    
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  void _triggerAiSuggestion(double amount, String category) {
    if (!mounted) return;
    
    final provider = context.read<ExpenseProvider>();
    final settings = context.read<SettingsProvider>();
    
    double categoryTotal = provider.categoryBreakdown[category] ?? 0.0;
    
    String suggestion = BudgetStrategist.generateLocalSuggestion(
      amount,
      category,
      categoryTotal,
      isHindi: settings.isHindi,
    );

    // Show suggestion in UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(suggestion),
        backgroundColor: AppTheme.primary,
        action: SnackBarAction(
          label: settings.isHindi ? 'सुनें' : 'Hear',
          textColor: AppTheme.onPrimary,
          onPressed: () => _ttsService.speak(suggestion, isHindi: settings.isHindi),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ethereal Ledger',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Primary Call to Action
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDim],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.onSurface.withOpacity(0.08),
                          blurRadius: 32,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _scanReceipt,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 48, color: AppTheme.onPrimary),
                              SizedBox(height: 16),
                              Text(
                                "Scan Receipt",
                                style: TextStyle(
                                  color: AppTheme.onPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    "Recent Activity",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: expenses.isEmpty
                        ? Center(
                            child: Text(
                              "No recent expenses. Scan a receipt to begin.",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.outlineVariant,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100), // Space for floating dock
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final ex = expenses[index];
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(ex.vendor, style: Theme.of(context).textTheme.labelLarge),
                                  subtitle: Text(ex.category, style: Theme.of(context).textTheme.bodySmall),
                                  trailing: Text(
                                    "₹${ex.amount.toStringAsFixed(2)}",
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: ex.category == 'Income' || ex.category == 'Refund' ? AppTheme.secondary : AppTheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
