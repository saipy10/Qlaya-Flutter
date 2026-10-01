# qlaya_flutter

[![pub package](https://img.shields.io/pub/v/qlaya_flutter.svg)](https://pub.dev/packages/qlaya_flutter)
[![GitHub](https://img.shields.io/badge/GitHub-saipy10%2FQlaya--Flutter-blue?logo=github)](https://github.com/saipy10/Qlaya-Flutter)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

**QLaya Flutter** — Fast, local, on-device decision engine for Flutter and Dart, powered exclusively by the bundled **`qlaya.int8.onnx`** quantized model.

[GitHub Repository](https://github.com/saipy10/Qlaya-Flutter) | [pub.dev Package](https://pub.dev/packages/qlaya_flutter) | [Issues & Feedback](https://github.com/saipy10/Qlaya-Flutter/issues) | [Main QLaya Engine](https://github.com/saipy10/QLaya)

## Bundled Model

When you download or add `qlaya_flutter`, the **`qlaya.int8.onnx`** model file is bundled with the package:

- **Model File**: `qlaya.int8.onnx` (~571.9 MB)
- **Quantization**: ONNX INT8 per-channel
- **Latency (p50)**: ~134.7 ms
- **RAM Working Set**: ~590 MB
- **Architecture**: Single, production-tuned model variant handling all classification, scoring, verification, and routing tasks.

## Installation

Add to your Flutter or Dart project:

```sh
flutter pub add qlaya_flutter
# or for Dart CLI / server apps:
dart pub add qlaya_flutter
```

Or add to your `pubspec.yaml`:

```yaml
dependencies:
  qlaya_flutter: ^0.4.1

flutter:
  assets:
    - packages/qlaya_flutter/qlaya.int8.onnx
```

## Quick Start & Tasks

All tasks run with the bundled `qlaya.int8.onnx` model automatically:

```dart
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() async {
  final client = QLayaClient(baseUrl: 'http://localhost:8000');

  // Task 1: Intent Classification
  final intent = await client.classify(
    text: 'I was charged twice, please refund',
    choices: ['refund_request', 'subscription_cancel', 'tech_support'],
  );
  print('Classified Choice: ${intent.choice}');

  // Task 2: Continuous Scoring / Rating
  final urgency = await client.score(
    text: 'CRITICAL: Database offline!',
    instruction: 'Rate urgency from 0.0 to 1.0',
  );
  print('Urgency Score: ${urgency.score}');

  // Task 3: Boolean Verification
  final isComplaint = await client.verify(
    text: 'Product stopped working after 2 days.',
    statement: 'Customer is filing a complaint',
  );
  print('Is Complaint: ${isComplaint.value}');

  // Task 4: Workflow Routing
  final routing = await client.route(
    text: 'Need to add 15 enterprise seats',
    routes: ['sales_enterprise', 'tier1_support', 'billing_ops'],
  );
  print('Route To: ${routing.route}');

  client.close();
}
```

## Running the Server

Start the local QLaya engine server using the bundled model:

```sh
pip install qlaya[serve]
qlaya-serve --model qlaya.int8.onnx --port 8000
```

## License

Apache-2.0 — see [LICENSE](LICENSE).
