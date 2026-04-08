import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _expenses = await DatabaseHelper.instance.readAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense, {bool persist = true}) async {
    if (persist) {
      await DatabaseHelper.instance.create(expense);
      await loadExpenses();
      
      // Mirror to Firebase if authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
           .collection('users')
           .doc(user.uid)
           .collection('expenses')
           .doc(expense.id.toString())
           .set(expense.toMap());
      }
    } else {
      _expenses.insert(0, expense);
      notifyListeners();
    }
  }

  Future<void> syncDownFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final snapshot = await FirebaseFirestore.instance
       .collection('users')
       .doc(user.uid)
       .collection('expenses')
       .get();
       
    for (var doc in snapshot.docs) {
      final expense = Expense.fromMap(doc.data());
      // Only insert to SQLite if it doesn't exist
      if (!_expenses.any((e) => e.id == expense.id)) {
        await DatabaseHelper.instance.create(expense);
      }
    }
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.update(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadExpenses();
  }

  // Analytics Helpers
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var expense in _expenses) {
      if (breakdown.containsKey(expense.category)) {
        breakdown[expense.category] = breakdown[expense.category]! + expense.amount;
      } else {
        breakdown[expense.category] = expense.amount;
      }
    }
    return breakdown;
  }
}
