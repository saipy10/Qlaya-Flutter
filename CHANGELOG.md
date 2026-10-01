## 0.5.0

**Breaking change** — consolidated to a single bundled model.

* **Bundle `qlaya.int8.onnx`**: The ONNX INT8 per-channel quantized model is now shipped directly with the package (~572 MB, ~135 ms p50 latency, ~590 MB RAM). No external download required.
* **Removed all other model variants**: `QLaya-OriginalBaseline`, `QLaya-Balanced`, `QLaya-SlowCPU`, `QLaya-DegradedAccuracy`, `QLaya-IntermediateStudent`, `QLaya-HighSpeedProduction`, `QLaya-CompactStudent`, `QLaya-UltraFastEdge`, `QLaya-UltraSmallStorage` are no longer available.
* **New Task API**: Added `QLayaTasks` and four typed task classes for common decision patterns:
  * `QLayaClassificationTask` / `client.classify()` — intent and category classification.
  * `QLayaScoreTask` / `client.score()` — continuous scoring and rating.
  * `QLayaBoolTask` / `client.verify()` — boolean verification.
  * `QLayaRoutingTask` / `client.route()` — workflow and destination routing.
* **`client.runTask(task)`**: Generic typed task runner for any `QLayaTask<T>`.
* **`QLayaModels.int8`** / **`QLayaModels.defaultModel`**: Static references to the single bundled model spec.
* **`QLayaModels.resolve()`**: Still supports fuzzy aliases (`qlaya.int8.onnx`, `QLaya-TopProduction`, `qlaya-int8`, `int8`); throws `ArgumentError` for removed variants.
* **New result types**: `QLayaClassificationResult`, `QLayaScoreResult`, `QLayaBoolResult`, `QLayaRoutingResult`.
* Flutter asset configured automatically — add `packages/qlaya_flutter/qlaya.int8.onnx` to your app's `flutter.assets`.
* Updated example and README to reflect bundled model and task API.
* Git LFS tracking configured for `*.onnx` via `.gitattributes`.

## 0.4.1


* Update package metadata and repository links to dedicated repository: [saipy10/Qlaya-Flutter](https://github.com/saipy10/Qlaya-Flutter).
* Add badges, repository documentation, and issue tracker links.

## 0.4.0

* Initial release of `qlaya_flutter` for Flutter and Dart.
* Complete model registry (`QLayaModels`) with 10 user-selectable quantized model variants (INT8, INT4, FP16, student distillations) hosted on Hugging Face at `saipy10/qlaya`.
* `QLayaClient` HTTP client for connecting to QLaya inference servers.
* Type definitions for `QLayaQuestion`, `QLayaAnswer`, `QLayaPrediction`, and `QLayaModelSpec`.
* Includes runnable example demonstrating model variant resolution.
