import 'dart:async';
import 'package:flutter/material.dart';

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
  Stopwatch watch = Stopwatch();
  Timer timer = Timer.periodic(Duration(milliseconds: 0), (timer) {});
  String displayedTime = '00:00:00:00';
  int milliseconds = 0;
  final _lapTimes = <String>[];
  int _lapCounter = 0;
  String _lapString = '0';
  bool timerOn = false;

  timeToString(int milliseconds) {
    int centiseconds = (milliseconds / 10).truncate();
    int seconds = (centiseconds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    String strHours = (hours % 60).toString().padLeft(2, '0');
    String strMinutes = (minutes % 60).toString().padLeft(2, '0');
    String strSeconds = (seconds % 60).toString().padLeft(2, '0');
    String strCentiseconds = (centiseconds % 100).toString().padLeft(2, '0');
    return "$strHours:$strMinutes:$strSeconds:$strCentiseconds";
  }

  displayTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        milliseconds = watch.elapsedMilliseconds;
        displayedTime = timeToString(milliseconds);
      });
    }
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
                  style: TextStyle(color: Colors.blue, fontSize: 80.0)),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      child: Text('Start/Resume',
                          style: TextStyle(fontSize: 25.0)),
                      onPressed: () {
                        setState(() {
                          watch.start();
                          timerOn = true;
                          timer = Timer.periodic(
                              Duration(milliseconds: 100), displayTime);
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green)),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                      child: Text('Pause', style: TextStyle(fontSize: 25.0)),
                      onPressed: () {
                        setState(() {
                          timerOn = false;
                          watch.stop();
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.orange)),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                      child: Text('Reset', style: TextStyle(fontSize: 25.0)),
                      onPressed: () {
                        setState(() {
                          watch.reset();
                          watch.stop();
                          timerOn = false;
                          displayedTime = '00:00:00:00';
                          _lapCounter = 0;
                          _lapTimes.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red))
                ],
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                  child: Text('Lap', style: TextStyle(fontSize: 25.0)),
                  onPressed: () {
                    setState(() {
                      if (timerOn) {
                        _lapCounter++;
                        _lapString = _lapCounter.toString();
                        _lapTimes.add('Lap $_lapString Time: $displayedTime');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue))
            ],
          ),
        ));
  }

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
