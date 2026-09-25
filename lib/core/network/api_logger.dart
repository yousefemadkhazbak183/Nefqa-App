import 'package:flutter/foundation.dart';
import 'package:requests_inspector/requests_inspector.dart';

class ApiLogger {
  static void log({
    required String name,
    required RequestMethod method,
    required String url,
    Map<String, dynamic>? params,
    required int statusCode,
    dynamic responseBody,
  }) {
    if (!kDebugMode) return;

    InspectorController().addNewRequest(
      RequestDetails(
        requestName: name,
        requestMethod: method,
        url: url,
        queryParameters: params ?? {},
        statusCode: statusCode,
        responseBody: responseBody,
        sentTime: DateTime.now(),
      ),
    );
  }
}
