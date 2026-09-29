/// Dart types for QLaya API requests and responses.
library;

/// A single question definition sent to the QLaya server.
class QLayaQuestion {
  final String id;
  final String text;
  final String type; // 'choice', 'score', 'noul'
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
