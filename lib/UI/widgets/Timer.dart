import 'dart:async' as s;

import 'package:flutter/material.dart';
class Timer extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {


  s.Timer _timer;
  int _start = 60;

  void startTimer() async {
    const oneSec = const Duration(seconds: 1);
    _timer =  new s.Timer.periodic(
      oneSec,
          (s.Timer timer) {
        if (_start == 0) {
          if(this.mounted)
            setState(() {
              timer.cancel();
            });
        } else {
          if(this.mounted)
            setState(() {
              _start--;
            });
        }
      },
    );
  }


  @override
  void initState() {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return   Text( _start == 0 || ( _timer != null &&!_timer.isActive) ?  "Click to resend"  :"Resend code after $_start sec" ,
      style: TextStyle(

          fontSize: 16.0
      ),);
  }
}
