import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traccar_client/main_screen.dart';

import '../../constants/colors.dart';
import '../../utils/utility.dart';
import '../../utils/widget_utils.dart';
import '../../widgets/basic_button.dart';
import 'forgot_password.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator:
                  (val) =>
                      val != null && emailRegex.hasMatch(val)
                          ? null
                          : 'Enter a valid email',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator:
                  (val) =>
                      val != null && val.length >= 6
                          ? null
                          : 'Minimum 6 characters',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  goto(widget: ForgotPasswordScreen());
                },
                child: Text('Forgot Password'),
              ),
            ),
            space(10),
            SizedBox(
              width: double.maxFinite,
              child: BasicButton(
                text: 'Login',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (true) {
                      gotoClear(widget: MainScreen());
                    }
                  }
                },
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      children: [
                        const TextSpan(
                          text: 'By continuing, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: _termsTap,
                          // Add onTap if needed with GestureRecognizer
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: _privacyTap,
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // Inside build method:

  TapGestureRecognizer _termsTap =
      TapGestureRecognizer()
        ..onTap = () {
          // Open terms URL or page
        };
  TapGestureRecognizer _privacyTap =
      TapGestureRecognizer()
        ..onTap = () {
          // Open privacy policy
        };
}
