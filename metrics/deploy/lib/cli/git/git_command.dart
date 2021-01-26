import 'dart:io';

import 'package:process_run/process_run.dart' as cmd;

/// A wrapper class for the Git CLI.
class GitCommand {
  /// Clones the git repository from the given [repoURL] to the given [srcPath].
  Future<void> clone(String repoURL, String srcPath) async {
    await cmd.run(
      'git',
      ['clone', repoURL, srcPath],
      verbose: true,
      stdin: stdin,
    );
  }

  /// Prints CLI version.
  Future<void> version() async {
    await cmd.run('git', ['--version'], verbose: true, stdin: stdin);
  }
}
