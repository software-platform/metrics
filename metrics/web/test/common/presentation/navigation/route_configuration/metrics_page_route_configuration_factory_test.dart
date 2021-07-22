// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/navigation/constants/default_routes.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/metrics_page_route_configuration_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/route_name_mock.dart';

void main() {
  group("MetricsPageRouteConfigurationFactory", () {
    const loginRouteName = RouteName.login;
    const dashboardRouteName = RouteName.dashboard;
    const projectGroupsRouteName = RouteName.projectGroups;
    const debugMenuRouteName = RouteName.debugMenu;
    const pageRouteConfigurationFactory =
        MetricsPageRouteConfigurationFactory();
    const pageParameters = DashboardPageParametersModel();

    final pageParametersMap = pageParameters.toMap();
    const loadingRouteConfiguration = DefaultRoutes.loading;

    MetricsPage createMetricsPage({
      RouteName routeName,
      Object arguments,
    }) {
      return MetricsPage(
        child: const Text('test'),
        routeName: routeName,
        arguments: arguments,
      );
    }

    test(
      ".create() returns a loading route configuration if the given page is null",
      () {
        final configuration = pageRouteConfigurationFactory.create(null);

        expect(configuration, equals(loadingRouteConfiguration));
      },
    );

    test(
      ".create() returns a loading route configuration if the given page route name is unknown",
      () {
        final routeName = RouteNameMock();
        final page = createMetricsPage(routeName: routeName);

        when(routeName.value).thenReturn('unknown');

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(loadingRouteConfiguration));
      },
    );

    test(
      ".create() returns a route configuration with parameters equal to null if the given page arguments is not an instance of the page parameters model",
      () {
        final page = createMetricsPage(
          routeName: RouteName.dashboard,
          arguments: Object(),
        );

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration.parameters, isNull);
      },
    );

    test(
      ".create() returns a loading route configuration if the given page route name is a loading",
      () {
        final page = createMetricsPage(routeName: RouteName.loading);

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(loadingRouteConfiguration));
      },
    );

    test(
      ".create() returns a login route configuration if the given page route name is a login",
      () {
        final page = createMetricsPage(routeName: loginRouteName);

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(DefaultRoutes.login));
      },
    );

    test(
      ".create() returns a dashboard route configuration if the given page route name is a dashboard",
      () {
        final page = createMetricsPage(routeName: dashboardRouteName);

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(DefaultRoutes.dashboard));
      },
    );

    test(
      ".create() returns a project groups route configuration if the given page route name is a project groups",
      () {
        final page = createMetricsPage(routeName: projectGroupsRouteName);

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(DefaultRoutes.projectGroups));
      },
    );

    test(
      ".create() returns a debug menu route configuration if the given page route name is a debug menu",
      () {
        final page = createMetricsPage(routeName: debugMenuRouteName);

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration, equals(DefaultRoutes.debugMenu));
      },
    );

    test(
      ".create() returns a route configuration with the parameters equal to the given page parameters",
      () {
        final page = createMetricsPage(
          routeName: debugMenuRouteName,
          arguments: pageParameters,
        );

        final configuration = pageRouteConfigurationFactory.create(page);

        expect(configuration.parameters, equals(pageParametersMap));
      },
    );
  });
}
