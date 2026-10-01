/// QLaya model registry.
///
/// Bundles and uses the official `qlaya.int8.onnx` quantized model variant
/// for all classification, scoring, verification, and routing tasks.
library;

/// A resolved model specification for the bundled QLaya model.
class QLayaModelSpec {
  /// Unique identifier of this model variant.
  final String id;

  /// Bundled ONNX model file name.
  final String fileName;

  /// HuggingFace repository ID (e.g. `saipy10/qlaya`).
  final String repo;

  /// Subfolder within the repo (`qlaya-int8`).
  final String? subfolder;

  /// User-facing description of this model variant.
  final String description;

  /// Approximate model size in megabytes (~571.9 MB).
  final double sizeMb;

  /// Median inference latency in milliseconds (134.7 ms).
  final double latencyP50Ms;

  /// RAM working set in megabytes (590 MB).
  final int ramWorkingSetMb;

  /// Package asset path for Flutter applications.
  final String assetPath;

  const QLayaModelSpec({
    required this.id,
    required this.fileName,
    required this.repo,
    required this.subfolder,
    required this.description,
    required this.sizeMb,
    required this.latencyP50Ms,
    required this.ramWorkingSetMb,
    this.assetPath = 'qlaya.int8.onnx',
  });
}

/// Registry of QLaya models.
///
/// Bundles and exclusively uses `qlaya.int8.onnx` for all tasks.
abstract final class QLayaModels {
  static const String _bundleRepo = 'saipy10/qlaya';

  /// The official bundled ONNX INT8 per-channel quantized model.
  static const QLayaModelSpec int8 = QLayaModelSpec(
    id: 'qlaya.int8.onnx',
    fileName: 'qlaya.int8.onnx',
    repo: _bundleRepo,
    subfolder: 'qlaya-int8',
    description:
        'Bundled ONNX INT8 per-channel quantized model — best latency/accuracy trade-off for on-device decision tasks',
    sizeMb: 571.9,
    latencyP50Ms: 134.7,
    ramWorkingSetMb: 590,
    assetPath: 'qlaya.int8.onnx',
  );

  /// Default model used for all inference tasks.
  static const QLayaModelSpec defaultModel = int8;

  /// All available models in this package (only the bundled INT8 model).
  static const Map<String, QLayaModelSpec> all = {
    'qlaya.int8.onnx': int8,
  };

  /// List of model IDs available in this package.
  static List<String> get allIds => all.keys.toList();

  /// Resolve a model identifier (exact or fuzzy) to the bundled [QLayaModelSpec].
  ///
  /// Supports:
  /// - `'qlaya.int8.onnx'`
  /// - `'QLaya-TopProduction'`
  /// - `'qlaya-int8'`
  /// - `'int8'`
  ///
  /// All other legacy models have been removed from this package.
  /// Throws [ArgumentError] if an unknown or removed model is requested.
  static QLayaModelSpec resolve(String modelId) {
    final normalized = modelId.toLowerCase().trim();
    if (normalized == 'qlaya.int8.onnx' ||
        normalized == 'qlaya-topproduction' ||
        normalized == 'topproduction' ||
        normalized == 'qlaya-int8' ||
        normalized == 'qlaya_int8' ||
        normalized == 'int8') {
      return int8;
    }

    throw ArgumentError(
      'Unknown or unsupported QLaya model "$modelId".\n'
      'This package bundles and uses only "qlaya.int8.onnx" for all tasks.\n'
      'Available model:\n  ${allIds.join("\n  ")}',
    );
  }
}
