// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/common/presentation/navigation/constants/default_routes.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/models/page_parameters_model.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';

/// A factory that is responsible for creating the [RouteConfiguration]
/// depending on the [MetricsPage].
class MetricsPageRouteConfigurationFactory {
  /// Creates a new instance of the [MetricsPageRouteConfigurationFactory].
  const MetricsPageRouteConfigurationFactory();

  /// Creates the [RouteConfiguration] using the given [page].
  ///
  /// If the given [page] is `null` or its [MetricsPage.routeName] does not
  /// match to any of [RouteName]s returns the [DefaultRoutes.loading].
  RouteConfiguration create(MetricsPage page) {
    final routeName = page?.routeName;
    final parameters = page?.arguments as PageParametersModel;
    final parametersMap = parameters?.toMap();

    switch (routeName) {
      case RouteName.login:
        return RouteConfiguration.login(parameters: parametersMap);
      case RouteName.dashboard:
        return RouteConfiguration.dashboard(parameters: parametersMap);
      case RouteName.projectGroups:
        return RouteConfiguration.projectGroups(parameters: parametersMap);
      case RouteName.debugMenu:
        return RouteConfiguration.debugMenu(parameters: parametersMap);
      default:
        return DefaultRoutes.loading;
    }
  }
}
