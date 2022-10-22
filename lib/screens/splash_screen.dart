import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/dashboard/home_screen.dart';
import 'package:booking_system_flutter/screens/maintenance_mode_screen.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';

import 'walk_through_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() async {
      setStatusBarColor(Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.dark);

      await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE,
          defaultValue: DEFAULT_LANGUAGE));

      int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
      if (themeModeIndex == ThemeModeSystem) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }

      if (isAndroid || isIOS) {
        await PackageInfo.fromPlatform().then((value) {
          currentPackageName = value.packageName;
        }).catchError((e) {
          //
        });
      }

      if (!await isAndroid12Above()) await 2.seconds.delay;

      if (getBoolAsync(IN_MAINTENANCE_MODE)) {
        MaintenanceModeScreen()
            .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
          WalkThroughScreen()
              .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          HomeScreen().launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            appStore.isDarkMode ? splash_background : splash_light_background,
            height: context.height(),
            width: context.width(),
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(appLogo, height: 200, width: 200),
              32.height,
              // Text(APP_NAME, style: boldTextStyle(size: 26)),
            ],
          ),
        ],
      ),
    );
  }
}
