import 'package:flutter/material.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/common/presentation/injector/widget/injection_container.dart';
import 'package:metrics/common/presentation/metrics_theme/config/dimensions_config.dart';
import 'package:metrics/common/presentation/metrics_theme/config/text_field_config.dart';
import 'package:metrics/common/presentation/metrics_theme/config/text_style_config.dart';
import 'package:metrics/common/presentation/metrics_theme/model/dark_metrics_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/light_metrics_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme_builder.dart';
import 'package:metrics/common/presentation/routes/observers/overlay_entry_route_observer.dart';
import 'package:metrics/common/presentation/routes/observers/toast_route_observer.dart';
import 'package:metrics/common/presentation/routes/route_generator.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/util/favicon.dart';
import 'package:provider/provider.dart';

void main() => runApp(MetricsApp());

class MetricsApp extends StatefulWidget {
  @override
  _MetricsAppState createState() => _MetricsAppState();
}

class _MetricsAppState extends State<MetricsApp> {
  /// A route observer used to dismiss all opened toasts
  /// when the page route changes.
  final _toastRouteObserver = ToastRouteObserver();

  /// A route observer used to close all opened overlay entries
  /// when the page route changes.
  final _userMenuRouteObserver = OverlayEntryRouteObserver();

  @override
  Widget build(BuildContext context) {
    Favicon().setup();
    return InjectionContainer(
      child: MetricsThemeBuilder(
        builder: (context, themeNotifier) {
          final isDark = themeNotifier?.isDark ?? true;

          return MaterialApp(
            title: CommonStrings.metrics,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            onGenerateRoute: (settings) => RouteGenerator.generateRoute(
              settings: settings,
              isLoggedIn:
                  Provider.of<AuthNotifier>(context, listen: false).isLoggedIn,
            ),
            navigatorObservers: [_toastRouteObserver, _userMenuRouteObserver],
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              fontFamily: TextStyleConfig.defaultFontFamily,
              brightness: Brightness.light,
              primarySwatch: Colors.teal,
              primaryColorBrightness: Brightness.light,
              buttonTheme: const ButtonThemeData(
                height: DimensionsConfig.buttonHeight,
              ),
              scaffoldBackgroundColor: LightMetricsThemeData.scaffoldColor,
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: LightMetricsThemeData.inputColor,
                hoverColor: LightMetricsThemeData.inputHoverColor,
                border: TextFieldConfig.border,
                enabledBorder: TextFieldConfig.border,
                focusedBorder: LightMetricsThemeData.inputFocusedBorder,
                errorStyle: TextFieldConfig.errorStyle,
                errorBorder: TextFieldConfig.errorBorder,
                focusedErrorBorder: TextFieldConfig.errorBorder,
                hintStyle: LightMetricsThemeData.hintStyle,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              splashColor: Colors.transparent,
            ),
            darkTheme: ThemeData(
              fontFamily: TextStyleConfig.defaultFontFamily,
              brightness: Brightness.dark,
              primarySwatch: Colors.teal,
              primaryColorBrightness: Brightness.dark,
              buttonTheme: const ButtonThemeData(
                height: DimensionsConfig.buttonHeight,
              ),
              scaffoldBackgroundColor: DarkMetricsThemeData.scaffoldColor,
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: DarkMetricsThemeData.inputColor,
                hoverColor: Colors.black,
                border: TextFieldConfig.border,
                enabledBorder: TextFieldConfig.border,
                focusedBorder: DarkMetricsThemeData.inputFocusedBorder,
                errorStyle: TextFieldConfig.errorStyle,
                errorBorder: TextFieldConfig.errorBorder,
                focusedErrorBorder: TextFieldConfig.errorBorder,
                hintStyle: DarkMetricsThemeData.hintStyle,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              splashColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
