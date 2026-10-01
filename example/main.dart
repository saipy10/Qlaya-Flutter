import 'dart:io';
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() async {
  print('====================================================');
  print('   QLaya Flutter / Dart — Bundled ONNX Decision Engine');
  print('====================================================\n');

  // 1. Inspect the bundled model
  final model = QLayaModels.int8;
  print('Model Identifier : ${model.id}');
  print('Bundled File     : ${model.fileName}');
  print('HuggingFace Repo : ${model.repo} (${model.subfolder})');
  print('Model Size       : ${model.sizeMb} MB');
  print('Benchmark Latency: ${model.latencyP50Ms} ms (p50)');
  print('Working RAM      : ${model.ramWorkingSetMb} MB');

  // Verify local model existence or show Hugging Face download instructions
  final file = QLayaDownloader.getModelFile();
  if (file.existsSync()) {
    final sizeInMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
    print('Local File Status: Found on disk ($sizeInMb MB)\n');
  } else {
    print('Local File Status: Model not downloaded yet.');
    print('Download via CLI : dart run qlaya_flutter:download');
    print('Or direct URL    : ${model.downloadUrl}\n');
  }

  // 2. Initialize QLaya Client (uses qlaya.int8.onnx for inference)
  final client = QLayaClient(baseUrl: 'http://localhost:8000');

  try {
    print('--- Task 1: Intent Classification ---');
    final intent = await client.classify(
      text: 'I was charged twice on my invoice, please refund my money',
      choices: ['refund_request', 'subscription_cancel', 'tech_support', 'general_query'],
      instruction: 'Identify the primary intent of the user message',
    );
    print('Input   : "I was charged twice on my invoice, please refund my money"');
    print('Result  : ${intent.choice}');
    print('Confidence: ${intent.confidence ?? "N/A"}\n');

    print('--- Task 2: Urgency / Severity Scoring ---');
    final score = await client.score(
      text: 'CRITICAL: Database connection pool exhausted in production cluster!',
      instruction: 'Rate the urgency level from 0.0 (low) to 1.0 (emergency)',
    );
    print('Input   : "CRITICAL: Database connection pool exhausted in production cluster!"');
    print('Score   : ${score.score}');
    print('Confidence: ${score.confidence ?? "N/A"}\n');

    print('--- Task 3: Boolean Verification ---');
    final verification = await client.verify(
      text: 'The app crashes whenever I tap the profile icon',
      statement: 'User is reporting a bug or application failure',
    );
    print('Input   : "The app crashes whenever I tap the profile icon"');
    print('Decision: ${verification.value ? "TRUE" : "FALSE"}');
    print('Confidence: ${verification.confidence ?? "N/A"}\n');

    print('--- Task 4: Workflow Routing ---');
    final routing = await client.route(
      text: 'Need to add 15 new enterprise user seats for next quarter',
      routes: ['sales_enterprise', 'tier1_support', 'billing_ops', 'legal_compliance'],
      instruction: 'Route this inquiry to the appropriate department',
    );
    print('Input   : "Need to add 15 new enterprise user seats for next quarter"');
    print('Route To: ${routing.route}');
    print('Confidence: ${routing.confidence ?? "N/A"}\n');

    print('All tasks executed successfully with qlaya.int8.onnx!');
  } catch (e) {
    print('Note: Live task execution requires running `qlaya-serve` ($e)');
    print('Run `pip install qlaya[serve]` followed by `qlaya-serve --model qlaya.int8.onnx`');
  } finally {
    client.close();
  }
}
