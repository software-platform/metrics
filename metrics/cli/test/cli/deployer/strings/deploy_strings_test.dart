// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/deployer/strings/deploy_strings.dart';
import 'package:test/test.dart';

void main() {
  group("DeployStrings", () {
    test(
      ".failedDeployment() returns a message that contains the given error message",
      () {
        const errorMessage = 'errorMessage';

        final message = DeployStrings.failedDeployment(errorMessage);

        expect(message, contains(errorMessage));
      },
    );

    test(
      ".deleteProject() returns a message that contains the given project id",
      () {
        const projectId = 'projectId';

        final message = DeployStrings.deleteProject(projectId);

        expect(message, contains(projectId));
      },
    );
  });
}
