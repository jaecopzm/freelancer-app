import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;

  /// Get all expenses for current user
  Future<List<Expense>> getExpenses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  /// Get expenses for a specific date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .eq('category', category)
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  /// Get expenses for a specific project
  Future<List<Expense>> getExpensesByProject(String projectId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .eq('project_id', projectId)
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get expenses by category summary
  Future<Map<String, double>> getExpensesByCategorySummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final summary = <String, double>{};

    for (final expense in expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }

    return summary;
  }

  /// Create a new expense
  Future<Expense> createExpense(Expense expense) async {
    final response = await _supabase
        .from('expenses')
        .insert(expense.toJson())
        .select()
        .single();

    return Expense.fromJson(response);
  }

  /// Update an expense
  Future<Expense> updateExpense(Expense expense) async {
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());

    final response = await _supabase
        .from('expenses')
        .update(updatedExpense.toJson())
        .eq('id', expense.id)
        .select()
        .single();

    return Expense.fromJson(response);
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _supabase.from('expenses').delete().eq('id', expenseId);
  }

  /// Get tax-deductible expenses total
  Future<double> getTaxDeductibleTotal(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses
        .where((e) => e.isTaxDeductible)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }
}
