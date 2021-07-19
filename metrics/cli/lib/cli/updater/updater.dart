// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/cli/updater/algorithm/update_algorithm.dart';
import 'package:cli/cli/updater/strings/update_strings.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/strings/common_strings.dart';
import 'package:cli/prompter/prompter.dart';
import 'package:cli/util/file/file_helper.dart';
import 'package:meta/meta.dart';

/// A class providing method for updating the deployed Metrics components.
class Updater {
  /// A class that provides an update algorithm.
  final UpdateAlgorithm _updateAlgorithm;

  /// A class that provides methods for working with the file system.
  final FileHelper _fileHelper;

  /// A [Prompter] class this updater uses to interact with a user.
  final Prompter _prompter;

  /// A [PathsFactory] class this updater uses to create the [Paths].
  final PathsFactory _pathsFactory;

  /// Creates a new instance of the [Updater] with the given services.
  ///
  /// Throws an [ArgumentError] if any of the given parameters is `null`.
  Updater({
    @required UpdateAlgorithm updateAlgorithm,
    @required FileHelper fileHelper,
    @required Prompter prompter,
    @required PathsFactory pathsFactory,
  })  : _updateAlgorithm = updateAlgorithm,
        _fileHelper = fileHelper,
        _prompter = prompter,
        _pathsFactory = pathsFactory {
    ArgumentError.checkNotNull(_updateAlgorithm, 'updateAlgorithm');
    ArgumentError.checkNotNull(_fileHelper, 'fileHelper');
    ArgumentError.checkNotNull(_prompter, 'prompter');
    ArgumentError.checkNotNull(_pathsFactory, 'pathsFactory');
  }

  /// Updates the deployed Metrics components using the given [config].
  ///
  /// Throws an [ArgumentError] if the given [config] is `null`.
  Future<void> update(UpdateConfig config) async {
    ArgumentError.checkNotNull(config, 'config');

    final tempDirectory = _createTempDirectory();
    final paths = _pathsFactory.create(tempDirectory.path);

    try {
      await _updateAlgorithm.start(config, paths);

      _prompter.info(UpdateStrings.successfulUpdating);
    } catch (error) {
      _prompter.error(UpdateStrings.failedUpdating(error));
    } finally {
      _prompter.info(CommonStrings.deletingTempDirectory);
      _deleteDirectory(tempDirectory);
    }
  }

  /// Creates a temporary directory in the current working directory.
  Directory _createTempDirectory() {
    final directory = Directory.current;

    return _fileHelper.createTempDirectory(
      directory,
      DeployConstants.tempDirectoryPrefix,
    );
  }

  /// Deletes the given [directory].
  void _deleteDirectory(Directory directory) {
    final directoryExist = directory.existsSync();

    if (!directoryExist) return;

    directory.deleteSync(recursive: true);
  }
}
