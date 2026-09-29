/// QLaya HTTP client — wraps the qlaya-serve REST API.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'types.dart';

/// A client for the QLaya HTTP server (`qlaya-serve`).
///
/// Connects to a running [QLaya serve](https://github.com/saipy10/QLaya)
/// instance and sends prediction requests.
///
/// ## Example
///
/// ```dart
/// final client = QLayaClient(baseUrl: 'http://localhost:8000');
///
/// // Pick the recommended production model
/// final model = QLayaModels.resolve('QLaya-TopProduction');
///
/// final result = await client.predict(
///   text: 'Cancel my subscription immediately',
///   model: model,
///   questions: [
///     QLayaQuestion(
///       id: 'intent',
///       text: 'What does the user want?',
///       type: 'choice',
///       choices: ['refund', 'cancel', 'support', 'other'],
///     ),
///   ],
/// );
/// print(result.answers);
/// client.close();
/// ```
class QLayaClient {
  final String baseUrl;
  final http.Client _http;
  final Duration timeout;

  QLayaClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  /// Send a prediction request to the QLaya server.
  ///
  /// [text] is the input to classify/route.
  /// [model] selects the quantized variant; defaults to `QLaya-TopProduction`.
  /// [questions] overrides the default router questions.
  Future<QLayaPrediction> predict({
    required String text,
    QLayaModelSpec? model,
    List<QLayaQuestion>? questions,
    Map<String, String>? extraHeaders,
  }) async {
    final resolvedModel = model ?? QLayaModels.all['QLaya-TopProduction']!;

    final body = <String, dynamic>{
      'text': text,
      'model': {
        'repo': resolvedModel.repo,
        if (resolvedModel.subfolder != null) 'subfolder': resolvedModel.subfolder,
      },
      if (questions != null) 'questions': questions.map((q) => q.toJson()).toList(),
    };

    final uri = Uri.parse('$baseUrl/predict');
    final response = await _http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?extraHeaders,
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw QLayaApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return QLayaPrediction.fromJson(json);
  }

  /// List available models from the server (requires server support).
  Future<List<String>> listModels() async {
    final uri = Uri.parse('$baseUrl/models');
    final response = await _http.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw QLayaApiException(statusCode: response.statusCode, body: response.body);
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return List<String>.from(json['models'] as List? ?? []);
  }

  /// Release underlying HTTP resources.
  void close() => _http.close();
}

/// Exception thrown when the QLaya HTTP server returns a non-200 response.
class QLayaApiException implements Exception {
  final int statusCode;
  final String body;

  const QLayaApiException({required this.statusCode, required this.body});

  @override
  String toString() => 'QLayaApiException($statusCode): $body';
}
