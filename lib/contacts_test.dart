import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:performance_flutter/resources/values/app_strings.dart';
import 'package:performance_flutter/test_result.dart';
import 'package:permission_handler/permission_handler.dart';


class ContactsTest extends StatefulWidget {
  @override
  _ContactsTestState createState() => _ContactsTestState();
}

class _ContactsTestState extends State<ContactsTest> {
  var _numberOfIterationsController = new TextEditingController();
  var _testResults = <TestResult>[];
  var _testRunning = false;
  var _testStarted = false;
  int _numberOfIterationsLeft;

  Widget _numberOfIterationsTextField() {
    return TextFormField(
      controller: _numberOfIterationsController,
      decoration: InputDecoration(labelText:'Number of iterations',),
    );
  }

  _iterate(int numberOfIterations) {
    _numberOfIterationsLeft = numberOfIterations;
    _testResults = <TestResult>[];
    for (int i = 0; i < numberOfIterations; i++) {
      _testStarted = true;
      _testRunning = true;
      _startTest();
    }
  }

  void _addTestResult(TestResult testResult) {
    setState(() {
      _testResults.add(testResult);
    });
  }

  void _startTest() async {
    var startTime = DateTime.now();
    await _insertContact();
    var stopTime = DateTime.now();
    var difference = stopTime.difference(startTime).inMicroseconds.toDouble();
    var resultString = "Test finished successfully";
    /*setState(() {
      _testResults.add(new TestResult(difference, resultString));
    });*/
    _addTestResult(new TestResult(difference, resultString));
    _numberOfIterationsLeft--;
    if (_numberOfIterationsLeft == 0) {
      var durationSum = 0.0;
      for (int i = 0; i < _testResults.length; i++) {
        durationSum += _testResults[i].duration;
      }
      double durationAvg = durationSum / _testResults.length;
      _addTestResult(new TestResult(durationAvg, "ALL TESTS FINISHED SUCCESSFULLY AVERAGING"));
    }
  }

  Future<void> _insertContact() async {
    var contact = new Contact();
    contact.familyName = "Flutter Test";
    contact.givenName = _numberOfIterationsLeft.toString();
    contact.phones = [Item(label: "mobile", value: "123456789")];
    return ContactsService.addContact(contact);
  }

  Widget _getTestResults() {
    return ListView.separated(
      itemCount: (_testResults.length > 0) ? _testResults.length : 0,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(_testResults[i].message + " in " + _testResults[i].duration.toString() + "μs"),
        );
      },
      separatorBuilder: (context, i) {
        return Divider();
      },
    );
  }

  @override
  initState() {
    super.initState();
    _handlePermissions();
  }
  
  void _handlePermissions() async {
    var permissionReadContacts = Permission.contacts;
    if (!await permissionReadContacts.request().isGranted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contacts Test'),
        ),
        body: Column(
          children: <Widget>[
            Text('Write contact to file system'),
            Text('Please specify test parameters'),
            _numberOfIterationsTextField(),
            RaisedButton(
              child: Text(AppStrings.button_startTest),
              onPressed: () => _iterate(int.parse(_numberOfIterationsController.text)),
            ),
            Expanded(
              child: _getTestResults(),
            ),
          ],
        )
    );
  }
}
