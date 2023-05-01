import 'package:devdeme3/auth.dart';
import 'package:flutter/material.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({required this.username, super.key});
  final String username;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  TextEditingController coo = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("confirm code"),
        ),
        body: Column(children: [
          TextFormField(
            controller: coo,
            decoration: const InputDecoration(hintText: 'enter code'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                if (coo.text.trim().isNotEmpty) {
                  AuthClass().confirmUser(
                      username: widget.username, confirmationCode: coo.text);
                }
              },
              child: const Text('confirm'))
        ]));
  }
}
