/// Task abstractions for QLaya decision engine.
///
/// All tasks exclusively use the bundled `qlaya.int8.onnx` model variant.
library;

import 'models.dart';
import 'types.dart';

/// Base contract for all QLaya inference tasks.
abstract class QLayaTask<T> {
  /// The input text to classify, score, verify, or route.
  String get text;

  /// The model specification — always resolves to the bundled `qlaya.int8.onnx`.
  QLayaModelSpec get model => QLayaModels.int8;

  /// Builds the questions payload sent to the QLaya inference engine.
  List<QLayaQuestion> buildQuestions();

  /// Parses the raw prediction response into the typed result [T].
  T parseResult(QLayaPrediction prediction);
}

/// A categorical classification task.
///
/// Classifies [text] into one of the provided [choices] (e.g., intent detection,
/// topic tagging, customer inquiry categorization).
class QLayaClassificationTask extends QLayaTask<QLayaClassificationResult> {
  @override
  final String text;

  /// Candidate categories / choices.
  final List<String> choices;

  /// Prompt or instruction given to the engine.
  final String questionText;

  /// Unique question identifier for tracking the answer.
  final String questionId;

  QLayaClassificationTask({
    required this.text,
    required this.choices,
    String? questionText,
    this.questionId = 'classification',
  }) : questionText = questionText ?? 'Select the best matching category';

  @override
  List<QLayaQuestion> buildQuestions() => [
        QLayaQuestion(
          id: questionId,
          text: questionText,
          type: 'choice',
          choices: choices,
        ),
      ];

  @override
  QLayaClassificationResult parseResult(QLayaPrediction prediction) {
    final answer = prediction.getAnswer(questionId);
    if (answer == null) {
      throw StateError('Task expected answer for question "$questionId"');
    }
    return QLayaClassificationResult(
      choice: answer.value?.toString() ?? '',
      confidence: answer.confidence,
      rawAnswer: answer,
    );
  }
}

/// A continuous scoring or rating task.
///
/// Scores [text] on a continuous scale (e.g. sentiment score, urgency rating,
/// satisfaction score, priority score).
class QLayaScoreTask extends QLayaTask<QLayaScoreResult> {
  @override
  final String text;

  /// Prompt or instruction given to the engine.
  final String questionText;

  /// Unique question identifier for tracking the answer.
  final String questionId;

  QLayaScoreTask({
    required this.text,
    String? questionText,
    this.questionId = 'score',
  }) : questionText = questionText ?? 'Rate this input on a scale from 0 to 1';

  @override
  List<QLayaQuestion> buildQuestions() => [
        QLayaQuestion(
          id: questionId,
          text: questionText,
          type: 'score',
        ),
      ];

  @override
  QLayaScoreResult parseResult(QLayaPrediction prediction) {
    final answer = prediction.getAnswer(questionId);
    if (answer == null) {
      throw StateError('Task expected answer for question "$questionId"');
    }
    final rawVal = answer.value;
    final numVal = rawVal is num
        ? rawVal.toDouble()
        : double.tryParse(rawVal?.toString() ?? '') ?? 0.0;
    return QLayaScoreResult(
      score: numVal,
      confidence: answer.confidence,
      rawAnswer: answer,
    );
  }
}

/// A boolean verification task.
///
/// Verifies whether [statement] holds true for [text] (e.g. "Is refund requested?",
/// "Is this inquiry urgent?", "Is this a complaint?").
class QLayaBoolTask extends QLayaTask<QLayaBoolResult> {
  @override
  final String text;

  /// Statement or condition to evaluate.
  final String statement;

  /// Unique question identifier for tracking the answer.
  final String questionId;

  QLayaBoolTask({
    required this.text,
    required this.statement,
    this.questionId = 'verify',
  });

  @override
  List<QLayaQuestion> buildQuestions() => [
        QLayaQuestion(
          id: questionId,
          text: statement,
          type: 'bool',
          choices: const ['true', 'false'],
        ),
      ];

  @override
  QLayaBoolResult parseResult(QLayaPrediction prediction) {
    final answer = prediction.getAnswer(questionId);
    if (answer == null) {
      throw StateError('Task expected answer for question "$questionId"');
    }
    final raw = answer.value;
    final bool boolVal;
    if (raw is bool) {
      boolVal = raw;
    } else {
      final s = raw?.toString().toLowerCase().trim();
      boolVal = s == 'true' || s == 'yes' || s == '1';
    }
    return QLayaBoolResult(
      value: boolVal,
      confidence: answer.confidence,
      rawAnswer: answer,
    );
  }
}

/// A workflow routing task.
///
/// Routes [text] to the appropriate handler, department, or workflow
/// destination from [routes].
class QLayaRoutingTask extends QLayaTask<QLayaRoutingResult> {
  @override
  final String text;

  /// Target route destinations.
  final List<String> routes;

  /// Routing prompt or instruction.
  final String instruction;

  /// Unique question identifier for tracking the answer.
  final String questionId;

  QLayaRoutingTask({
    required this.text,
    required this.routes,
    String? instruction,
    this.questionId = 'route',
  }) : instruction = instruction ?? 'Determine the target destination route';

  @override
  List<QLayaQuestion> buildQuestions() => [
        QLayaQuestion(
          id: questionId,
          text: instruction,
          type: 'choice',
          choices: routes,
        ),
      ];

  @override
  QLayaRoutingResult parseResult(QLayaPrediction prediction) {
    final answer = prediction.getAnswer(questionId);
    if (answer == null) {
      throw StateError('Task expected answer for question "$questionId"');
    }
    return QLayaRoutingResult(
      route: answer.value?.toString() ?? '',
      confidence: answer.confidence,
      rawAnswer: answer,
    );
  }
}

/// Factory and namespace for creating QLaya tasks.
abstract final class QLayaTasks {
  /// Create a categorical classification task.
  static QLayaClassificationTask classify({
    required String text,
    required List<String> choices,
    String? questionText,
    String questionId = 'classification',
  }) =>
      QLayaClassificationTask(
        text: text,
        choices: choices,
        questionText: questionText,
        questionId: questionId,
      );

  /// Create a continuous scoring / rating task.
  static QLayaScoreTask score({
    required String text,
    String? questionText,
    String questionId = 'score',
  }) =>
      QLayaScoreTask(
        text: text,
        questionText: questionText,
        questionId: questionId,
      );

  /// Create a boolean verification task.
  static QLayaBoolTask verify({
    required String text,
    required String statement,
    String questionId = 'verify',
  }) =>
      QLayaBoolTask(
        text: text,
        statement: statement,
        questionId: questionId,
      );

  /// Create a workflow routing task.
  static QLayaRoutingTask route({
    required String text,
    required List<String> routes,
    String? instruction,
    String questionId = 'route',
  }) =>
      QLayaRoutingTask(
        text: text,
        routes: routes,
        instruction: instruction,
        questionId: questionId,
      );
}
