import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:devdeme3/auth.dart';
import 'package:devdeme3/confirm.dart';
import 'package:devdeme3/login.dart';
import 'package:devdeme3/main.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();

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
          title: Text("register"),
        ),
        body: Column(children: [
          TextFormField(
            controller: username,
            decoration: const InputDecoration(hintText: 'name'),
          ),
          const SizedBox(
            height: 20,
          ),
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
                  print("got ehre");
                  AuthClass().signUpUser(
                      username: email.text,
                      password: password.text,
                      email: email.text,
                      onConfirmCode: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfirmPage(
                                      username: email.text,
                                    )));
                      },
                      onNavigateToBlogPage: () async {
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
              child: const Text('Register')),
          const SizedBox(
            height: 30,
          ),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text("sign in"))
        ]));
  }
}
