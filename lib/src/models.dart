/// QLaya model registry — maps user-facing QLaya model IDs to HuggingFace
/// checkpoint specs (repo + subfolder).
///
/// All IDs are derived from the project's `benchmark_results.json` status field.
library;

/// A resolved HuggingFace checkpoint specification.
class QLayaModelSpec {
  /// HuggingFace repository ID (e.g. `saipy10/qlaya`).
  final String repo;

  /// Subfolder within the repo, or `null` for the root checkpoint.
  final String? subfolder;

  /// User-facing description of this model variant.
  final String description;

  /// Approximate model size in megabytes.
  final double sizeMb;

  /// Median inference latency in milliseconds (from benchmark).
  final double latencyP50Ms;

  /// RAM working set in megabytes (from benchmark).
  final int ramWorkingSetMb;

  const QLayaModelSpec({
    required this.repo,
    required this.subfolder,
    required this.description,
    required this.sizeMb,
    required this.latencyP50Ms,
    required this.ramWorkingSetMb,
  });
}

/// Registry of all QLaya quantized model variants.
///
/// Use [QLayaModels.resolve] to look up a variant by ID, or iterate
/// [QLayaModels.all] for UI picker lists.
abstract final class QLayaModels {
  static const String _bundleRepo = 'saipy10/qlaya';

  /// All available QLaya model variants, keyed by their QLaya ID.
  static const Map<String, QLayaModelSpec> all = {
    'QLaya-OriginalBaseline': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-fp32',
      description:
          'Uncompressed FP32 teacher — maximum accuracy, 1.7 GB RAM',
      sizeMb: 1685.2,
      latencyP50Ms: 382.4,
      ramWorkingSetMb: 1720,
    ),
    'QLaya-Balanced': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-fp16',
      description: 'Half-precision FP16/BF16 — 50 % smaller, identical accuracy',
      sizeMb: 842.6,
      latencyP50Ms: 368.0,
      ramWorkingSetMb: 860,
    ),
    'QLaya-TopProduction': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-int8',
      description:
          'ONNX INT8 per-channel — best latency/accuracy trade-off ⭐ recommended',
      sizeMb: 571.9,
      latencyP50Ms: 134.7,
      ramWorkingSetMb: 590,
    ),
    'QLaya-SlowCPU': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-int4-b32',
      description: 'ONNX INT4 block-32 — full accuracy but slow on CPU',
      sizeMb: 441.2,
      latencyP50Ms: 680.9,
      ramWorkingSetMb: 460,
    ),
    'QLaya-DegradedAccuracy': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-int4-b64',
      description: 'ONNX INT4 block-64 — smallest teacher, 75 % choice accuracy',
      sizeMb: 419.6,
      latencyP50Ms: 1047.6,
      ramWorkingSetMb: 435,
    ),
    'QLaya-IntermediateStudent': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-distil-14l-fp32',
      description: '14-layer distilled student FP32 — half the layers, full accuracy',
      sizeMb: 978.0,
      latencyP50Ms: 195.2,
      ramWorkingSetMb: 1010,
    ),
    'QLaya-HighSpeedProduction': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-distil-14l-int8',
      description:
          '14-layer distilled + INT8 — 80 % smaller than teacher, 78 ms latency',
      sizeMb: 332.5,
      latencyP50Ms: 78.4,
      ramWorkingSetMb: 350,
    ),
    'QLaya-CompactStudent': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-distil-6l-fp32',
      description: '6-layer compact student FP32 — 143 M params, 94 ms, 92 % accuracy',
      sizeMb: 573.6,
      latencyP50Ms: 94.0,
      ramWorkingSetMb: 605,
    ),
    'QLaya-UltraFastEdge': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-distil-6l-int8',
      description: '6-layer distilled + INT8 — 38.6 ms latency, 210 MB RAM, edge/mobile',
      sizeMb: 195.2,
      latencyP50Ms: 38.6,
      ramWorkingSetMb: 210,
    ),
    'QLaya-UltraSmallStorage': QLayaModelSpec(
      repo: _bundleRepo,
      subfolder: 'qlaya-distil-6l-int4',
      description:
          '6-layer distilled + INT4 — 91.6 % size reduction, only 142 MB',
      sizeMb: 142.1,
      latencyP50Ms: 112.5,
      ramWorkingSetMb: 160,
    ),
  };

  /// Sorted list of all QLaya model IDs for display/picker use.
  static List<String> get allIds => all.keys.toList()..sort();

  /// Resolve a QLaya model ID (exact or fuzzy, case-insensitive) to its [QLayaModelSpec].
  ///
  /// Throws [ArgumentError] with a helpful message if [modelId] is not found.
  ///
  /// Examples:
  /// ```dart
  /// QLayaModels.resolve('QLaya-TopProduction')  // exact
  /// QLayaModels.resolve('topproduction')        // fuzzy slug
  /// QLayaModels.resolve('ultra-fast-edge')      // fuzzy slug
  /// ```
  static QLayaModelSpec resolve(String modelId) {
    // Exact match
    if (all.containsKey(modelId)) return all[modelId]!;
    // Fuzzy: strip QLaya- prefix, lower, remove hyphens/underscores
    final slug = modelId.toLowerCase().replaceFirst('qlaya-', '').replaceAll(RegExp(r'[-_]'), '');
    for (final entry in all.entries) {
      final candidate = entry.key.toLowerCase().replaceFirst('qlaya-', '').replaceAll(RegExp(r'[-_]'), '');
      if (slug == candidate) return entry.value;
    }
    throw ArgumentError(
      'Unknown QLaya model "$modelId".\n'
      'Available variants:\n  ${allIds.join("\n  ")}',
    );
  }
}
