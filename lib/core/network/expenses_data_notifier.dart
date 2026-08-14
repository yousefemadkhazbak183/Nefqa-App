import 'package:flutter/foundation.dart';

class ExpensesDataNotifier extends ChangeNotifier {
  void notifyExpensesChanged() {
    notifyListeners();
  }
}
