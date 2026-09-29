/// QLaya — Flutter and Dart client library.
///
/// Provides a type-safe interface to the QLaya HTTP server or local inference.
/// Users can select from 10 quantized model variants derived from benchmark experiments.
///
/// ## Quick start
///
/// ```dart
/// import 'package:qlaya_flutter/qlaya_flutter.dart';
///
/// void main() async {
///   final client = QLayaClient(baseUrl: 'http://localhost:8000');
///
///   // List all available quantized model variants
///   print(QLayaModels.allIds);
///
///   // Pick a model by QLaya ID
///   final model = QLayaModels.resolve('QLaya-TopProduction');
///
///   // Make a routing decision
///   final result = await client.predict(
///     text: 'I need a refund for a duplicate charge',
///     model: model,
///   );
///   print(result);
///   client.close();
/// }
/// ```
library qlaya_flutter;

export 'src/client.dart';
export 'src/models.dart';
export 'src/types.dart';
