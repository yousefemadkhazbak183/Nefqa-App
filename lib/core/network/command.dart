import 'package:flutter/material.dart';
import 'package:nefqa/core/network/result.dart';

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get error => _result is Failure<T>;
  bool get completed => _result is Success<T>;

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    _result = await action();
    _running = false;
    notifyListeners();
  }
}

// Without Parameters
class SimpleCommand<T> extends Command<T> {
  SimpleCommand(this._action);
  final Future<Result<T>> Function() _action;

  Future<void> execute() async {
    await _execute(_action);
  }

}

// More than one Record
class ParameterizedCommand<T, A> extends Command<T> {
  ParameterizedCommand(this._action);
  final Future<Result<T>> Function(A argument) _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}