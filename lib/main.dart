import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

void main() => runApp(StopwatchPage());

class StopwatchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stopwatch',
      theme: ThemeData(primaryColor: Colors.blue),
      home: FlutterStopwatch(),
    );
  }
}

class FlutterStopwatch extends StatefulWidget {
  @override
  _FlutterStopwatchState createState() => _FlutterStopwatchState();
}

class _FlutterStopwatchState extends State<FlutterStopwatch> {
  Timer? timer; // Timer to check and manipulate watch state
  String displayedTime = '00:00:00';
  int seconds = 0; // Total number of unpaused seconds since start
  List<String> _lapTimes = <String>[]; // Hold lap times
  int _lapCounter = 0; // Number of laps
  String _lapString = '0'; // Num of laps converted to string
  bool timerOn = false; // Whether watch is on

  @override
  void initState() {
    super.initState();
    // Update timer frequently in case app is reloaded/restarted
    timer =
        Timer.periodic(Duration(milliseconds: 100), (Timer t) => checkStatus());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Check whether watch is on and save DateTime data in order to update watch
  checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timerOn = prefs.getBool('timerOn') ?? false;
    // If watch is on:
    if (timerOn) {
      setState(() {
        // Find difference between last saved date time and current date time
        String oldTimeStr =
            prefs.getString('oldTimeStr') ?? dateFormat.format(DateTime.now());
        String currTimeStr = dateFormat.format(DateTime.now());
        DateTime oldTime = dateFormat.parse(oldTimeStr);
        DateTime currTime = dateFormat.parse(currTimeStr);
        int diff = currTime.difference(oldTime).inSeconds;
        prefs.setString('oldTimeStr', currTimeStr);

        // Add difference in saved date times to seconds
        seconds = prefs.getInt('seconds') ?? 0;
        seconds = seconds + diff;
        prefs.setInt('seconds', seconds);
        displayedTime = timeToString(seconds);

        // Reload saved lap counters and times
        _lapCounter = prefs.getInt('_lapCounter') ?? 0;
        _lapString = prefs.getString('_lapString') ?? '0';
        _lapTimes = prefs.getStringList('_lapTimes') ?? [];
      });
    } else {
      // Otherwise if watch is not on, save current number of seconds
      setState(() {
        seconds = prefs.getInt('seconds') ?? 0;
        prefs.setInt('seconds', seconds);
        prefs.setString('oldTimeStr', dateFormat.format(DateTime.now()));
        displayedTime = timeToString(seconds);
      });
    }
  }

  // Helper function to convert seconds to time display in hh:mm:ss
  timeToString(int seconds) {
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String strHours = (hours % 60).toString().padLeft(2, '0');
    String strMinutes = (minutes % 60).toString().padLeft(2, '0');
    String strSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$strHours:$strMinutes:$strSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Stopwatch"),
          actions: [
            IconButton(icon: Icon(Icons.list), onPressed: _pushLapTimes),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(displayedTime,
                  style: TextStyle(color: Colors.black, fontSize: 80.0)),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Start watch button
                  ElevatedButton(
                      child: Text('Start/Resume',
                          style: TextStyle(fontSize: 25.0)),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          timerOn = true;
                          prefs.setBool('timerOn', timerOn);
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green)),
                  SizedBox(width: 20.0),
                  // Pause watch button
                  ElevatedButton(
                      child: Text('Pause', style: TextStyle(fontSize: 25.0)),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          timerOn = false;
                          prefs.setBool('timerOn', timerOn);
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.orange)),
                  SizedBox(width: 20.0),
                  // Reset watch button
                  ElevatedButton(
                      child: Text('Reset', style: TextStyle(fontSize: 25.0)),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          timerOn = false;
                          displayedTime = '00:00:00';
                          // Reset lap number and times
                          _lapCounter = 0;
                          _lapTimes.clear();
                          prefs.setBool('timerOn', timerOn);
                          prefs.setInt('seconds', 0);
                          prefs.setInt('_lapCounter', _lapCounter);
                          prefs.setStringList('_lapTimes', _lapTimes);
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red))
                ],
              ),
              SizedBox(height: 30.0),
              // Record lap button
              ElevatedButton(
                  child: Text('Lap', style: TextStyle(fontSize: 25.0)),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    setState(() {
                      timerOn = prefs.getBool('timerOn') ?? false;
                      // If watch active, increment lap number and add time
                      if (timerOn) {
                        _lapCounter++;
                        _lapString = _lapCounter.toString();
                        _lapTimes.add('Lap $_lapString Time: $displayedTime');
                        prefs.setInt('_lapCounter', _lapCounter);
                        prefs.setString('_lapString', _lapString);
                        prefs.setStringList('_lapTimes', _lapTimes);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.purple))
            ],
          ),
        ));
  }

  // List of lap times is stored in a separate page
  void _pushLapTimes() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _lapTimes.map(
            (String time) {
              return ListTile(
                title: Text(time),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: Text('Lap Times'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
