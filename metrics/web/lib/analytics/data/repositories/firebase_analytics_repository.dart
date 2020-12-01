import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:metrics/analytics/domain/repositories/analytics_repository.dart';

/// Provides methods for interaction with the [FirebaseAnalytics].
class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  @override
  Future<void> logLogin(String id) async {
    await _analytics.setUserId(id);

    return _analytics.logLogin();
  }

  @override
  Future<void> logPageView(String pageName) {
    return _analytics.logEvent(name: pageName);
  }
}
