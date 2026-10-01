/// Dart types for QLaya API requests, responses, and task results.
library;

/// A single question definition sent to the QLaya server.
class QLayaQuestion {
  final String id;
  final String text;
  final String type; // 'choice', 'score', 'bool'
  final List<String>? choices;

  const QLayaQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.choices,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type,
        if (choices != null) 'choices': choices,
      };
}

/// A single answer returned by the QLaya server.
class QLayaAnswer {
  final String id;
  final dynamic value;
  final double? confidence;

  const QLayaAnswer({
    required this.id,
    required this.value,
    this.confidence,
  });

  factory QLayaAnswer.fromJson(Map<String, dynamic> json) => QLayaAnswer(
        id: json['id'] as String,
        value: json['value'],
        confidence: (json['confidence'] as num?)?.toDouble(),
      );

  @override
  String toString() => 'QLayaAnswer(id: $id, value: $value, confidence: $confidence)';
}

/// The complete prediction response from the QLaya server.
class QLayaPrediction {
  final List<QLayaAnswer> answers;
  final String? modelId;
  final double? latencyMs;

  const QLayaPrediction({
    required this.answers,
    this.modelId,
    this.latencyMs,
  });

  /// Find answer by question ID, or return the first answer if ID not found.
  QLayaAnswer? getAnswer(String id) {
    for (final a in answers) {
      if (a.id == id) return a;
    }
    return answers.isNotEmpty ? answers.first : null;
  }

  factory QLayaPrediction.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as List<dynamic>? ?? [];
    return QLayaPrediction(
      answers: rawAnswers
          .map((a) => QLayaAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
      modelId: json['model_id'] as String?,
      latencyMs: (json['latency_ms'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() => 'QLayaPrediction(model: $modelId, answers: $answers)';
}

/// Result of a classification task.
class QLayaClassificationResult {
  /// The predicted choice / class.
  final String choice;

  /// Confidence score between 0.0 and 1.0 (if returned by engine).
  final double? confidence;

  /// The raw QLaya answer payload.
  final QLayaAnswer rawAnswer;

  const QLayaClassificationResult({
    required this.choice,
    this.confidence,
    required this.rawAnswer,
  });

  @override
  String toString() =>
      'QLayaClassificationResult(choice: $choice, confidence: $confidence)';
}

/// Result of a continuous scoring or rating task.
class QLayaScoreResult {
  /// Numeric score output.
  final double score;

  /// Confidence score between 0.0 and 1.0.
  final double? confidence;

  /// The raw QLaya answer payload.
  final QLayaAnswer rawAnswer;

  const QLayaScoreResult({
    required this.score,
    this.confidence,
    required this.rawAnswer,
  });

  @override
  String toString() =>
      'QLayaScoreResult(score: $score, confidence: $confidence)';
}

/// Result of a boolean verification task.
class QLayaBoolResult {
  /// True or false decision.
  final bool value;

  /// Confidence score between 0.0 and 1.0.
  final double? confidence;

  /// The raw QLaya answer payload.
  final QLayaAnswer rawAnswer;

  const QLayaBoolResult({
    required this.value,
    this.confidence,
    required this.rawAnswer,
  });

  @override
  String toString() =>
      'QLayaBoolResult(value: $value, confidence: $confidence)';
}

/// Result of a routing task.
class QLayaRoutingResult {
  /// The resolved target route or handler.
  final String route;

  /// Confidence score between 0.0 and 1.0.
  final double? confidence;

  /// The raw QLaya answer payload.
  final QLayaAnswer rawAnswer;

  const QLayaRoutingResult({
    required this.route,
    this.confidence,
    required this.rawAnswer,
  });

  @override
  String toString() =>
      'QLayaRoutingResult(route: $route, confidence: $confidence)';
}
