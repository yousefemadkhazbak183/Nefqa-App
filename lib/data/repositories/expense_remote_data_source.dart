import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:requests_inspector/requests_inspector.dart';
import '../../core/network/api_logger.dart';
import '../models/expense.dart';

class ExpenseRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;
  static const _timeoutDuration = Duration(seconds: 5);

  ExpenseRemoteDataSource(this._supabaseClient);

  Future<List<Expense>> getExpenses(String userId) async {
    final response = await _supabaseClient
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .timeout(_timeoutDuration);

    ApiLogger.log(
      name: 'Get Expenses',
      method: RequestMethod.GET,
      url: '${_supabaseClient.rest.url}/expenses',
      params: {'user_id': userId},
      statusCode: 200,
      responseBody: response,
    );

    return (response as List).map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> addExpense(Expense expense) async {
    final json = expense.toJson()..remove('id');

    final response = await _supabaseClient
        .from('expenses')
        .insert(json)
        .select()
        .single()
        .timeout(_timeoutDuration);

    ApiLogger.log(
      name: 'Add Expense',
      method: RequestMethod.POST,
      url: '${_supabaseClient.rest.url}/expenses',
      params: json,
      statusCode: 201,
      responseBody: response,
    );

    return Expense.fromJson(response);
  }

  Future<Expense> updateExpense(Expense expense) async {
    final response = await _supabaseClient
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id!)
        .select()
        .single()
        .timeout(_timeoutDuration);

    ApiLogger.log(
      name: 'Update Expense',
      method: RequestMethod.PUT,
      url: '${_supabaseClient.rest.url}/expenses/${expense.id}',
      statusCode: 200,
      responseBody: response,
    );

    return Expense.fromJson(response);
  }

  Future<void> deleteExpense(int id) async {
    await _supabaseClient
        .from('expenses')
        .delete()
        .eq('id', id)
        .timeout(_timeoutDuration);

    ApiLogger.log(
      name: 'Delete Expense',
      method: RequestMethod.DELETE,
      url: '${_supabaseClient.rest.url}/expenses/$id',
      statusCode: 200,
      responseBody: null,
    );
  }
}
