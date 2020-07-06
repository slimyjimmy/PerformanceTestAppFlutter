import 'dart:async';

import 'package:flutter/material.dart';
import 'package:performance_flutter/resources/values/app_strings.dart';
import 'package:performance_flutter/test_result.dart';
import 'package:sensors/sensors.dart';

class AccelerometerTest extends StatefulWidget {
  @override
  _AccelerometerTestState createState() => _AccelerometerTestState();
}

class _AccelerometerTestState extends State<AccelerometerTest> {
  TextEditingController _numberOfIterationsController =
      new TextEditingController();
  var _testResults = <TestResult>[];
  var _testRunning = false;
  var _testStarted = false;
  AccelerometerEvent _accelerometerEvent;
  StreamSubscription _streamSubscription;
  var _numberOfIterationsLeft;

  Widget _numberOfIterationsTextField() {
    return TextFormField(
      controller: _numberOfIterationsController,
      decoration: InputDecoration(
        labelText: 'Number of iterations',
      ),
    );
  }

  /*Future<Widget> _getResultTile(int i) async {
    await Future.delayed(Duration(seconds: 1));
    return ListTile(
      title: Text(_testResults[i].message + " in " + _testResults[i].duration.toString()),
    );
  }*/

  _iterate(int numberOfIterations) {
    _testResults = <TestResult>[];
    _numberOfIterationsLeft = numberOfIterations;
    _testStarted = true;
    _testRunning = true;
    _startTest();
  }

  void _test(DateTime startTime) {
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) async {
      var stopTime = DateTime.now();
      await _streamSubscription.cancel();
      _addTestResult(new TestResult(
          stopTime.difference(startTime).inMicroseconds.toDouble(),
          "Test finished (" + event.toString() + ")"));
      _numberOfIterationsLeft--;
      if (_numberOfIterationsLeft > 0) {
        _test(DateTime.now());
      } else {
        var durationSum = 0.0;
        for (int i = 0; i < _testResults.length; i++) {
          durationSum += _testResults[i].duration;
        }
        var durationAvg = durationSum / _testResults.length;
        _addTestResult(
            new TestResult(durationAvg, "ALL TESTS FINISHED AVAREGING"));
      }
    });
  }

  void _addTestResult(TestResult testResult) {
    setState(() {
      _testResults.add(testResult);
    });
  }

  void _startTest() async {
    var startTime = DateTime.now();
    _test(startTime);
  }

  Widget _getTestResults() {
    return ListView.separated(
      itemCount: (_testResults.length > 0) ? _testResults.length : 0,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(_testResults[i].message +
              " in " +
              _testResults[i].duration.toString() + "μs"),
        );
      },
      separatorBuilder: (context, i) {
        return Divider();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Accelerometer Test'),
        ),
        body: Column(
          children: <Widget>[
            Text('Fetch the current accelerometer values'),
            Text('Please specify test parameters'),
            _numberOfIterationsTextField(),
            RaisedButton(
              child: Text(AppStrings.button_startTest),
              onPressed: () =>
                  _iterate(int.parse(_numberOfIterationsController.text)),
            ),
            Expanded(
              child: _getTestResults(),
            ),
          ],
        ));
  }
}
