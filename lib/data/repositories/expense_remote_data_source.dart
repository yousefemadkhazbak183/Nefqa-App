import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/network/api_constants.dart';
import '../models/expense.dart';

class ExpenseRemoteDataSource {
  final http.Client _client;

  ExpenseRemoteDataSource(this._client);

  Future<List<Expense>> getExpenses(String userId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/expenses?userId=$userId');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch expenses');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense> addExpense(Expense expense) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/expenses');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }

    return Expense.fromJson(jsonDecode(response.body));
  }

  Future<Expense> updateExpense(Expense expense) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/expenses/${expense.id}');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update expense');
    }

    return Expense.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteExpense(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/expenses/$id');
    final response = await _client.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
}
