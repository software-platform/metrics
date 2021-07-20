// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/auth/presentation/pages/login_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/models/page_parameters_model.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/debug_menu/presentation/pages/debug_menu_page.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';

/// A factory that is responsible for creating the [MetricsPage]
/// depending on the [RouteConfiguration].
class MetricsPageFactory {
  /// Creates the [MetricsPage] using the given [routeConfiguration]
  /// and [pageParameters].
  ///
  /// If the given [routeConfiguration] is `null` or its [RouteConfiguration.name]
  /// does not match any of [RouteName]s, returns the [DashboardPage].
  MetricsPage create(
    RouteConfiguration routeConfiguration,
    PageParametersModel pageParameters,
  ) {
    RouteName routeName = routeConfiguration?.name;
    String path = routeConfiguration?.path;
    Widget child = const DashboardPage();

    switch (routeName) {
      case RouteName.loading:
        child = const LoadingPage();
        break;
      case RouteName.login:
        child = const LoginPage();
        break;
      case RouteName.projectGroups:
        child = const ProjectGroupPage();
        break;
      case RouteName.debugMenu:
        child = const DebugMenuPage();
        break;
      default:
        path = RouteConfiguration.dashboard().path;
        routeName = RouteName.dashboard;
        break;
    }

    return _createMetricsPage(child, routeName, path, pageParameters);
  }

  /// Creates a new instance of the [MetricsPage] with the given parameters.
  MetricsPage _createMetricsPage(
    Widget child,
    RouteName routeName,
    String path,
    PageParametersModel arguments,
  ) {
    return MetricsPage(
      name: path,
      child: child,
      routeName: routeName,
      arguments: arguments,
    );
  }
}
