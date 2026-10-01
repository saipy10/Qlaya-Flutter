/// QLaya — Flutter and Dart client library.
///
/// Provides a type-safe interface to the QLaya decision engine powered exclusively
/// by the bundled `qlaya.int8.onnx` quantized model.
///
/// Supports high-level tasks for:
/// - Intent and category classification
/// - Continuous sentiment and urgency scoring
/// - Boolean question verification
/// - Workflow and destination routing
///
/// ## Quick start
///
/// ```dart
/// import 'package:qlaya_flutter/qlaya_flutter.dart';
///
/// void main() async {
///   final client = QLayaClient(baseUrl: 'http://localhost:8000');
///
///   // Run an intent classification task using bundled qlaya.int8.onnx
///   final result = await client.classify(
///     text: 'I was charged twice, please refund',
///     choices: ['refund', 'billing_issue', 'general_support'],
///   );
///   print('Choice: ${result.choice} (${result.confidence})');
///
///   client.close();
/// }
/// ```
library qlaya_flutter;

export 'src/client.dart';
export 'src/downloader.dart';
export 'src/models.dart';
export 'src/tasks.dart';
export 'src/types.dart';
