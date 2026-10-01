/// QLaya HTTP client — wraps the qlaya-serve REST API.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'downloader.dart';
import 'models.dart';
import 'tasks.dart';
import 'types.dart';

/// A client for the QLaya HTTP server (`qlaya-serve`).
///
/// Connects to a running QLaya inference engine instance and executes
/// tasks using the `qlaya.int8.onnx` model (hosted on Hugging Face).
///
/// ## Example
///
/// ```dart
/// // Uses default http://localhost:8000 or custom baseUrl
/// final client = QLayaClient();
///
/// // Intent Classification Task
/// final intent = await client.classify(
///   text: 'I was charged twice, please refund',
///   choices: ['billing_refund', 'cancellation', 'tech_support', 'other'],
/// );
/// print('Intent: ${intent.choice} (${intent.confidence})');
///
/// client.close();
/// ```
class QLayaClient {
  final String baseUrl;
  final http.Client _http;
  final Duration timeout;

  QLayaClient({
    this.baseUrl = 'http://localhost:8000',
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  /// Ensures that the model weights are downloaded locally from Hugging Face.
  Future<void> ensureModel({
    String? directory,
    String? path,
    void Function(QLayaDownloadProgress progress)? onProgress,
  }) async {
    await QLayaDownloader.ensureModel(
      directory: directory,
      path: path,
      onProgress: onProgress,
    );
  }

  /// Execute any typed [QLayaTask] using the bundled `qlaya.int8.onnx` model.
  Future<T> runTask<T>(
    QLayaTask<T> task, {
    Map<String, String>? extraHeaders,
  }) async {
    final prediction = await predict(
      text: task.text,
      model: task.model,
      questions: task.buildQuestions(),
      extraHeaders: extraHeaders,
    );
    return task.parseResult(prediction);
  }

  /// Classify [text] into one of the candidate [choices].
  Future<QLayaClassificationResult> classify({
    required String text,
    required List<String> choices,
    String? instruction,
    String questionId = 'classification',
    Map<String, String>? extraHeaders,
  }) =>
      runTask(
        QLayaTasks.classify(
          text: text,
          choices: choices,
          questionText: instruction,
          questionId: questionId,
        ),
        extraHeaders: extraHeaders,
      );

  /// Score or rate [text] on a continuous scale (e.g. sentiment, urgency).
  Future<QLayaScoreResult> score({
    required String text,
    String? instruction,
    String questionId = 'score',
    Map<String, String>? extraHeaders,
  }) =>
      runTask(
        QLayaTasks.score(
          text: text,
          questionText: instruction,
          questionId: questionId,
        ),
        extraHeaders: extraHeaders,
      );

  /// Verify whether a boolean [statement] holds true for [text].
  Future<QLayaBoolResult> verify({
    required String text,
    required String statement,
    String questionId = 'verify',
    Map<String, String>? extraHeaders,
  }) =>
      runTask(
        QLayaTasks.verify(
          text: text,
          statement: statement,
          questionId: questionId,
        ),
        extraHeaders: extraHeaders,
      );

  /// Route [text] to one of the target [routes].
  Future<QLayaRoutingResult> route({
    required String text,
    required List<String> routes,
    String? instruction,
    String questionId = 'route',
    Map<String, String>? extraHeaders,
  }) =>
      runTask(
        QLayaTasks.route(
          text: text,
          routes: routes,
          instruction: instruction,
          questionId: questionId,
        ),
        extraHeaders: extraHeaders,
      );

  /// Send a low-level prediction request to the QLaya server.
  ///
  /// [text] is the input to classify/route.
  /// [model] selects the model specification; defaults to the bundled `qlaya.int8.onnx`.
  /// [questions] questions defining the routing/classification decisions.
  Future<QLayaPrediction> predict({
    required String text,
    QLayaModelSpec? model,
    List<QLayaQuestion>? questions,
    Map<String, String>? extraHeaders,
  }) async {
    final resolvedModel = model ?? QLayaModels.int8;

    final body = <String, dynamic>{
      'text': text,
      'model': {
        'id': resolvedModel.id,
        'file': resolvedModel.fileName,
        'repo': resolvedModel.repo,
        if (resolvedModel.subfolder != null)
          'subfolder': resolvedModel.subfolder,
      },
      if (questions != null)
        'questions': questions.map((q) => q.toJson()).toList(),
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

  /// List available models from the server.
  Future<List<String>> listModels() async {
    final uri = Uri.parse('$baseUrl/models');
    final response = await _http.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw QLayaApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
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
