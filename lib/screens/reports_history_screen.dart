import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/expense_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsHistoryScreen extends StatefulWidget {
  const ReportsHistoryScreen({super.key});

  @override
  State<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends State<ReportsHistoryScreen> {
  bool _isSyncing = false;

  Future<void> _sync(BuildContext ctx) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Sign in first to sync your cloud data.')));
      return;
    }
    setState(() => _isSyncing = true);
    await ctx.read<ExpenseProvider>().syncDownFromFirebase();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Cloud sync complete!'), backgroundColor: AppTheme.primary));
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-sync on open if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null && mounted) {
        _sync(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Previous Reports'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_sync),
              tooltip: 'Sync from Firebase',
              onPressed: () => _sync(context),
            ),
        ],
      ),
      body: user == null
          ? _buildSignInPrompt(context)
          : Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                if (provider.expenses.isEmpty) {
                  return _buildEmpty(context);
                }
                return Column(
                  children: [
                    // User greeting banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                            backgroundColor: AppTheme.primaryContainer,
                            child: user.photoURL == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user.displayName?.split(' ').first ?? 'User'}!',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${provider.expenses.length} transaction(s) synced',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Transaction list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: provider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = provider.expenses[index];
                          final dateStr = '${expense.date.day}/${expense.date.month}/${expense.date.year}';
                          final categoryColors = {
                            'Food': Colors.orange,
                            'Shopping': Colors.purple,
                            'Transport': Colors.blue,
                            'Health': Colors.green,
                            'Entertainment': Colors.red,
                            'Other': Colors.grey,
                          };
                          final color = categoryColors[expense.category] ?? Colors.grey;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: color.withAlpha(30),
                                child: Icon(Icons.receipt_long, color: color, size: 20),
                              ),
                              title: Text(
                                expense.vendor.isNotEmpty ? expense.vendor : expense.category,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('$dateStr • ${expense.category}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              trailing: Text(
                                'Rs. ${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: color),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text('Sign In Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Sign in with Google from your Profile to sync and view your complete financial history stored in the cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No records yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Scan receipts to start tracking!', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
