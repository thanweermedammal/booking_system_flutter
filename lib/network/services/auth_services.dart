import 'dart:convert';

import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/otp_dialog.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/login_model.dart';
import 'package:booking_system_flutter/model/register_model.dart';
import 'package:booking_system_flutter/model/user_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/home_screen.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  //region Google Login
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      //Authentication
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      await googleSignIn.signOut();
      String firstName = '';
      String lastName = '';
      if (currentUser.displayName.validate().split(' ').length >= 1) firstName = currentUser.displayName.splitBefore(' ');
      if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');

      Map req = {
        "email": currentUser.email,
        "first_name": firstName,
        "last_name": lastName,
        "username": (firstName + lastName).toLowerCase(),
        "profile_image": currentUser.photoURL,
        "social_image": currentUser.photoURL,
        "accessToken": googleSignInAuthentication.accessToken,
        "login_type": LoginTypeGoogle,
        "user_type": LoginTypeUser,
      };

      log("Google Login Json" + jsonEncode(req));

      await loginUser(req, isSocialLogin: true).then((value) async {
        await loginFromFirebaseUser(currentUser, loginData: value);
      }).catchError((e) {
        log(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  //endregion

  //region Email
  Future<void> signUpWithEmailPassword(context, {required RegisterResponse registerResponse, bool? isOTP, bool isLogin = true}) async {
    RegisterData? registerData = registerResponse.registerData!;

    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(email: registerData.email.validate(), password: registerData.password.validate()).catchError((e) async {
      await _auth.signInWithEmailAndPassword(email: registerData.email.validate(), password: registerData.password.validate()).then((value) {
        //
        setRegisterData(
          currentUser: value.user!,
          registerData: registerData,
          userModel: UserData(
            uid: value.user!.uid,
            api_token: registerData.api_token,
            contact_number: registerData.contact_number,
            display_name: registerData.display_name,
            email: registerData.email,
            first_name: registerData.first_name,
            last_name: registerData.last_name,
            user_type: registerData.user_type,
            username: registerData.username,
            password: registerData.password,
          ),
          isRegister: true,
        );
      }).catchError((e) {
        //
      });

      log("Err ${e.toString()}");
    });
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;
      String displayName = registerData.first_name.validate() + registerData.last_name.validate();

      UserData userModel = UserData()
        ..uid = currentUser.uid
        ..email = currentUser.email
        ..contact_number = registerData.contact_number
        ..first_name = registerData.first_name.validate()
        ..last_name = registerData.last_name.validate()
        ..username = registerData.username.validate()
        ..display_name = displayName
        ..user_type = LoginTypeUser
        ..loginType = getStringAsync(LOGIN_TYPE)
        ..created_at = Timestamp.now().toDate().toString()
        ..updated_at = Timestamp.now().toDate().toString()
        ..player_id = getStringAsync(PLAYERID);

      setRegisterData(currentUser: currentUser, registerData: registerData, userModel: userModel, isRegister: isLogin);
    }
  }

  Future<UserData> signInWithEmailPassword(context, {required UserData userData}) async {
    return await _auth.signInWithEmailAndPassword(email: userData.email.validate(), password: userData.password.validate()).then((value) async {
      final User user = value.user!;

      UserData userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      return userModel;
    }).catchError((e) {
      log(e.toString());

      throw USER_NOT_FOUND;
    });
  }

  //endregion

  //region Change password
  Future<void> changePassword(String newPassword) async {
    await FirebaseAuth.instance.currentUser!.updatePassword(newPassword).then((value) async {
      await setValue("PASSWORD", newPassword);
    });
  }

  //endregion

  //region Common Methods
  Future<void> updateUserData(UserData user) async {
    userService.updateDocument(
      {
        'player_id': getStringAsync(PLAYERID),
        'updatedAt': Timestamp.now(),
      },
      user.uid,
    );
  }

  Future<void> loginFromFirebaseUser(User currentUser, {LoginResponse? loginData}) async {
    if (loginData!.data != null) {
      if (await userService.isUserExist(loginData.data!.email)) {
        log(" User  ${loginData.data!.api_token.validate()}");

        ///Return user data
        await userService.userByEmail(loginData.data!.email).then((user) async {
          setRegisterData(currentUser: currentUser, userModel: loginData.data!, isRegister: false);
        }).catchError((e) {
          log(e);
          throw e;
        });
      } else {
        log("Create User");

        /// Create user
        loginData.data!.uid = currentUser.uid.validate();
        loginData.data!.user_type = LoginTypeUser;
        loginData.data!.loginType = LoginTypeGoogle;
        loginData.data!.player_id = getStringAsync(PLAYERID);
        if (isIOS) {
          loginData.data!.display_name = currentUser.displayName;
        }

        log(loginData.data!);

        setRegisterData(currentUser: currentUser, userModel: loginData.data!, isRegister: true);
      }
    } else {
      appStore.setLoading(false);

      log("---------------Error---------------");
    }
  }

  Future<void> setRegisterData({required User currentUser, RegisterData? registerData, required UserData userModel, bool isRegister = true}) async {
    await appStore.setUserProfile(currentUser.photoURL.validate());

    log("============UserModel: ${userModel.toJson()}");
    if (isRegister) {
      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
        if (registerData != null) {
          // Login Request
          var request = {
            UserKeys.email: registerData.email.validate(),
            UserKeys.password: registerData.password.validate(),
            UserKeys.playerId: getStringAsync(PLAYERID),
          };

          // Calling Login API
          await loginUser(request).then((res) async {
            if (res.data!.user_type == LoginTypeUser) {
              // When Login is Successfully done and will redirect to HomeScreen.
              toast(language!.loginSuccessfully, print: true);
              if (res.data != null) await saveUserData(res.data!);
              appStore.setLoading(false);
              push(HomeScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
            }
          }).catchError((e) {
            toast("Please Login Again");
            appStore.setLoading(false);

            throw USER_CANNOT_LOGIN;
          });
        }
      }).catchError((e) {
        log(e.toString());
        appStore.setLoading(false);

        throw USER_NOT_CREATED;
      });
    } else {
      appStore.setLoading(false);

      await saveUserData(userModel);
      push(HomeScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
    }
  }

  //endregion

  //region OTP

  Future<void> loginWithOTP(BuildContext context, String phoneNumber) async {
    return await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          toast('The provided phone number is not valid.');
          throw 'The provided phone number is not valid.';
        } else {
          toast(e.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        finish(context);

        appStore.setLoading(false);

        showInDialog(
          context,
          contentPadding: EdgeInsets.zero,
          builder: (p0) => AppCommonDialog(
            title: "ENTER OTP ",
            child: OTPDialog(verificationId: verificationId, isCodeSent: true, phoneNumber: phoneNumber),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }

  Future<void> signUpWithOTP(context, RegisterData data) async {
    AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: data.verificationId.validate(),
      smsCode: data.otpCode.validate(),
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) {
      if (result.user != null) {
        User currentUser = result.user!;
        UserData userModel = UserData();
        var displayName = data.first_name.validate() + data.last_name.validate();

        userModel.uid = currentUser.uid.validate();
        userModel.email = data.email.validate();
        userModel.contact_number = data.contact_number.validate();
        userModel.first_name = data.first_name.validate();
        userModel.last_name = data.last_name.validate();
        userModel.username = data.username.validate();
        userModel.display_name = displayName;
        userModel.user_type = LoginTypeUser;
        userModel.loginType = LoginTypeOTP;
        userModel.created_at = Timestamp.now().toDate().toString();
        userModel.updated_at = Timestamp.now().toDate().toString();
        userModel.player_id = getStringAsync(PLAYERID);

        log("User ${userModel.toJson()}");

        setRegisterData(currentUser: currentUser, registerData: data, userModel: userModel, isRegister: true);
      }
    });
  }

//endregion

}
