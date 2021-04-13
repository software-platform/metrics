// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/firebase/firebase_command.dart';
import 'package:cli/common/model/services.dart';
import 'package:cli/flutter/service/flutter_service.dart';
import 'package:cli/gcloud/service/gcloud_service.dart';
import 'package:cli/git/service/git_service.dart';
import 'package:cli/npm/service/npm_service.dart';

/// A class that provides an ability to check whether all required third-party
/// services are available and get their versions.
class Doctor {
  /// A service that provides methods for working with Flutter.
  final FlutterService _flutterService;

  /// A service that provides methods for working with GCloud.
  final GCloudService _gcloudService;

  /// A service that provides methods for working with Npm.
  final NpmService _npmService;

  /// A class that provides methods for working with the Git.
  final GitService _gitService;

  /// A class that provides methods for working with the Firebase.
  final FirebaseCommand _firebaseCommand;

  /// Creates a new instance of the [Doctor] with the given services.
  ///
  /// Throws an [ArgumentError] if the given [services] is `null`.
  /// Throws an [ArgumentError] if the given [Services.flutterService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gcloudService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.npmService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gitService] is `null`.
  /// Throws an [ArgumentError] if the given [firebaseCommand] is `null`.
  Doctor({
    Services services,
    FirebaseCommand firebaseCommand,
  })  : _flutterService = services?.flutterService,
        _gcloudService = services?.gcloudService,
        _npmService = services?.npmService,
        _gitService = services?.gitService,
        _firebaseCommand = firebaseCommand {
    ArgumentError.checkNotNull(services, 'services');
    ArgumentError.checkNotNull(_flutterService, 'flutterService');
    ArgumentError.checkNotNull(_gcloudService, 'gcloudService');
    ArgumentError.checkNotNull(_npmService, 'npmService');
    ArgumentError.checkNotNull(_gitService, 'gitService');
    ArgumentError.checkNotNull(_firebaseCommand, 'firebaseCommand');
  }

  /// Checks versions of the required third-party services.
  Future<void> checkVersions() async {
    await _checkVersion(_flutterService.version);
    await _checkVersion(_gcloudService.version);
    await _checkVersion(_npmService.version);
    await _checkVersion(_gitService.version);
    await _checkVersion(_firebaseCommand.version);
  }

  /// Checks version of the third-party service using the given
  /// [versionCallback].
  ///
  /// Catches all thrown exceptions to be able to proceed with checking the
  /// version of all the rest services.
  Future<void> _checkVersion(Future<void> Function() versionCallback) async {
    try {
      await versionCallback();
    } catch (_) {}
  }
}
