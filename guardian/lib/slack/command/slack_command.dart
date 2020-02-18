import 'package:guardian/runner/command/guardian_command.dart';
import 'package:guardian/slack/model/slack_config.dart';

/// An abstract class representing command for Slack related interactions.
///
/// Implements [GuardianCommand] properties dealing with configurations
/// providing Slack configurations to related commands.
abstract class SlackCommand extends GuardianCommand {
  @override
  String get configurationsFilename => SlackConfig().filename;

  @override
  SlackConfig get config => SlackConfig()..readFromMap(loadConfigurations());
}
