#!/usr/bin/env dart
/// QLaya CLI dispatcher.
import 'download.dart' as download_cli;

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == 'download') {
    final subArgs = args.isNotEmpty && args.first == 'download'
        ? args.sublist(1)
        : args;
    await download_cli.main(subArgs);
  } else if (args.first == '--help' || args.first == '-h') {
    print('''
QLaya CLI — Machine Learning Decision Engine Tooling

Available commands:
  download    Download the official qlaya.int8.onnx weights from Hugging Face Hub

Run `dart run qlaya_flutter <command> --help` for command-specific options.
''');
  } else {
    print('Unknown command: ${args.first}');
    print('Run `dart run qlaya_flutter --help` for available commands.');
  }
}
