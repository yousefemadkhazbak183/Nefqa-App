import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/expense.dart';

class ExpenseRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  ExpenseRemoteDataSource(this._supabaseClient);

  Future<List<Expense>> getExpenses(String userId) async {
    final response = await _supabaseClient
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> addExpense(Expense expense) async {
    final json = expense.toJson()..remove('id');

    final response = await _supabaseClient
        .from('expenses')
        .insert(json)
        .select()
        .single();

    return Expense.fromJson(response);
  }

  Future<Expense> updateExpense(Expense expense) async {
    final response = await _supabaseClient
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id!)
        .select()
        .single();

    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(int id) async {
    await _supabaseClient.from('expenses').delete().eq('id', id);
  }
}
