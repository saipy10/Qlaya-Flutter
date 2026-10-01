# qlaya_flutter

[![pub package](https://img.shields.io/pub/v/qlaya_flutter.svg)](https://pub.dev/packages/qlaya_flutter)
[![Hugging Face](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-saipy10%2Fqlaya-yellow)](https://huggingface.co/saipy10/qlaya)
[![GitHub](https://img.shields.io/badge/GitHub-saipy10%2FQlaya--Flutter-blue?logo=github)](https://github.com/saipy10/Qlaya-Flutter)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/saipy10/Qlaya-Flutter/main/cover.png" alt="QLaya Flutter" width="100%" />
</p>

**QLaya Flutter** is a fast, type-safe Flutter & Dart client for the QLaya on-device decision engine, powered by the **`qlaya.int8.onnx`** model hosted on Hugging Face Hub.

It enables intelligent, low-latency decision making directly inside your Flutter and Dart applications:
* 🎯 **Intent & Category Classification** — Map user inputs to target categories
* ⚡ **Continuous Scoring** — Evaluate severity, urgency, or sentiment on a 0.0 to 1.0 scale
* ✅ **Boolean Verification** — Validate hypotheses and statements against input text
* 🔀 **Workflow Routing** — Automatically route requests and inquiries to appropriate handlers

---

## Installation

Add `qlaya_flutter` to your project dependencies:

```sh
flutter pub add qlaya_flutter
```

Or for pure Dart applications:

```sh
dart pub add qlaya_flutter
```

---

## Model Download

The official quantized model (`qlaya.int8.onnx`, ~571.9 MB) is hosted on Hugging Face Hub at [**saipy10/qlaya**](https://huggingface.co/saipy10/qlaya).

You can download it using either the command line or directly inside your Dart/Flutter code:

### Option A: Download via Command Line

Run the built-in downloader to save the model to your project:

```sh
# Downloads qlaya.int8.onnx to the current directory
dart run qlaya_flutter:download

# Or specify a target directory
dart run qlaya_flutter:download --dir=./models
```

### Option B: Download Programmatically in Flutter

You can verify and download the model weights on-demand with progress updates:

```dart
import 'package:qlaya_flutter/qlaya_flutter.dart';

Future<void> initModel() async {
  // Checks local presence and downloads from Hugging Face if missing
  await QLayaDownloader.ensureModel(
    onProgress: (progress) {
      print('Downloading: ${progress.percent}% (${progress.receivedMb} / ${progress.totalMb} MB)');
    },
  );
}
```

---

## Basic Usage

### 1. Initialize Client

```dart
import 'package:qlaya_flutter/qlaya_flutter.dart';

final client = QLayaClient(); // Uses default endpoint or custom baseUrl
```

### 2. Intent Classification

Classify input text into one of several predefined choices:

```dart
final result = await client.classify(
  text: 'I was charged twice on my monthly invoice, please refund my money',
  choices: ['refund_request', 'subscription_cancel', 'tech_support', 'billing_ops'],
);

print('Choice: ${result.choice}');
print('Confidence: ${result.confidence}');
```

### 3. Continuous Scoring / Rating

Rate the urgency, priority, or severity of an incident on a 0.0 to 1.0 scale:

```dart
final urgency = await client.score(
  text: 'CRITICAL: Database connection pool completely exhausted in production!',
  instruction: 'Rate the urgency level from 0.0 (low) to 1.0 (emergency)',
);

print('Urgency Score: ${urgency.score}');
```

### 4. Boolean Verification

Verify whether a condition or hypothesis holds true for the input:

```dart
final verification = await client.verify(
  text: 'The application crashes immediately whenever I tap my profile picture',
  statement: 'User is reporting a software bug',
);

print('Verified: ${verification.value}'); // true
```

### 5. Workflow Routing

Route customer requests or messages to the appropriate team or service:

```dart
final routing = await client.route(
  text: 'We need to upgrade our plan to 25 enterprise user seats for next quarter',
  routes: ['sales_enterprise', 'tier1_support', 'billing_ops', 'legal_compliance'],
);

print('Target Route: ${routing.route}');
```

### 6. Clean Up Resources

```dart
client.close();
```

---

## Interactive Flutter Example

This package includes a full Material 3 Flutter application in the [`example/`](example/) directory demonstrating all four decision tasks and model download management:

To run the example app:

```sh
cd example
flutter run
```

---

## Model Specifications

| Parameter | Specification |
| :--- | :--- |
| **Model Variant** | `qlaya.int8.onnx` |
| **Host Repository** | [Hugging Face (`saipy10/qlaya`)](https://huggingface.co/saipy10/qlaya) |
| **Direct Download** | `https://huggingface.co/saipy10/qlaya/resolve/main/qlaya.int8.onnx` |
| **Quantization** | INT8 per-channel |
| **Latency (p50)** | ~134.7 ms |
| **RAM Working Set**| ~590 MB |
| **Model Size** | ~571.9 MB |

---

## License

Apache-2.0 — see [LICENSE](LICENSE) for details.
