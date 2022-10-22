import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/component/otp_dialog.dart';
import 'package:booking_system_flutter/component/selected_item_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/register_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/forgot_password_screen.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/home_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/string_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

class SignInScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;

  SignInScreen({this.isFromDashboard, this.isFromServiceBooking});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isRemember = getBoolAsync(IS_REMEMBERED, defaultValue: true);
    if (isRemember) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
    } else {
      if (isIqonicProduct) {
        emailCont.text = DEFAULT_EMAIL;
        passwordCont.text = DEFAULT_PASS;
      }
    }
    afterBuildCreated(() {
      if (getStringAsync(PLAYERID).isEmpty) saveOneSignalPlayerId();
    });
  }

  //region Methods
  void loginUsers() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      var request = {
        UserKeys.email: emailCont.text.trim(),
        UserKeys.password: passwordCont.text.trim(),
        UserKeys.playerId: getStringAsync(PLAYERID, defaultValue: ""),
      };

      log("Login Request $request");

      appStore.setLoading(true);

      await loginUser(request).then((res) async {
        res.data!.password = passwordCont.text.trim();

        await userService.getUser(email: res.data!.email).then((value) async {
          res.data!.uid = value.uid.validate();

          if (res.data!.user_type == LoginTypeUser) {
            if (res.data != null) await saveUserData(res.data!);

            toast(language!.loginSuccessfully);

            if (widget.isFromDashboard.validate()) {
              setStatusBarColor(context.primaryColor);
              finish(context, true);
              return;
            }

            HomeScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
          } else {
            toast(language!.cantLogin);
          }
        }).catchError((e) {
          if (e.toString() == USER_NOT_FOUND) {
            RegisterData data = RegisterData(
              api_token: res.data!.api_token.validate(),
              contact_number: res.data!.contact_number.validate(),
              display_name: res.data!.display_name.validate(),
              email: res.data!.email.validate(),
              first_name: res.data!.first_name.validate(),
              last_name: res.data!.last_name.validate(),
              user_type: res.data!.user_type.validate(),
              username: res.data!.username.validate(),
              password: passwordCont.text.trim(),
            );
            log(data.toJson());

            authService.signUpWithEmailPassword(context, registerResponse: RegisterResponse(registerData: data), isLogin: false).then((value) {
              //
            }).catchError((e) {
              appStore.setLoading(false);

              log(e.toString());
            });
          } else {
            appStore.setLoading(false);

            toast(e.toString());
          }
        });
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });

      appStore.setLoading(false);
    }
  }

  //endregion

  //region Widgets
  Widget _buildTopWidget() {
    return Container(
      child: Column(
        children: [
          Text("${language!.lblLoginTitle}!", style: boldTextStyle(size: 24)).center(),
          16.height,
          Text(language!.lblLoginSubTitle, style: primaryTextStyle(size: 16), textAlign: TextAlign.center).center().paddingSymmetric(horizontal: 32),
          32.height,
        ],
      ),
    );
  }

  Widget _buildFormWidget() {
    return Column(
      children: [
        AppTextField(
          textFieldType: TextFieldType.EMAIL,
          controller: emailCont,
          focus: emailFocus,
          nextFocus: passwordFocus,
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintEmailTxt),
          suffix: ic_message.iconImage(size: 10).paddingAll(14),
          autoFillHints: [AutofillHints.email],
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.PASSWORD,
          controller: passwordCont,
          focus: passwordFocus,
          suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
          suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintPasswordTxt),
          onFieldSubmitted: (s) {
            loginUsers();
          },
        ),
      ],
    );
  }

  Widget _buildRememberWidget() {
    return Column(
      children: [
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                2.width,
                SelectedItemWidget(isSelected: isRemember).onTap(() async {
                  await setValue(IS_REMEMBERED, isRemember);
                  isRemember = !isRemember;
                  setState(() {});
                }),
                TextButton(
                  onPressed: () async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  },
                  child: Text(language!.rememberMe, style: secondaryTextStyle()),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
              child: Text(
                language!.forgotPassword,
                style: boldTextStyle(color: primaryColor, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        24.height,
        AppButton(
          text: language!.btnTextLogin,
          color: primaryColor,
          textStyle: boldTextStyle(color: white),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            loginUsers();
          },
        ),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(language!.doNotHaveAccount, style: secondaryTextStyle()),
            TextButton(
              onPressed: () {
                SignUpScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              },
              child: Text(
                language!.txtCreateAccount,
                style: boldTextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSocialWidget() {
    return Column(
      children: [
        20.height,
        Row(
          children: [
            Divider(color: context.dividerColor, thickness: 2).expand(),
            16.width,
            Text(language!.lblOrContinueWith, style: secondaryTextStyle()),
            16.width,
            Divider(color: context.dividerColor, thickness: 2).expand(),
          ],
        ),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: primaryColor.withOpacity(0.1),
                boxShape: BoxShape.circle,
              ),
              child: GoogleLogoWidget(size: 24).onTap(() async {
                hideKeyboard(context);

                appStore.setLoading(true);

                await authService.signInWithGoogle().then((value) async {
                  appStore.setLoading(false);
                  //
                }).catchError((e) {
                  appStore.setLoading(false);
                  toast(e.toString());
                });
              }),
            ),
            28.width,
            Container(
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: primaryColor.withOpacity(0.1),
                boxShape: BoxShape.circle,
              ),
              child: ic_calling.iconImage(color: primaryColor).paddingAll(4).onTap(() async {
                hideKeyboard(context);

                appStore.setLoading(true);

                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  builder: (p0) => AppCommonDialog(title: "OTP LOGIN", child: OTPDialog()),
                );

                appStore.setLoading(false);
                //voidCallback?.call();
              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
            ),
          ],
        ),
      ],
    );
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (widget.isFromServiceBooking.validate()) {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark);
    }
    if (widget.isFromDashboard.validate()) {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark);
    }
    setStatusBarColor(primaryColor, statusBarIconBrightness: Brightness.light);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        elevation: 0,
        showBack: false,
        color: context.scaffoldBackgroundColor,
        backWidget: BackWidget(),
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: Body(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                64.height,
                _buildTopWidget(),
                _buildFormWidget(),
                _buildRememberWidget(),
                if (!getBoolAsync(HAS_IN_REVIEW)) _buildSocialWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
