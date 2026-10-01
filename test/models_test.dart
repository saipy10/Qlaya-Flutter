import 'dart:io';
import 'package:test/test.dart';
import 'package:qlaya_flutter/qlaya_flutter.dart';

void main() {
  group('QLayaModels (Bundled qlaya.int8.onnx)', () {
    test('contains only 1 model variant', () {
      expect(QLayaModels.all.length, equals(1));
      expect(QLayaModels.all.containsKey('qlaya.int8.onnx'), isTrue);
    });

    test('allIds contains only qlaya.int8.onnx', () {
      expect(QLayaModels.allIds, equals(['qlaya.int8.onnx']));
    });

    test('int8 and defaultModel are identical', () {
      expect(QLayaModels.defaultModel, equals(QLayaModels.int8));
      expect(QLayaModels.int8.id, equals('qlaya.int8.onnx'));
      expect(QLayaModels.int8.fileName, equals('qlaya.int8.onnx'));
      expect(QLayaModels.int8.repo, equals('saipy10/qlaya'));
      expect(QLayaModels.int8.subfolder, equals('qlaya-int8'));
      expect(QLayaModels.int8.sizeMb, equals(571.9));
      expect(QLayaModels.int8.latencyP50Ms, equals(134.7));
      expect(QLayaModels.int8.ramWorkingSetMb, equals(590));
      expect(QLayaModels.int8.assetPath, equals('qlaya.int8.onnx'));
    });

    test('resolve exact filename works', () {
      final spec = QLayaModels.resolve('qlaya.int8.onnx');
      expect(spec.fileName, equals('qlaya.int8.onnx'));
      expect(spec.subfolder, equals('qlaya-int8'));
    });

    test('resolve legacy aliases map to bundled int8 model', () {
      expect(QLayaModels.resolve('QLaya-TopProduction').fileName, equals('qlaya.int8.onnx'));
      expect(QLayaModels.resolve('qlaya-int8').fileName, equals('qlaya.int8.onnx'));
      expect(QLayaModels.resolve('int8').fileName, equals('qlaya.int8.onnx'));
      expect(QLayaModels.resolve('TOPPRODUCTION').fileName, equals('qlaya.int8.onnx'));
    });

    test('resolve throws ArgumentError for removed legacy models', () {
      final removedModels = [
        'QLaya-OriginalBaseline',
        'QLaya-Balanced',
        'QLaya-SlowCPU',
        'QLaya-DegradedAccuracy',
        'QLaya-IntermediateStudent',
        'QLaya-HighSpeedProduction',
        'QLaya-CompactStudent',
        'QLaya-UltraFastEdge',
        'QLaya-UltraSmallStorage',
        'non-existent-model',
      ];

      for (final modelId in removedModels) {
        expect(
          () => QLayaModels.resolve(modelId),
          throwsArgumentError,
          reason: '$modelId should be rejected because only qlaya.int8.onnx is supported',
        );
      }
    });

    test('bundled qlaya.int8.onnx file exists on disk with valid size', () {
      final file = File(QLayaModels.int8.fileName);
      expect(file.existsSync(), isTrue,
          reason: 'qlaya.int8.onnx must be present in the package');
      expect(file.lengthSync(), greaterThan(500 * 1024 * 1024),
          reason: 'qlaya.int8.onnx should be ~572 MB');
    });
  });
}
