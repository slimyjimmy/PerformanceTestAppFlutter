import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performance_flutter/base64.dart';
import 'package:performance_flutter/resources/values/app_strings.dart';
import 'package:performance_flutter/test_result.dart';
import 'package:permission_handler/permission_handler.dart';



class FilesystemTest extends StatefulWidget {
  @override
  _FilesystemTestState createState() => _FilesystemTestState();
}

class _FilesystemTestState extends State<FilesystemTest> {
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
    _saveTestFileToDevice();
    for (int i = 0; i < numberOfIterations; i++) {
      _testStarted = true;
      _testRunning = true;
      _startTest();
    }
  }

  void _saveTestFileToDevice() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final encodedFile = Base64.encodedFile;

    File file = File('$path/flutter_test_file.png');
    file.writeAsBytes(base64.decode(encodedFile)).whenComplete(() {
      print("Saved");
      print(file.path);
    });
  }

  void _addTestResult(TestResult testResult) {
    setState(() {
      _testResults.add(testResult);
    });
  }

  void _startTest() async {
    var startTime = DateTime.now();
    var test = await _readTestFileFromDevice();
    var stopTime = DateTime.now();
    var difference = stopTime.difference(startTime).inMicroseconds.toDouble();
    var resultString = "Test finished successfully.";
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

  Future _readTestFileFromDevice() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    File file = File('$path/flutter_test_file.png');
    print("inside read");
    return file.readAsBytes();
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
    var permissionLocation = Permission.storage;
    if (!await permissionLocation.request().isGranted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Filesystem Test'),
        ),
        body: Column(
          children: <Widget>[
            Text('Retrieve image from filesystem'),
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
