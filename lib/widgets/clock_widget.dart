import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneClock extends StatefulWidget {
  final String timezone;

  const TimezoneClock({super.key, required this.timezone});

  @override
  State<TimezoneClock> createState() => _TimezoneClockState();
}

class _TimezoneClockState extends State<TimezoneClock> {
  late tz.Location location;
  late Timer _timer;
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    location = tz.getLocation(widget.timezone);
    currentTime = tz.TZDateTime.now(location);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = tz.TZDateTime.now(location);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(currentTime),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }
}
