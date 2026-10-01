# qlaya_flutter

[![pub package](https://img.shields.io/pub/v/qlaya_flutter.svg)](https://pub.dev/packages/qlaya_flutter)
[![Hugging Face](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-saipy10%2Fqlaya-yellow)](https://huggingface.co/saipy10/qlaya)
[![GitHub](https://img.shields.io/badge/GitHub-saipy10%2FQlaya--Flutter-blue?logo=github)](https://github.com/saipy10/Qlaya-Flutter)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

**QLaya Flutter** — Fast, local, on-device decision engine client for Flutter and Dart, powered by the **`qlaya.int8.onnx`** quantized model hosted on Hugging Face Hub.

[Hugging Face Model](https://huggingface.co/saipy10/qlaya) | [GitHub Repository](https://github.com/saipy10/Qlaya-Flutter) | [pub.dev Package](https://pub.dev/packages/qlaya_flutter) | [Issues & Feedback](https://github.com/saipy10/Qlaya-Flutter/issues)

---

## Model Specifications

The official quantized model weights are hosted on Hugging Face Hub at [**`saipy10/qlaya`**](https://huggingface.co/saipy10/qlaya):

- **Model File**: `qlaya.int8.onnx` (~571.9 MB)
- **Quantization**: ONNX INT8 per-channel
- **Latency (p50)**: ~134.7 ms
- **RAM Working Set**: ~590 MB
- **Direct Download URL**: `https://huggingface.co/saipy10/qlaya/resolve/main/qlaya.int8.onnx`
- **Capabilities**: Fast on-device classification, continuous scoring, boolean verification, and workflow routing.

---

## Installation

Add to your Flutter or Dart project:

```sh
flutter pub add qlaya_flutter
# or for Dart CLI / server apps:
dart pub add qlaya_flutter
```

---

## Downloading the Model

You can obtain the model weights either via a command or directly within your code:

### 1. Download via CLI Command

Run the built-in downloader to fetch `qlaya.int8.onnx` from Hugging Face into your current directory or custom path:

```sh
# Download into current directory
dart run qlaya_flutter:download

# Or specify a custom target directory
dart run qlaya_flutter:download --dir=./models

# Force re-download
dart run qlaya_flutter:download --force
```

### 2. Download / Ensure Programmatically in Dart / Flutter

You can also ensure the model exists or download it on-the-fly directly inside your app:

```dart
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() async {
  // Check if model is already downloaded
  if (!QLayaDownloader.isModelAvailable()) {
    print('Downloading model weights from Hugging Face...');
    await QLayaDownloader.download(
      onProgress: (p) {
        print('${p.percent}% (${p.receivedMb} / ${p.totalMb} MB)');
      },
    );
  }
}
```

---

## Inference Usage

Use `QLayaClient` to run type-safe decision tasks:

```dart
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() async {
  // Connects to local server (defaults to http://localhost:8000)
  final client = QLayaClient();

  // Task 1: Intent Classification
  final intent = await client.classify(
    text: 'I was charged twice, please refund',
    choices: ['refund_request', 'subscription_cancel', 'tech_support'],
  );
  print('Classified Choice: ${intent.choice}');

  // Task 2: Continuous Scoring / Rating
  final urgency = await client.score(
    text: 'CRITICAL: Database connection timeout in production!',
    instruction: 'Rate urgency from 0.0 (low) to 1.0 (emergency)',
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
    text: 'Need to add 15 enterprise seats for next quarter',
    routes: ['sales_enterprise', 'tier1_support', 'billing_ops'],
  );
  print('Route To: ${routing.route}');

  client.close();
}
```

---

## Running the Inference Server

Start the local QLaya engine server using the downloaded ONNX model:

```sh
pip install qlaya[serve]
qlaya-serve --model qlaya.int8.onnx --port 8000
```

---

## License

Apache-2.0 — see [LICENSE](LICENSE).
