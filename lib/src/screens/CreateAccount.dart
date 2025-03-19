import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'Login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountScreen extends StatefulWidget {
  final String method;

  const CreateAccountScreen(this.method, {super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final nameController = TextEditingController();
  final phonenumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void dialog(type, title, desc) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.bottomSlide,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CREATE ACCOUNT".tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(top: 60.0),
            //   child: Center(
            //     child: SizedBox(
            //         width: 200,
            //         height: 150,
            //         child: Image.asset('assets/images/senzelife.png')),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Name'.tr(),
                  hintText: '',
                  prefixIcon: const Icon(Icons.people, size: 24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                  controller: phonenumberController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Phone Number'.tr(),
                    hintText: '',
                    prefixIcon: const Icon(Icons.phone, size: 24),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(8),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Email'.tr(),
                    hintText: '',
                    prefixIcon: const Icon(Icons.email, size: 24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
              child: TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password'.tr(),
                  hintText: '',
                  prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: _toggle,
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 0, bottom: 15),
              child: TextField(
                controller: passwordConfirmController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Confirm Password'.tr(),
                  hintText: '',
                  prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: _toggle,
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              margin: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () => {
                  EasyLoading.show(status: 'Submitting'.tr()),
                  if (passwordController.text == passwordConfirmController.text)
                    {
                      SignUp(nameController.text, phonenumberController.text,
                          emailController.text, passwordController.text)
                    }
                  else
                    {
                      EasyLoading.dismiss(),
                      dialog(DialogType.error, 'Error'.tr(),
                          'Password is not identical.'.tr())
                    }
                },
                child: Text(
                  'Submit'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> SignUp(name, phonenumber, email, password) async {
    if (name != "" &&
        phonenumber != "" &&
        email != "" &&
        password != "" &&
        password.length > 5) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = userCredential.user;
        user?.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user?.uid)
            .set({
          'CreatedAt': DateTime.now(),
          'Name': name,
          'PhoneNumber': phonenumber,
          'Email': email,
          'Uid': user?.uid,
          'AlertNotification': true,
          "RuleBasedNotification": false
        }).then((value) => {
                  EasyLoading.dismiss(),
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide,
                    title: 'Account created'.tr(),
                    desc: 'Please verify email in your inbox/junk'.tr(),
                    btnOkOnPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                  ).show().catchError(
                      (error) => print("Failed to add user: $error"))
                });
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        if (e.code == 'weak-password') {
          dialog(DialogType.error, 'Error'.tr(),
              'The password provided is too weak'.tr());

          // if (kDebugMode) {
          //   print('The password provided is too weak.');
          // }
        } else if (e.code == 'email-already-in-use') {
          dialog(DialogType.error, 'Error'.tr(),
              'The account already exists for that email'.tr());

          // if (kDebugMode) {
          //   print('The account already exists for that email.');
          // }
        }
      } catch (e) {
        EasyLoading.dismiss();
        // if (kDebugMode) {
        //   print(e);
        // }
      }
    } else {
      EasyLoading.dismiss();
      dialog(DialogType.error, 'Error'.tr(), 'Fill in required fields'.tr());
    }
  }
}
