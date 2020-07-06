import 'package:flutter/material.dart';
import 'package:performance_flutter/contacts_test.dart';
import 'package:performance_flutter/filesystem_test.dart';
import 'package:performance_flutter/geolocation_test.dart';
import 'package:performance_flutter/resources/values/app_colors.dart';
import 'package:performance_flutter/resources/values/app_strings.dart';

import 'accelerometer_test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: AppColors.PRIMARY_COLOR,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.app_name),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text(AppStrings.button_accelerometer),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                body: AccelerometerTest(),
              );
            })),
          ),
          RaisedButton(
            child: Text(AppStrings.button_contacts),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                body: ContactsTest(),
              );
            })),
          ),
          RaisedButton(
            child: Text(AppStrings.button_geolocation),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                body: GeolocationTest(),
              );
            })),
          ),
          RaisedButton(
            child: Text(AppStrings.button_filesystem),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                body: FilesystemTest(),
              );
            })),
          )
        ],
      ),
    );
  }
}
