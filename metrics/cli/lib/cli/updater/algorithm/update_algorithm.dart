// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/sentry_config.dart';
import 'package:cli/common/model/config/sentry_web_config.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:cli/common/model/config/web_metrics_config.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:cli/services/firebase/firebase_service.dart';
import 'package:cli/services/flutter/flutter_service.dart';
import 'package:cli/services/git/git_service.dart';
import 'package:cli/services/npm/npm_service.dart';
import 'package:cli/services/sentry/model/sentry_project.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:cli/services/sentry/model/source_map.dart';
import 'package:cli/services/sentry/sentry_service.dart';
import 'package:cli/util/file/file_helper.dart';
import 'package:meta/meta.dart';

/// A class providing algorithm for updating the deployed components.
class UpdateAlgorithm {
  /// A service that provides methods for working with Flutter.
  final FlutterService _flutterService;

  /// A service that provides methods for working with Npm.
  final NpmService _npmService;

  /// A class that provides methods for working with the Git.
  final GitService _gitService;

  /// A class that provides methods for working with the Firebase.
  final FirebaseService _firebaseService;

  /// A class that provides methods for working with the Sentry.
  final SentryService _sentryService;

  /// A class that provides methods for working with the file system.
  final FileHelper _fileHelper;

  /// Creates a new instance of the [UpdateAlgorithm] with the given services.
  ///
  /// Throws an [ArgumentError] if the given [services] is `null`.
  /// Throws an [ArgumentError] if the given [fileHelper] is `null`.
  UpdateAlgorithm({
    @required Services services,
    @required FileHelper fileHelper,
  })  : _gitService = services?.gitService,
        _npmService = services?.npmService,
        _flutterService = services?.flutterService,
        _sentryService = services?.sentryService,
        _firebaseService = services?.firebaseService,
        _fileHelper = fileHelper {
    ArgumentError.checkNotNull(services, 'services');
    ArgumentError.checkNotNull(_fileHelper, 'fileHelper');
  }

  /// Starts the updating of the deployed Metrics components using the
  /// given [config] and [paths].
  ///
  /// Throws an [ArgumentError] if the given [config] is `null`.
  /// Throws an [ArgumentError] if the given [paths] is `null`.
  Future<void> start(UpdateConfig config, Paths paths) async {
    ArgumentError.checkNotNull(config, 'config');
    ArgumentError.checkNotNull(paths, 'paths');

    await _gitService.checkout(DeployConstants.repoUrl, paths.rootPath);
    await _installNpmDependencies(
      paths.firebasePath,
      paths.firebaseFunctionsPath,
    );
    await _flutterService.build(paths.webAppPath);

    final firebaseConfig = config.firebaseConfig;

    final sentryWebConfig = await _setupSentry(
      config.sentryConfig,
      paths.webAppPath,
      paths.webAppBuildPath,
    );
    final metricsConfig = WebMetricsConfig(
      googleSignInClientId: firebaseConfig.googleSignInClientId,
      sentryWebConfig: sentryWebConfig,
    );

    _applyMetricsConfig(metricsConfig, paths.metricsConfigPath);
    _firebaseService.initializeAuth(firebaseConfig.authToken);

    try {
      await _deployToFirebase(
        firebaseConfig.projectId,
        paths.firebasePath,
        paths.webAppPath,
      );
    } finally {
      _firebaseService.resetAuth();
    }
  }

  /// Installs npm dependencies within the given [firebasePath] and
  /// the [functionsPath].
  Future<void> _installNpmDependencies(
    String firebasePath,
    String functionsPath,
  ) async {
    await _npmService.installDependencies(firebasePath);
    await _npmService.installDependencies(functionsPath);
  }

  /// Sets up a Sentry for the application under deployment within
  /// the given [webPath] and the [buildWebPath].
  Future<SentryWebConfig> _setupSentry(
    SentryConfig config,
    String webPath,
    String buildWebPath,
  ) async {
    if (config == null) return null;

    final release = config.releaseName;
    final sentryProject = SentryProject(
      organizationSlug: config.organizationSlug,
      projectSlug: config.projectSlug,
    );
    final sentryRelease = SentryRelease(
      name: release,
      project: sentryProject,
    );

    _sentryService.initializeAuth(config.authToken);

    try {
      await _createSentryRelease(
        sentryRelease,
        webPath,
        buildWebPath,
      );
    } finally {
      _sentryService.resetAuth();
    }

    return SentryWebConfig(
      release: release,
      dsn: config.projectDsn,
      environment: DeployConstants.sentryEnvironment,
    );
  }

  /// Creates a new Sentry release using the given [release] within
  /// the [webPath] and the [buildWebPath].
  Future<void> _createSentryRelease(
    SentryRelease release,
    String webPath,
    String buildWebPath,
  ) async {
    final webSourceMap = SourceMap(
      path: webPath,
      extensions: const ['dart'],
    );
    final buildSourceMap = SourceMap(
      path: buildWebPath,
      extensions: const ['map', 'js'],
    );

    return _sentryService.createRelease(
      release,
      [webSourceMap, buildSourceMap],
    );
  }

  /// Applies the given [config] to the Metrics configuration file within
  /// the given [metricsConfigPath].
  void _applyMetricsConfig(WebMetricsConfig config, String metricsConfigPath) {
    final configFile = _fileHelper.getFile(metricsConfigPath);

    _fileHelper.replaceEnvironmentVariables(configFile, config.toMap());
  }

  /// Deploys Firebase components and application to the Firebase project
  /// with the given [projectId] within the given [firebasePath] and
  /// the [webPath].
  Future<void> _deployToFirebase(
    String projectId,
    String firebasePath,
    String webPath,
  ) async {
    await _firebaseService.deployFirebase(projectId, firebasePath);
    await _firebaseService.deployHosting(
      projectId,
      DeployConstants.firebaseTarget,
      webPath,
    );
  }
}
