import 'dart:async';

import 'package:flutter/material.dart';
import 'package:metrics/features/auth/presentation/state/user_store.dart';
import 'package:metrics/features/common/presentation/metrics_theme/store/theme_store.dart';
import 'package:metrics/features/common/presentation/routes/route_generator.dart';
import 'package:metrics/features/common/presentation/strings/common_strings.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/// The application side menu widget.
class MetricsDrawer extends StatelessWidget {
  const MetricsDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Container(),
          ),
          StateBuilder<ThemeStore>(
            models: [Injector.getAsReactive<ThemeStore>()],
            builder: (context, model) {
              final snapshot = model.snapshot.data;

              return CheckboxListTile(
                value: snapshot.isDark,
                title: const Text('Dark theme'),
                onChanged: (_) => _changeTheme(model, snapshot),
              );
            },
          ),
          StateBuilder<UserStore>(
            models: [Injector.getAsReactive<UserStore>()],
            builder: (context, ReactiveModel<UserStore> userStoreRM) {
              return ListTile(
                key: const Key('Logout'),
                title: const Text(CommonStrings.logOut),
                onTap: () => signOut(context, userStoreRM),
              );
            },
          )
        ],
      ),
    );
  }

  /// Signs out a user from the app
  Future<void> signOut(BuildContext context, ReactiveModel<UserStore> storeRM) async {
    StreamSubscription _loggedInStreamSubscription;

    _loggedInStreamSubscription = Injector.get<UserStore>()
        .loggedInStream
        .listen((isUserLoggedIn) {
      if (isUserLoggedIn != null && !isUserLoggedIn) {
        /// Remove all the routes below the pushed 'login' route to prevent
        /// accidental navigate back to the dashboard page
        Navigator.pushNamedAndRemoveUntil(
            context,
            RouteGenerator.login,
                (Route<dynamic> route) => false);
        /// Cancels logged in stream subscription
        _loggedInStreamSubscription.cancel();
      }
    });

    await storeRM.setState((userStore) => userStore.signOut());
  }

  void _changeTheme(ReactiveModel<ThemeStore> model, ThemeStore snapshot) {
    model.setState(
      (model) => snapshot.isDark = !snapshot.isDark,
    );
  }
}
