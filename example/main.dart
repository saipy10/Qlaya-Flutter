import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() async {
  print('=== QLaya Quantized Models ===');
  for (final id in QLayaModels.allIds) {
    final spec = QLayaModels.all[id]!;
    print('- $id: ${spec.sizeMb} MB (p50: ${spec.latencyP50Ms} ms, RAM: ${spec.ramWorkingSetMb} MB) — ${spec.description}');
  }

  // Resolve model by exact key or fuzzy slug
  final model = QLayaModels.resolve('ultra-fast-edge');
  print('\nResolved model spec:');
  print('  Repo: ${model.repo}');
  print('  Subfolder: ${model.subfolder}');
  print('  Size: ${model.sizeMb} MB');
  print('  Latency: ${model.latencyP50Ms} ms');

  // Client usage against local server (qlaya-serve)
  final client = QLayaClient(baseUrl: 'http://localhost:8000');
  try {
    print('\nSending sample query to local server...');
    final result = await client.predict(
      text: 'I was charged twice, please refund',
      model: model,
    );
    print('Prediction answers: ${result.answers}');
  } catch (e) {
    print('Note: To run live prediction, start the server using `qlaya-serve` ($e)');
  } finally {
    client.close();
  }
}
