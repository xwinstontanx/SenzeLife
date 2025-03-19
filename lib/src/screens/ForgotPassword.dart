import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("FORGOT PASSWORD".tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: kIsWeb ? 600.0 : double.infinity,
              child: Container(
                alignment: Alignment.center,
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black26, width: 1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  elevation: 7,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'ENTER EMAIL ADDRESS TO RESET PASSWORD'.tr(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10, bottom: 0),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Email'.tr(),
                              hintText: '',
                              prefixIcon: const Icon(Icons.email, size: 24),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 250,
                          margin: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () =>
                                forgotPassword(emailController.text),
                            child: Text(
                              'SUBMIT'.tr(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> forgotPassword(String email) async {
    if (email.isNotEmpty) {
      try {
        final userCredential =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (userCredential.isEmpty) {
          // Email does not exist in Firebase Authentication
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'RESET PASSWORD'.tr(),
            desc: 'The email is invalid'.tr(),
            btnOkOnPress: () {},
          ).show();
        } else {
          // Email exists, send password reset email
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

          // Show success dialog
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'RESET PASSWORD'.tr(),
            desc: 'Please check your inbox/junk to reset password'.tr(),
            btnOkOnPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ).show();
        }
      } on FirebaseAuthException catch (e) {
        print(e.code);
        // Handle FirebaseAuth exceptions if needed
      } catch (e) {
        // Handle other exceptions if needed
        print(e.toString());
      }
    } else {
      // Email is empty
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error'.tr(),
        desc: 'Kindly fill up all the fields'.tr(),
        btnOkOnPress: () {},
      ).show();
    }
  }
}
