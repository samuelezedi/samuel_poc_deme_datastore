import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:devdeme3/auth.dart';
import 'package:devdeme3/confirm.dart';
import 'package:devdeme3/main.dart';
import 'package:devdeme3/register.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  AuthUser? user;

  Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  Future<AuthUser> getCurrentUser() async {
    final user = await Amplify.Auth.getCurrentUser();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("login"),
        ),
        body: Column(children: [
          TextFormField(
            controller: email,
            decoration: const InputDecoration(hintText: 'email'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'password'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                if (email.text.trim().isNotEmpty &&
                    password.text.trim().isNotEmpty) {
                  AuthClass().signInUser(email.text, password.text,
                      onConfirmCode: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmPage(
                                  username: email.text,
                                )));
                  }, doNavigateToBlogPage: () async {
                    if (await isUserSignedIn()) {
                      user = await getCurrentUser();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlogPage(
                                    user: user!,
                                  )));
                    }
                  });
                }
              },
              child: const Text('Login')),
          const SizedBox(
            height: 30,
          ),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text("sign up"))
        ]));
  }
}
