import 'package:flutter/material.dart';

import '../../constants/resources.dart';
import '../../utils/responsive.dart';
import '../../utils/widget_utils.dart';
import '../../widgets/basic_button.dart';
import '../../widgets/basic_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Resources.logoImg,
                    fit: BoxFit.cover,
                    width: Responsive.width(context) * .5,
                  ),
                  space(30),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(context) * .05,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        space(20),
                        Text(
                          'Please enter the email address of your Dormly account and we\'ll send you a reset link on your provided email.',
                        ),
                        space(20),
                        BasicTextField(
                          controller: _emailCont,
                          hint: 'Email',
                          prefix: Icon(Icons.email),
                        ),
                        space(20),
                        BasicButton(
                          text: 'Send Reset Link',
                          onPressed: () async {
                            if (true) {
                              pop();
                              showSnack(
                                message:
                                    'Password reset link has been sent to email.',
                                type: SnackType.success,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
