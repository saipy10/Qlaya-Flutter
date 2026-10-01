#!/usr/bin/env dart
/// Command-line tool to download the QLaya ONNX model from Hugging Face Hub.
///
/// Usage:
///   dart run qlaya_flutter:download [options]
///
/// Options:
///   -d, --dir <path>     Directory to save the model file (defaults to current directory)
///   -f, --force          Force re-download even if file already exists
///   -h, --help           Show this help message
import 'dart:io';
import 'package:qlaya_flutter/qlaya_flutter.dart';

Future<void> main(List<String> args) async {
  String? targetDir;
  bool force = false;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '-h' || arg == '--help') {
      _printUsage();
      exit(0);
    } else if (arg == '-f' || arg == '--force') {
      force = true;
    } else if (arg == '-d' || arg == '--dir') {
      if (i + 1 < args.length) {
        targetDir = args[++i];
      } else {
        stderr.writeln('Error: Missing value for $arg');
        exit(1);
      }
    } else if (arg.startsWith('--dir=')) {
      targetDir = arg.substring('--dir='.length);
    } else {
      stderr.writeln('Unknown option: $arg');
      _printUsage();
      exit(1);
    }
  }

  final model = QLayaModels.int8;
  final downloadUri = QLayaDownloader.getDownloadUri(model);
  final targetFile = QLayaDownloader.getModelFile(
    directory: targetDir,
    model: model,
  );

  print('========================================================');
  print('          QLaya Model Downloader (Hugging Face)         ');
  print('========================================================');
  print('Model Variant : ${model.id}');
  print('Repository    : ${model.repo}');
  print('Expected Size : ${model.sizeMb} MB');
  print('Source URL    : $downloadUri');
  print('Target Path   : ${targetFile.absolute.path}');
  print('--------------------------------------------------------');

  if (!force && targetFile.existsSync() && targetFile.lengthSync() > 1024 * 1024) {
    final sizeMb = (targetFile.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
    print('Model already exists at: ${targetFile.path} ($sizeMb MB)');
    print('Use --force (-f) to overwrite and re-download.');
    print('========================================================');
    exit(0);
  }

  print('Starting download from Hugging Face Hub...\n');

  var lastRenderedPercent = -1;
  final stopwatch = Stopwatch()..start();

  try {
    final file = await QLayaDownloader.download(
      model: model,
      destinationDir: targetDir,
      overwrite: force,
      onProgress: (progress) {
        if (progress.totalBytes <= 0) {
          stdout.write('\rDownloading: ${progress.receivedMb} MB received...');
          return;
        }

        final percent = progress.percent;
        if (percent != lastRenderedPercent) {
          lastRenderedPercent = percent;
          final barWidth = 30;
          final completedWidth = (progress.fraction * barWidth).round();
          final remainingWidth = barWidth - completedWidth;
          final bar = '=' * completedWidth + (remainingWidth > 0 ? '>' : '') + ' ' * (remainingWidth > 0 ? remainingWidth - 1 : 0);

          final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;
          final speedMbS = elapsedSec > 0
              ? (progress.bytesReceived / (1024 * 1024) / elapsedSec).toStringAsFixed(1)
              : '0.0';

          stdout.write(
            '\r[$bar] ${percent.toString().padLeft(3)}% '
            '(${progress.receivedMb} / ${progress.totalMb} MB) '
            '@ $speedMbS MB/s',
          );
        }
      },
    );

    stopwatch.stop();
    final totalSec = (stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(1);
    print('\n\nSuccessfully downloaded model in $totalSec seconds!');
    print('Saved to: ${file.absolute.path}');
    print('========================================================');
  } catch (e) {
    print('\nDownload failed: $e');
    exit(1);
  }
}

void _printUsage() {
  print('''
Usage:
  dart run qlaya_flutter:download [options]

Downloads the official QLaya ONNX model weights from Hugging Face.

Options:
  -d, --dir <path>     Directory to save the model file (default: current directory)
  -f, --force          Force re-download and overwrite existing file
  -h, --help           Show this help message

Examples:
  dart run qlaya_flutter:download
  dart run qlaya_flutter:download --dir=./assets/models
  dart run qlaya_flutter:download --force
''');
}
