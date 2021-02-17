// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:links_checker/arguments/models/links_checker_arguments.dart';

/// A class that provides methods for registering
/// and parsing the [LinksCheckerArguments].
class LinksCheckerArgumentsParser {
  /// A name of the paths argument.
  static const String paths = 'paths';

  /// A name of the ignore argument.
  static const String ignore = 'ignore';

  /// Creates a new instance of the [LinksCheckerArgumentsParser].
  const LinksCheckerArgumentsParser();

  /// Configures the given [argParser] to accept the required arguments.
  void configureArguments(ArgParser argParser) {
    argParser.addOption(
      paths,
      help: 'A string representing the space-separated '
          'paths to files to analyze.',
      valueHelp: "'file1 path/to/file2 another/path/to/file3'",
      abbr: 'p',
      defaultsTo: '',
    );

    argParser.addOption(
      ignore,
      help: 'A string representing the space-separated '
          'paths which should be excluded from analyze.',
      valueHelp: "'.folder/ path/to/folder/ file.ext'",
      abbr: 'i',
      defaultsTo: '',
    );
  }

  /// Parses the [argResults] to the [LinksCheckerArguments] object.
  LinksCheckerArguments parseArgResults(ArgResults argResults) {
    final pathsList = _getArguments(argResults, paths);
    final ignoreList = _getArguments(argResults, ignore);

    return LinksCheckerArguments(paths: pathsList, ignorePaths: ignoreList);
  }

  /// Retrieves arguments for the given [option] from the given [argResults].
  List<String> _getArguments(ArgResults argResults, String option) {
    final argument = argResults[option] as String;

    return argument.split(' ').where((path) => path.isNotEmpty).toList();
  }
}
