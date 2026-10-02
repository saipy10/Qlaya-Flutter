/// QLaya model downloader for fetching weights from Hugging Face Hub.
library;

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models.dart';

/// Progress information for an active model download.
class QLayaDownloadProgress {
  /// Total bytes received so far.
  final int bytesReceived;

  /// Total expected bytes, or -1 if unknown.
  final int totalBytes;

  const QLayaDownloadProgress({
    required this.bytesReceived,
    required this.totalBytes,
  });

  /// Fraction of download completed from 0.0 to 1.0.
  double get fraction =>
      totalBytes > 0 ? (bytesReceived / totalBytes).clamp(0.0, 1.0) : 0.0;

  /// Percentage completed (0 to 100).
  int get percent => (fraction * 100).round();

  /// Formatted received size in megabytes.
  String get receivedMb => (bytesReceived / (1024 * 1024)).toStringAsFixed(1);

  /// Formatted total size in megabytes.
  String get totalMb => totalBytes > 0
      ? (totalBytes / (1024 * 1024)).toStringAsFixed(1)
      : 'unknown';

  /// Whether the download has completed.
  bool get isDone => totalBytes > 0 && bytesReceived >= totalBytes;
}

/// Utility for downloading and managing QLaya ONNX model files.
///
/// Fetches official model weights directly from the Hugging Face Hub
/// repository (`https://huggingface.co/saipy10/qlaya`).
class QLayaDownloader {
  /// Default Hugging Face direct download base URL.
  static const String huggingFaceBaseUrl = 'https://huggingface.co';

  /// Resolves the direct download URL for a given model.
  static Uri getDownloadUri([QLayaModelSpec? model]) {
    final m = model ?? QLayaModels.int8;
    return Uri.parse(
        '$huggingFaceBaseUrl/${m.repo}/resolve/main/${m.fileName}');
  }

  /// Checks whether the model file is already present on local disk.
  static bool isModelAvailable({
    String? path,
    String? directory,
    QLayaModelSpec? model,
  }) {
    final file = _resolveTargetFile(
      path: path,
      directory: directory,
      model: model,
    );
    return file.existsSync() && file.lengthSync() > 1024 * 1024;
  }

  /// Gets the local [File] reference for the model.
  static File getModelFile({
    String? path,
    String? directory,
    QLayaModelSpec? model,
  }) =>
      _resolveTargetFile(
        path: path,
        directory: directory,
        model: model,
      );

  /// Downloads the specified model from Hugging Face Hub.
  ///
  /// - [model]: Model to download (defaults to [QLayaModels.int8]).
  /// - [destinationDir]: Target directory (defaults to current directory).
  /// - [destinationPath]: Full path to save file (overrides [destinationDir]).
  /// - [overwrite]: Whether to re-download if file already exists.
  /// - [onProgress]: Optional callback invoked as chunks are received.
  /// - [httpClient]: Optional custom HTTP client.
  static Future<File> download({
    QLayaModelSpec? model,
    String? destinationDir,
    String? destinationPath,
    bool overwrite = false,
    void Function(QLayaDownloadProgress progress)? onProgress,
    http.Client? httpClient,
  }) async {
    final spec = model ?? QLayaModels.int8;
    final targetFile = _resolveTargetFile(
      path: destinationPath,
      directory: destinationDir,
      model: spec,
    );

    if (!overwrite &&
        targetFile.existsSync() &&
        targetFile.lengthSync() > 1024 * 1024) {
      final total = targetFile.lengthSync();
      onProgress?.call(
        QLayaDownloadProgress(bytesReceived: total, totalBytes: total),
      );
      return targetFile;
    }

    // Ensure parent directory exists
    if (!targetFile.parent.existsSync()) {
      targetFile.parent.createSync(recursive: true);
    }

    final downloadUri = getDownloadUri(spec);
    final client = httpClient ?? http.Client();
    final tempFile = File('${targetFile.path}.download.tmp');

    try {
      final request = http.Request('GET', downloadUri);
      final response = await client.send(request);

      if (response.statusCode >= 300 && response.statusCode < 400) {
        // Follow redirect if not handled automatically
        final redirectLocation = response.headers['location'];
        if (redirectLocation != null) {
          final redirectedUri = Uri.parse(redirectLocation);
          final redirectReq = http.Request('GET', redirectedUri);
          final redirectResp = await client.send(redirectReq);
          if (redirectResp.statusCode != 200) {
            throw HttpException(
              'Failed to download model from Hugging Face (${redirectResp.statusCode}): $downloadUri',
              uri: downloadUri,
            );
          }
          await _writeStreamToFile(redirectResp, tempFile, onProgress);
        } else {
          throw HttpException('Redirect without location header',
              uri: downloadUri);
        }
      } else if (response.statusCode != 200) {
        throw HttpException(
          'Failed to download model from Hugging Face (${response.statusCode}): $downloadUri',
          uri: downloadUri,
        );
      } else {
        await _writeStreamToFile(response, tempFile, onProgress);
      }

      // Rename temp file to target file atomically
      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }
      tempFile.renameSync(targetFile.path);

      return targetFile;
    } catch (e) {
      if (tempFile.existsSync()) {
        try {
          tempFile.deleteSync();
        } catch (_) {}
      }
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }

  /// Ensures the model is downloaded and ready to use.
  ///
  /// If already downloaded, returns the existing [File] immediately.
  /// Otherwise, downloads it from Hugging Face.
  static Future<File> ensureModel({
    String? directory,
    String? path,
    QLayaModelSpec? model,
    void Function(QLayaDownloadProgress progress)? onProgress,
  }) async {
    final spec = model ?? QLayaModels.int8;
    if (isModelAvailable(path: path, directory: directory, model: spec)) {
      final file =
          _resolveTargetFile(path: path, directory: directory, model: spec);
      onProgress?.call(
        QLayaDownloadProgress(
          bytesReceived: file.lengthSync(),
          totalBytes: file.lengthSync(),
        ),
      );
      return file;
    }

    return download(
      model: spec,
      destinationDir: directory,
      destinationPath: path,
      onProgress: onProgress,
    );
  }

  static Future<void> _writeStreamToFile(
    http.StreamedResponse response,
    File file,
    void Function(QLayaDownloadProgress progress)? onProgress,
  ) async {
    final totalBytes = response.contentLength ?? -1;
    var bytesReceived = 0;
    final sink = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytesReceived += chunk.length;
        onProgress?.call(
          QLayaDownloadProgress(
            bytesReceived: bytesReceived,
            totalBytes: totalBytes,
          ),
        );
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  static File _resolveTargetFile({
    String? path,
    String? directory,
    QLayaModelSpec? model,
  }) {
    if (path != null && path.isNotEmpty) {
      return File(path);
    }
    final fileName = model?.fileName ?? QLayaModels.int8.fileName;
    if (directory != null && directory.isNotEmpty) {
      final sep = Platform.pathSeparator;
      final cleanDir = directory.endsWith(sep)
          ? directory.substring(0, directory.length - 1)
          : directory;
      return File('$cleanDir$sep$fileName');
    }
    return File(fileName);
  }
}
