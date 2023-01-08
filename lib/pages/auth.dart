import 'package:flutter/material.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'dart:convert';
import 'package:robopole_mob/utils/storageUtils.dart';

import '../utils/APIUri.dart';
import '../utils/dialogs.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String login = '';
  String password = '';
  bool isError = false;
  String errorMessage = '';

  void auth() async{
    showLoader(context);
    var response = await http.post(
        Uri.parse(
            '${APIUri.User.Authenticate}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'login': login, 'password': password}));

    if (response.statusCode == 200) {
      User user = User.fromJson(response.body);

      if (user.MobileAccess as bool) {
        await LocalStorage.WriteUser(user);
        await LocalStorage.Cultures();

        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const FunctionalPage()), (
                route) => false);
      }
      else{
        errorMessage = "Нет доступа к мобильному приложению";
        Navigator.pop(context);
        showErrorDialog(context, errorMessage);
      }
    }
    else{
      var error = Error.fromResponse(response);
      errorMessage = "${error.Message}";
      Navigator.pop(context);
      showErrorDialog(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          appBar: AppBar(
            title: Text("Робополе 2022"),
            leading: Icon(Icons.android),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const Text(
                      "Войдите в РобоПоле",
                      style: TextStyle(color: Colors.black54, fontSize: 24),
                    )),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: TextField(
                    onChanged: (value) {
                      login = value;
                    },
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Логин',
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                          const BorderSide(color: Colors.black54, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: Colors.deepOrangeAccent.withOpacity(0.5),
                              width: 2)),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: TextField(
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: 'Пароль',
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                              const BorderSide(color: Colors.black54, width: 2)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.deepOrangeAccent.withOpacity(0.5),
                                  width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: auth,
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: const Text(
                      "Войти",
                      style: TextStyle(fontSize: 20),
                    )),
              ],
            ),
          ),
        );
  }
}
