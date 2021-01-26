import 'dart:io';

import 'package:process_run/process_run.dart' as cmd;

/// A wrapper class for the Flutter CLI.
class FlutterCommand {
  /// Prints CLI version.
  Future<void> version() async {
    await cmd.run('flutter', ['--version'], verbose: true, stdin: stdin);
  }

  /// Enables Web support for the Flutter.
  Future<void> enableWeb() async {
    await cmd.run(
      'flutter',
      ['config', '--enable-web'],
      verbose: true,
      stdin: stdin,
    );
  }

  /// Builds Flutter Web project.
  Future<void> buildWeb(String workingDir) async {
    await cmd.run(
      'flutter',
      ['build', 'web'],
      workingDirectory: workingDir,
      verbose: true,
      stdin: stdin,
    );
  }
}
