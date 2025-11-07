import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

/// Expense service provider
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

/// All expenses provider
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getExpenses();
});

/// Expenses for current month
final monthlyExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return service.getExpensesByDateRange(startOfMonth, endOfMonth);
});

/// Total expenses for current month
final monthlyExpensesTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(monthlyExpensesProvider.future);
  return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
});

/// Expenses by category summary
final expensesByCategoryProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final service = ref.watch(expenseServiceProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return service.getExpensesByCategorySummary(startOfMonth, endOfMonth);
});

/// Expense controller for CRUD operations
final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
      return ExpenseController(ref.watch(expenseServiceProvider), ref);
    });

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final ExpenseService _service;
  final Ref _ref;

  ExpenseController(this._service, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> createExpense(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.createExpense(expense);
      _ref.invalidate(expensesProvider);
      _ref.invalidate(monthlyExpensesProvider);
      _ref.invalidate(monthlyExpensesTotalProvider);
      _ref.invalidate(expensesByCategoryProvider);
    });
  }

  Future<void> updateExpense(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateExpense(expense);
      _ref.invalidate(expensesProvider);
      _ref.invalidate(monthlyExpensesProvider);
      _ref.invalidate(monthlyExpensesTotalProvider);
      _ref.invalidate(expensesByCategoryProvider);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteExpense(expenseId);
      _ref.invalidate(expensesProvider);
      _ref.invalidate(monthlyExpensesProvider);
      _ref.invalidate(monthlyExpensesTotalProvider);
      _ref.invalidate(expensesByCategoryProvider);
    });
  }
}
