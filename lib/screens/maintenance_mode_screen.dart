import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class MaintenanceModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/app_images/maintenance_mode.png',
            height: 300,
          ),
          Text('Under Maintenance...',
                  style: boldTextStyle(size: 18), textAlign: TextAlign.center)
              .center(),
          8.height,
          Text('Catch up after a while',
                  style: secondaryTextStyle(), textAlign: TextAlign.center)
              .center(),
          16.height,
          TextButton(
            onPressed: () async {
              // await setupFirebaseRemoteConfig();
              RestartWidget.restartApp(context);
            },
            child: Text('Recheck'),
          ),
        ],
      ),
    );
  }
}
