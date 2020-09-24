import 'package:flutter/material.dart';
import 'package:metrics/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/auth/presentation/widgets/auth_form.dart';
import 'package:metrics/common/presentation/metrics_theme/state/theme_notifier.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/common/presentation/routes/route_name.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/common/presentation/toast/widgets/negative_toast.dart';
import 'package:metrics/common/presentation/toast/widgets/toast.dart';
import 'package:metrics/common/presentation/widgets/metrics_theme_image.dart';
import 'package:provider/provider.dart';

/// Shows the authentication form to sign in.
class LoginPage extends StatefulWidget {
  /// Creates a new instance of [LoginPage].
  const LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

/// The logic and internal state for the [LoginPage] widget.
class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  /// An [AuthNotifier] needed to be able to remove the listener
  /// in the [dispose] method.
  AuthNotifier _authNotifier;

  /// A [ThemeNotifier] needed to change the theme according to the operating
  /// system's theme.
  ThemeNotifier _themeNotifier;

  @override
  void initState() {
    _authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _authNotifier.addListener(_loggedInListener);
    _authNotifier.addListener(_loggedInErrorListener);

    _themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePlatformBrightness();
    });

    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    _handlePlatformBrightness();
    super.didChangePlatformBrightness();
  }

  /// Changes the current theme according to the operating system's theme.
  void _handlePlatformBrightness() {
    final platformBrightness =
        WidgetsBinding.instance.window.platformBrightness;

    final isDark = platformBrightness == Brightness.dark;

    _themeNotifier.setTheme(isDark: isDark);
  }

  /// Navigates to the dashboard screen once the user becomes logged in.
  void _loggedInListener() {
    final isLoggedIn = _authNotifier.isLoggedIn;

    if (isLoggedIn != null && isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteName.dashboard,
        (Route<dynamic> route) => false,
      );
    }
  }

  /// Shows the [NegativeToast] with an error message
  /// if the auth error message is not null.
  void _loggedInErrorListener() {
    final errorMessage = _authNotifier.authErrorMessage;

    if (errorMessage != null) {
      showToast(context, NegativeToast(message: errorMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = MetricsTheme.of(context).loginTheme;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 104.0),
                alignment: Alignment.center,
                child: const MetricsThemeImage(
                  darkAsset: 'icons/logo-metrics.svg',
                  lightAsset: 'icons/logo-metrics-light.svg',
                  width: 180.0,
                  height: 44.0,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  CommonStrings.welcomeMetrics,
                  style: loginTheme.titleTextStyle,
                ),
              ),
              AuthForm(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_loggedInListener);
    _authNotifier.removeListener(_loggedInErrorListener);

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
