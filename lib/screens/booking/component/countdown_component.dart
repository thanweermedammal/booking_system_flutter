import 'dart:async';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CountdownWidget extends StatefulWidget {
  final String? text;
  final BookingDetailResponse bookingDetailResponse;

  CountdownWidget({this.text, required this.bookingDetailResponse});

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? timer;
  bool stopTimer = true;

  int value = 0;

  @override
  void initState() {
    if (widget.bookingDetailResponse.booking_detail!.status.validate() == BookingStatusKeys.inProgress) {
      value =
          "${(widget.bookingDetailResponse.booking_detail!.durationDiff.toInt() + DateTime.now().difference(DateTime.parse(widget.bookingDetailResponse.booking_detail!.startAt.validate())).inSeconds)}"
              .toInt();
      stopTimer = false;
      init();
    } else {
      value = widget.bookingDetailResponse.booking_detail!.durationDiff.validate().toInt();
    }
    LiveStream().on(startTimer, (value) {
      Map<String, dynamic> data = value as Map<String, dynamic>;

      if (data['status'] == BookingStatusKeys.hold || data['status'] == BookingStatusKeys.complete) {
        value = data['inSeconds'] as int;
        stopTimer = true;
        setState(() {});
      } else {
        value = data['inSeconds'] as int;
        stopTimer = false;
        init();
      }
      //
    });

    LiveStream().on(pauseTimer, (value) {
      timer?.cancel();
      //
    });

    super.initState();
  }

  void init() async {
    timer = Timer(1.seconds, () {
      if (!stopTimer) init();
      value += 1;
      setState(() {});
    });
  }

  // Logic For Calculate Time
  String calculateTimer(int secTime) {
    int hour = 0, minute = 0, seconds = 0;

    hour = secTime ~/ 3600;

    minute = ((secTime - hour * 3600)) ~/ 60;

    seconds = secTime - (hour * 3600) - (minute * 60);

    String hourLeft = hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

    String minuteLeft = minute.toString().length < 2 ? "0" + minute.toString() : minute.toString();

    String secondsLeft = seconds.toString().length < 2 ? "0" + seconds.toString() : seconds.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorderWidget(
      padding: EdgeInsets.all(16),
      color: context.dividerColor,
      child: Row(
        children: [
          Text(widget.text ?? '${language!.lblServiceTotalTime} : ', style: primaryTextStyle()),
          Text(calculateTimer(value), style: boldTextStyle(color: Colors.red)),
        ],
      ),
    ).withWidth(context.width()).paddingSymmetric(vertical: 8);
  }
}
