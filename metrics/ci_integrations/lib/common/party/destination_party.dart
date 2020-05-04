import 'package:ci_integration/common/client/destination_client.dart';
import 'package:ci_integration/common/config/model/destination_config.dart';
import 'package:ci_integration/common/party/integration_party.dart';

/// An abstract class representing an integration party
/// for a destination storage integration.
abstract class DestinationParty<T extends DestinationConfig,
    K extends DestinationClient> extends IntegrationParty<T, K> {}
