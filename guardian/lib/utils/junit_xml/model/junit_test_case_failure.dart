part of junit_xml;

/// A class representing <failure> element of JUnitXML report.
///
/// [text] contains relevant data for the failure (for example, a stack trace).
class JUnitTestCaseFailure extends JUnitTestCaseExecutionResult {
  JUnitTestCaseFailure({String text}) : super(text: text);
}