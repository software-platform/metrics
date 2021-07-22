// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metrics/analytics/data/repositories/firebase_analytics_repository.dart';
import 'package:metrics/analytics/domain/usecases/log_login_use_case.dart';
import 'package:metrics/analytics/domain/usecases/log_page_view_use_case.dart';
import 'package:metrics/analytics/domain/usecases/reset_user_use_case.dart';
import 'package:metrics/analytics/presentation/state/analytics_notifier.dart';
import 'package:metrics/auth/data/repositories/firebase_user_repository.dart';
import 'package:metrics/auth/domain/usecases/create_user_profile_usecase.dart';
import 'package:metrics/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:metrics/auth/domain/usecases/receive_authentication_updates.dart';
import 'package:metrics/auth/domain/usecases/receive_user_profile_updates.dart';
import 'package:metrics/auth/domain/usecases/sign_in_usecase.dart';
import 'package:metrics/auth/domain/usecases/sign_out_usecase.dart';
import 'package:metrics/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:metrics/auth/presentation/models/user_profile_model.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/common/data/repositories/firestore_build_day_repository.dart';
import 'package:metrics/common/data/repositories/firestore_project_repository.dart';
import 'package:metrics/common/domain/usecases/receive_project_updates.dart';
import 'package:metrics/common/presentation/metrics_theme/state/theme_notifier.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_factory.dart';
import 'package:metrics/common/presentation/navigation/models/factory/page_parameters_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/metrics_page_route_configuration_factory.dart';
import 'package:metrics/common/presentation/navigation/state/navigation_notifier.dart';
import 'package:metrics/common/presentation/state/projects_notifier.dart';
import 'package:metrics/dashboard/data/repositories/firestore_metrics_repository.dart';
import 'package:metrics/dashboard/domain/usecases/receive_build_day_project_metrics_updates.dart';
import 'package:metrics/dashboard/domain/usecases/receive_project_metrics_updates.dart';
import 'package:metrics/dashboard/presentation/state/project_metrics_notifier.dart';
import 'package:metrics/dashboard/presentation/state/timer_notifier.dart';
import 'package:metrics/debug_menu/data/repositories/hive_local_config_repository.dart';
import 'package:metrics/debug_menu/domain/usecases/close_local_config_storage_usecase.dart';
import 'package:metrics/debug_menu/domain/usecases/open_local_config_storage_usecase.dart';
import 'package:metrics/debug_menu/domain/usecases/read_local_config_usecase.dart';
import 'package:metrics/debug_menu/domain/usecases/update_local_config_usecase.dart';
import 'package:metrics/debug_menu/presentation/state/debug_menu_notifier.dart';
import 'package:metrics/feature_config/data/repositories/firestore_feature_config_repository.dart';
import 'package:metrics/feature_config/domain/usecases/fetch_feature_config_usecase.dart';
import 'package:metrics/feature_config/presentation/state/feature_config_notifier.dart';
import 'package:metrics/platform/web/browser_navigation_state/browser_navigation_state.dart';
import 'package:metrics/project_groups/data/repositories/firestore_project_group_repository.dart';
import 'package:metrics/project_groups/domain/usecases/add_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/delete_project_group_usecase.dart';
import 'package:metrics/project_groups/domain/usecases/receive_project_group_updates.dart';
import 'package:metrics/project_groups/domain/usecases/update_project_group_usecase.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart';

/// Creates the [ChangeNotifier]s and injects them, using the [MultiProvider] widget.
class InjectionContainer extends StatefulWidget {
  /// A child widget to display.
  final Widget child;

  /// A [MetricsConfig] instance that is used to initialize components
  /// this container injects.
  final MetricsConfig metricsConfig;

  /// Creates the [InjectionContainer].
  ///
  /// The [child] must not be null.
  const InjectionContainer({
    Key key,
    @required this.child,
    @required this.metricsConfig,
  })  : assert(child != null),
        assert(metricsConfig != null),
        super(key: key);

  @override
  _InjectionContainerState createState() => _InjectionContainerState();
}

class _InjectionContainerState extends State<InjectionContainer> {
  /// A use case needed to be able to sign in a user.
  SignInUseCase _signInUseCase;

  /// A use case needed to be able to sign in a user with Google.
  GoogleSignInUseCase _googleSignInUseCase;

  /// A use case needed to be able to sign out a user.
  SignOutUseCase _signOutUseCase;

  /// A use case needed to receive the authentication updates.
  ReceiveAuthenticationUpdates _receiveAuthUpdates;

  /// A use case needed to be able to receive the user profile updates.
  ReceiveUserProfileUpdates _receiveUserProfileUpdates;

  /// A use case needed to be able to create a new user profile.
  CreateUserProfileUseCase _createUserProfileUseCase;

  /// A use case needed to be able to update the existing user profile.
  UpdateUserProfileUseCase _updateUserProfileUseCase;

  /// A use case needed to be able to receive the project updates.
  ReceiveProjectUpdates _receiveProjectUpdates;

  /// A use case needed to be able to receive the project metrics updates.
  ReceiveProjectMetricsUpdates _receiveProjectMetricsUpdates;

  /// A use case needed to receive the project group updates.
  ReceiveProjectGroupUpdates _receiveProjectGroupUpdates;

  /// A use case needed to be able to add a new project group.
  AddProjectGroupUseCase _addProjectGroupUseCase;

  /// A use case needed to be able to update the existing project group.
  UpdateProjectGroupUseCase _updateProjectGroupUseCase;

  /// A use case needed to be able to delete a project group.
  DeleteProjectGroupUseCase _deleteProjectGroupUseCase;

  /// A use case needed to be able to fetch a feature config.
  FetchFeatureConfigUseCase _fetchFeatureConfigUseCase;

  /// A use case needed to be able to log user logins.
  LogLoginUseCase _logLoginUseCase;

  /// A use case needed to be able to log page changes.
  LogPageViewUseCase _logPageViewUseCase;

  /// A use case needed to be able to reset the analytics user identifier.
  ResetUserUseCase _resetUserUseCase;

  /// A use case needed to be able to open the local config storage.
  OpenLocalConfigStorageUseCase _openLocalConfigStorageUseCase;

  /// A use case needed to be able to read the local config.
  ReadLocalConfigUseCase _readLocalConfigUseCase;

  /// A use case needed to be able to update the local config.
  UpdateLocalConfigUseCase _updateLocalConfigUseCase;

  /// A use case needed to be able to close the local config storage.
  CloseLocalConfigStorageUseCase _closeLocalConfigStorageUseCase;

  /// A use case needed to be able to receive the build day project metrics.
  ReceiveBuildDayProjectMetricsUpdates _receiveBuildDayProjectMetricsUpdates;

  /// Returns the current system's theme brightness.
  Brightness get platformBrightness {
    return WidgetsBinding.instance.window.platformBrightness;
  }

  /// The [ChangeNotifier] that holds the authentication state.
  AuthNotifier _authNotifier;

  /// The [ChangeNotifier] of the theme type.
  ThemeNotifier _themeNotifier;

  /// The [ChangeNotifier] that manages navigation.
  NavigationNotifier _navigationNotifier;

  @override
  void initState() {
    super.initState();
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId: widget.metricsConfig?.googleSignInClientId,
    );

    final _metricsRepository = FirestoreMetricsRepository();
    final _userRepository = FirebaseUserRepository(googleSignIn: googleSignIn);
    final _projectGroupRepository = FirestoreProjectGroupsRepository();
    final _projectRepository = FirestoreProjectRepository();
    final _featureConfigRepository = FirestoreFeatureConfigRepository();
    final _analyticsRepository = FirebaseAnalyticsRepository();
    final _hiveLocalConfigRepository = HiveLocalConfigRepository();
    final _buildDayRepository = FirestoreBuildDayRepository();

    _receiveProjectUpdates = ReceiveProjectUpdates(_projectRepository);
    _receiveProjectMetricsUpdates =
        ReceiveProjectMetricsUpdates(_metricsRepository);

    _receiveAuthUpdates = ReceiveAuthenticationUpdates(_userRepository);
    _signInUseCase = SignInUseCase(_userRepository);
    _googleSignInUseCase = GoogleSignInUseCase(_userRepository);
    _signOutUseCase = SignOutUseCase(_userRepository);

    _receiveUserProfileUpdates = ReceiveUserProfileUpdates(_userRepository);
    _createUserProfileUseCase = CreateUserProfileUseCase(_userRepository);
    _updateUserProfileUseCase = UpdateUserProfileUseCase(_userRepository);

    _receiveProjectGroupUpdates = ReceiveProjectGroupUpdates(
      _projectGroupRepository,
    );
    _addProjectGroupUseCase = AddProjectGroupUseCase(_projectGroupRepository);
    _updateProjectGroupUseCase = UpdateProjectGroupUseCase(
      _projectGroupRepository,
    );
    _deleteProjectGroupUseCase = DeleteProjectGroupUseCase(
      _projectGroupRepository,
    );

    _fetchFeatureConfigUseCase = FetchFeatureConfigUseCase(
      _featureConfigRepository,
    );

    _logLoginUseCase = LogLoginUseCase(_analyticsRepository);
    _logPageViewUseCase = LogPageViewUseCase(_analyticsRepository);
    _resetUserUseCase = ResetUserUseCase(_analyticsRepository);

    _openLocalConfigStorageUseCase = OpenLocalConfigStorageUseCase(
      _hiveLocalConfigRepository,
    );
    _readLocalConfigUseCase = ReadLocalConfigUseCase(
      _hiveLocalConfigRepository,
    );
    _updateLocalConfigUseCase = UpdateLocalConfigUseCase(
      _hiveLocalConfigRepository,
    );
    _closeLocalConfigStorageUseCase = CloseLocalConfigStorageUseCase(
      _hiveLocalConfigRepository,
    );
    _receiveBuildDayProjectMetricsUpdates =
        ReceiveBuildDayProjectMetricsUpdates(_buildDayRepository);

    _authNotifier = AuthNotifier(
      _receiveAuthUpdates,
      _signInUseCase,
      _googleSignInUseCase,
      _signOutUseCase,
      _receiveUserProfileUpdates,
      _createUserProfileUseCase,
      _updateUserProfileUseCase,
    );

    _themeNotifier = ThemeNotifier(brightness: platformBrightness);

    _navigationNotifier = NavigationNotifier(
      MetricsPageFactory(),
      PageParametersFactory(),
      const MetricsPageRouteConfigurationFactory(),
      BrowserNavigationState(window.history),
    );

    _authNotifier.addListener(_authNotifierListener);
    _themeNotifier.addListener(_themeNotifierListener);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _navigationNotifier),
        ChangeNotifierProvider(
          create: (_) => FeatureConfigNotifier(_fetchFeatureConfigUseCase),
        ),
        ChangeNotifierProvider.value(value: _authNotifier),
        ChangeNotifierProvider.value(value: _themeNotifier),
        ChangeNotifierProvider<DebugMenuNotifier>(
          create: (_) => DebugMenuNotifier(
            _openLocalConfigStorageUseCase,
            _readLocalConfigUseCase,
            _updateLocalConfigUseCase,
            _closeLocalConfigStorageUseCase,
          ),
        ),
        ChangeNotifierProxyProvider<AuthNotifier, AnalyticsNotifier>(
          lazy: false,
          create: (_) => AnalyticsNotifier(
            _logLoginUseCase,
            _logPageViewUseCase,
            _resetUserUseCase,
          ),
          update: (_, authNotifier, analyticsNotifier) {
            final user = authNotifier.userProfileModel;

            if (user != null) {
              analyticsNotifier.logLogin(user.id);
            }

            return analyticsNotifier;
          },
        ),
        ChangeNotifierProxyProvider<AuthNotifier, ProjectsNotifier>(
          lazy: false,
          create: (_) => ProjectsNotifier(_receiveProjectUpdates),
          update: (_, authNotifier, projectsNotifier) {
            _updateProjectsSubscription(authNotifier, projectsNotifier);

            return projectsNotifier;
          },
        ),
        ChangeNotifierProxyProvider2<AuthNotifier, ProjectsNotifier,
            ProjectGroupsNotifier>(
          create: (_) => ProjectGroupsNotifier(
            _receiveProjectGroupUpdates,
            _addProjectGroupUseCase,
            _updateProjectGroupUseCase,
            _deleteProjectGroupUseCase,
          ),
          update: (_, authNotifier, projectsNotifier, projectGroupsNotifier) {
            final isLoggedIn = authNotifier.isLoggedIn;

            if (isLoggedIn != null && isLoggedIn) {
              projectGroupsNotifier.subscribeToProjectGroups();
            } else {
              projectGroupsNotifier.unsubscribeFromProjectGroups();
            }

            projectGroupsNotifier.setProjects(
              projectsNotifier.projectModels,
              projectsNotifier.projectsErrorMessage,
            );

            return projectGroupsNotifier;
          },
        ),
        ChangeNotifierProxyProvider2<ProjectsNotifier, ProjectGroupsNotifier,
            ProjectMetricsNotifier>(
          create: (_) => ProjectMetricsNotifier(
            _receiveProjectMetricsUpdates,
            _receiveBuildDayProjectMetricsUpdates,
          ),
          update: (_, projectsNotifier, projectGroupsNotifier,
              projectMetricsNotifier) {
            projectMetricsNotifier.setProjects(
              projectsNotifier.projectModels,
              projectsNotifier.projectsErrorMessage,
            );

            projectMetricsNotifier.setProjectGroups(
              projectGroupsNotifier.projectGroupModels,
            );

            return projectMetricsNotifier;
          },
        ),
        ChangeNotifierProxyProvider<ProjectMetricsNotifier, TimerNotifier>(
          create: (_) => TimerNotifier(),
          lazy: false,
          update: (_, projectMetricsNotifier, timerNotifier) {
            final isMetricsLoaded = !projectMetricsNotifier.isMetricsLoading;

            if (isMetricsLoaded) {
              const duration = Duration(seconds: 1);
              timerNotifier.start(duration);
            }

            return timerNotifier;
          },
        ),
      ],
      child: widget.child,
    );
  }

  /// Listens to [AuthNotifier]'s updates.
  void _authNotifierListener() {
    final updatedUserProfile = _authNotifier.userProfileModel;
    final isLoggedIn = _authNotifier.isLoggedIn;

    _navigationNotifier.handleAuthenticationUpdates(isLoggedIn: isLoggedIn);
    _themeNotifier.changeTheme(updatedUserProfile?.selectedTheme);
  }

  /// Listens to [ThemeNotifier]'s updates.
  void _themeNotifierListener() {
    final userProfileModel = UserProfileModel(
      selectedTheme: _themeNotifier.selectedTheme,
    );

    _authNotifier.updateUserProfile(userProfileModel);
  }

  /// Updates projects subscription based on user logged in status.
  void _updateProjectsSubscription(
    AuthNotifier authNotifier,
    ProjectsNotifier projectsNotifier,
  ) {
    final isLoggedIn = authNotifier.isLoggedIn;

    if (isLoggedIn == null) return;

    if (isLoggedIn) {
      projectsNotifier.subscribeToProjects();
    } else {
      projectsNotifier.unsubscribeFromProjects();
    }
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_authNotifierListener);
    _themeNotifier.removeListener(_themeNotifierListener);
    _authNotifier.dispose();
    _themeNotifier.dispose();
    _navigationNotifier.dispose();
    super.dispose();
  }
}
