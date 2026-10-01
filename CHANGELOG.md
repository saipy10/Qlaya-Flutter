## 0.5.1

* **Interactive Flutter Example App**: Replaced CLI script in `example/main.dart` with a complete Material 3 Flutter application featuring interactive playgrounds for Classification, Urgency Scoring, Verification, and Workflow Routing.
* **Model Download UI**: Added live progress tracking for Hugging Face model downloads in the Flutter example.
* **Simplified Documentation**: Overhauled `README.md` to guide users step-by-step from installation to basic usage.
* **Cleaned API Interfaces**: Removed legacy server configuration requirements from docs and client descriptions.

## 0.5.0

* **Hugging Face Hub hosting**: Model weights are hosted on Hugging Face at [`saipy10/qlaya`](https://huggingface.co/saipy10/qlaya) with direct download support.
* **CLI Downloader**: Added `dart run qlaya_flutter:download` to download `qlaya.int8.onnx` directly from terminal with progress indicators and speed display.
* **Programmatic Downloader**: Added `QLayaDownloader` to verify, download, and ensure model availability directly within Flutter or Dart code.
* **Optimized package size**: Package published to pub.dev is lightweight (<20 KB) while weights are fetched on demand.
* **New Task API**: Added `QLayaTasks` and four typed task classes for common decision patterns:
  * `QLayaClassificationTask` / `client.classify()` — intent and category classification.
  * `QLayaScoreTask` / `client.score()` — continuous scoring and rating.
  * `QLayaBoolTask` / `client.verify()` — boolean verification.
  * `QLayaRoutingTask` / `client.route()` — workflow and destination routing.
* **`client.runTask(task)`**: Generic typed task runner for any `QLayaTask<T>`.
* **`QLayaModels.int8`** / **`QLayaModels.defaultModel`**: Model specification with Hugging Face repository and direct download link.
* **New result types**: `QLayaClassificationResult`, `QLayaScoreResult`, `QLayaBoolResult`, `QLayaRoutingResult`.
* Updated examples, tests, and documentation.

## 0.4.1


* Update package metadata and repository links to dedicated repository: [saipy10/Qlaya-Flutter](https://github.com/saipy10/Qlaya-Flutter).
* Add badges, repository documentation, and issue tracker links.

## 0.4.0

* Initial release of `qlaya_flutter` for Flutter and Dart.
* Complete model registry (`QLayaModels`) with 10 user-selectable quantized model variants (INT8, INT4, FP16, student distillations) hosted on Hugging Face at `saipy10/qlaya`.
* `QLayaClient` HTTP client for connecting to QLaya inference servers.
* Type definitions for `QLayaQuestion`, `QLayaAnswer`, `QLayaPrediction`, and `QLayaModelSpec`.
* Includes runnable example demonstrating model variant resolution.
